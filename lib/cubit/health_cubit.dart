import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/appointment_entry.dart';
import '../models/blood_pressure_entry.dart';
import '../models/food_entry.dart';
import '../models/glucose_entry.dart';
import '../models/labTest_entry.dart';
import '../models/med_entry.dart';
import '../models/offline_queue_entry.dart';
import '../models/symptom_entry.dart';
import '../models/weight_entry.dart';
import '../services/account_scoped_storage.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import '../services/token_service.dart';
import '../widgets/alarm_screen.dart';
import '../widgets/components.dart';

// ─── Storage key constants ────────────────────────────────────────────────────
// Keys are now relative; AccountScopedStorage namespaces them per user.
class _Keys {
  static const bp         = 'blood_pressure_entries';
  static const weight     = 'weight_entries';
  static const glucose    = 'glucose_entries';
  static const meds       = 'medication_entries';
  static const symptoms   = 'symptom_entries';
  static const food       = 'food_entries';
  static const reminders  = 'reminder_entries';
  static const labs       = 'lab_test_entries';
  static const appts      = 'appointments';
  static const tiles      = 'health_tiles';
}

/// HealthCubit now:
///   • stores everything under the active user's namespace (fixes multi-account bug)
///   • tries to push every write to the server via SyncService
///   • marks entries as synced once the server confirms
///   • drains the offline queue on init (in case the last session had pending items)
class HealthCubit extends Cubit<List<BloodPressureEntry>> {
  final _uuid = const Uuid();
  final _sync = SyncService();

  HealthCubit() : super([]) {
    tiles = List.from(allTiles);
    _init();
  }

  Future<void> _init() async {
    // Drain any items left over from a previous offline session
    await _sync.drainQueue();
    await Future.wait([
      _loadEntries(),
      _loadWeightEntries(),
      _loadGlucoseEntries(),
      _loadMedicationEntries(),
      _loadSymptomEntries(),
      _loadFoodEntries(),
      _loadReminders(),
      _loadAppointments(),
      _loadLabTests(),
      _loadTiles(),
    ]);
  }

  // Convenience: get an account-scoped store.
  // Returns null if no user is active (e.g. between logout and login).
  Future<AccountScopedStorage?> get _store async {
    try {
      return await AccountScopedStorage.forCurrentUser();
    } catch (_) {
      return null;
    }
  }

  DateTime selectedDate = DateTime.now();

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    emit(List.from(state));
  }

  DateTime getSelectedDate() => selectedDate;

  // ─── BLOOD PRESSURE ────────────────────────────────────────────────────────

  Future<void> _loadEntries() async {
    final store = await _store;
    if (store == null) return;
    final list = store.getStringList(_Keys.bp) ?? [];
    final entries = list.map(BloodPressureEntry.fromJson).toList();
    emit(entries);
  }

  Future<void> _saveEntries(List<BloodPressureEntry> entries) async {
    final store = await _store;
    await store?.setStringList(_Keys.bp, entries.map((e) => e.toJson()).toList());
  }

  List<BloodPressureEntry> getEntries() => state;

  Future<void> addBloodPressure(BloodPressureEntry entry) async {
    final e = entry.localId.isEmpty
        ? entry.copyWith(localId: _uuid.v4())
        : entry;

    final updated = List<BloodPressureEntry>.from(state)..add(e);
    emit(updated);
    await _saveEntries(updated);

    final serverResp = await _sync.pushRecord(
      modelType: 'blood_pressure',
      apiPayload: e.toApiPayload(),
      localRecordId: e.localId,
    );

    if (serverResp != null) {
      // Mark entry synced and store the server-assigned id
      final serverId = serverResp['log_id'] as int?;
      final synced = updated.map((entry) {
        if (entry.localId == e.localId) {
          return entry.copyWith(isSynced: true, serverId: serverId);
        }
        return entry;
      }).toList();
      emit(synced);
      await _saveEntries(synced);
    }
  }

  Future<void> deleteBloodPressure(BloodPressureEntry entry) async {
    final updated = state.where((e) => e.localId != entry.localId).toList();
    emit(updated);
    await _saveEntries(updated);
    // TODO: push DELETE to server if entry.serverId != null
  }

  // ─── WEIGHT ────────────────────────────────────────────────────────────────

  List<WeightEntry> _weightEntries = [];
  List<WeightEntry> getWeightEntries() => _weightEntries;

  Future<void> _loadWeightEntries() async {
    final store = await _store;
    if (store == null) return;
    final list = store.getStringList(_Keys.weight) ?? [];
    _weightEntries = list.map(WeightEntry.fromJson).toList();
  }

  Future<void> _saveWeightEntries() async {
    final store = await _store;
    await store?.setStringList(
        _Keys.weight, _weightEntries.map((e) => e.toJson()).toList());
  }

  Future<void> addWeight(WeightEntry entry) async {
    final e =
    entry.localId.isEmpty ? entry.copyWith(localId: _uuid.v4()) : entry;
    _weightEntries.add(e);
    await _saveWeightEntries();
    emit(List.from(state));

    final serverResp = await _sync.pushRecord(
      modelType: 'health_metrics',
      apiPayload: e.toApiPayload(),
      localRecordId: e.localId,
    );

    if (serverResp != null) {
      final idx = _weightEntries.indexWhere((w) => w.localId == e.localId);
      if (idx != -1) {
        _weightEntries[idx] = e.copyWith(
          isSynced: true,
          serverId: serverResp['log_id'] as int?,
        );
        await _saveWeightEntries();
        emit(List.from(state));
      }
    }
  }

  // ─── GLUCOSE ───────────────────────────────────────────────────────────────

  List<GlucoseEntry> _glucoseEntries = [];
  List<GlucoseEntry> getGlucoseEntries() => _glucoseEntries;

  Future<void> _loadGlucoseEntries() async {
    final store = await _store;
    if (store == null) return;
    final list = store.getStringList(_Keys.glucose) ?? [];
    _glucoseEntries = list.map(GlucoseEntry.fromJson).toList();
  }

  Future<void> _saveGlucoseEntries() async {
    final store = await _store;
    await store?.setStringList(
        _Keys.glucose, _glucoseEntries.map((e) => e.toJson()).toList());
  }

  Future<void> addGlucose(GlucoseEntry entry) async {
    final e =
    entry.localId.isEmpty ? entry.copyWith(localId: _uuid.v4()) : entry;
    _glucoseEntries.add(e);
    await _saveGlucoseEntries();
    emit(List.from(state));

    final serverResp = await _sync.pushRecord(
      modelType: 'glucose',
      apiPayload: e.toApiPayload(),
      localRecordId: e.localId,
    );

    if (serverResp != null) {
      final idx = _glucoseEntries.indexWhere((g) => g.localId == e.localId);
      if (idx != -1) {
        _glucoseEntries[idx] = e.copyWith(
          isSynced: true,
          serverId: serverResp['log_id'] as int?,
        );
        await _saveGlucoseEntries();
        emit(List.from(state));
      }
    }
  }

  // ─── MEDICATION ────────────────────────────────────────────────────────────
  // Note: Medications are stored locally as a flat MedicationEntry.
  // Syncing to the server's normalized schema (Medications + UserMedications)
  // would require a medication search endpoint. For now we log offline only
  // and mark them as not synced until a proper med-sync endpoint is added.

  List<MedicationEntry> _medicationEntries = [];
  List<MedicationEntry> getMedicationEntries() => _medicationEntries;

  Future<void> _loadMedicationEntries() async {
    final store = await _store;
    if (store == null) return;
    final list = store.getStringList(_Keys.meds) ?? [];
    _medicationEntries = list.map(MedicationEntry.fromJson).toList();
    emit(List.from(state));
  }

  Future<void> _saveMedicationEntries() async {
    final store = await _store;
    await store?.setStringList(
        _Keys.meds, _medicationEntries.map((e) => e.toJson()).toList());
  }

  Future<void> addMedication(MedicationEntry entry) async {
    _medicationEntries.add(entry);
    await _saveMedicationEntries();
    emit(List.from(state));
  }

  Future<void> deleteMedication(MedicationEntry entry) async {
    _medicationEntries.remove(entry);
    await _saveMedicationEntries();
    emit(List.from(state));
  }

  // ─── SYMPTOMS ──────────────────────────────────────────────────────────────

  List<SymptomEntry> _symptomEntries = [];
  List<SymptomEntry> getSymptomEntries() => _symptomEntries;

  Future<void> _loadSymptomEntries() async {
    final store = await _store;
    if (store == null) return;
    final list = store.getStringList(_Keys.symptoms) ?? [];
    _symptomEntries = list.map(SymptomEntry.fromJson).toList();
  }

  Future<void> _saveSymptomEntries() async {
    final store = await _store;
    await store?.setStringList(
        _Keys.symptoms, _symptomEntries.map((e) => e.toJson()).toList());
  }

  Future<void> addSymptom(SymptomEntry entry) async {
    _symptomEntries.add(entry);
    await _saveSymptomEntries();
    emit(List.from(state));
  }

  Future<void> deleteSymptom(SymptomEntry entry) async {
    _symptomEntries.remove(entry);
    await _saveSymptomEntries();
    emit(List.from(state));
  }

  // ─── FOOD LOG ──────────────────────────────────────────────────────────────

  List<FoodEntry> _foodEntries = [];
  List<FoodEntry> getFoodEntries() => _foodEntries;

  Map<String, List<FoodEntry>> getFoodEntriesByMeal(DateTime date) {
    final dayEntries = _foodEntries.where((e) =>
    e.dateTime.year == date.year &&
        e.dateTime.month == date.month &&
        e.dateTime.day == date.day);
    final grouped = <String, List<FoodEntry>>{};
    for (final e in dayEntries) {
      grouped.putIfAbsent(e.mealType ?? 'Other', () => []).add(e);
    }
    return grouped;
  }

  Future<void> _loadFoodEntries() async {
    final store = await _store;
    if (store == null) return;
    final list = store.getStringList(_Keys.food) ?? [];
    _foodEntries = list.map(FoodEntry.fromJson).toList();
    emit(List.from(state));
  }

  Future<void> _saveFoodEntries() async {
    final store = await _store;
    await store?.setStringList(
        _Keys.food, _foodEntries.map((e) => e.toJson()).toList());
  }

  Future<void> addFood(FoodEntry entry) async {
    _foodEntries.add(entry);
    await _saveFoodEntries();
    emit(List.from(state));
  }

  Future<void> deleteFood(FoodEntry entry) async {
    if (entry.hasImage) {
      final file = File(entry.imagePath!);
      if (await file.exists()) await file.delete();
    }
    _foodEntries.remove(entry);
    await _saveFoodEntries();
    emit(List.from(state));
  }

  // ─── REMINDERS ─────────────────────────────────────────────────────────────

  final List<ReminderEntry> _reminders = [];
  List<ReminderEntry> getReminders() => _reminders;

  final Map<String, String> _reminderLogStatus = {};
  Map<String, String> get reminderLogStatus => _reminderLogStatus;

  String _logKey(ReminderEntry entry, int timeIndex, DateTime date) =>
      '${entry.createdAt.millisecondsSinceEpoch}_${timeIndex}_'
          '${date.year}${date.month}${date.day}';

  void skipReminderLog(ReminderEntry entry, int timeIndex, DateTime date) {
    _reminderLogStatus[_logKey(entry, timeIndex, date)] = 'skipped';
    emit(List.from(state));
  }

  void resolveReminderLog(ReminderEntry entry, int timeIndex, DateTime date) {
    _reminderLogStatus[_logKey(entry, timeIndex, date)] = 'logged';
    emit(List.from(state));
  }

  bool isSkipped(ReminderEntry entry, int timeIndex, DateTime date) =>
      _reminderLogStatus[_logKey(entry, timeIndex, date)] == 'skipped';

  bool isResolved(ReminderEntry entry, int timeIndex, DateTime date) =>
      _reminderLogStatus[_logKey(entry, timeIndex, date)] == 'logged';

  Future<void> addReminder(ReminderEntry entry) async {
    _reminders.add(entry);
    await _saveReminders();
    NotificationService.scheduleReminder(entry);
    emit(List.from(state));
  }

  Future<void> updateReminder(ReminderEntry old, ReminderEntry updated) async {
    final index = _reminders.indexOf(old);
    if (index != -1) {
      _reminders[index] = updated;
      await _saveReminders();
      NotificationService.cancelReminder(old);
      NotificationService.scheduleReminder(updated);
      emit(List.from(state));
    }
  }

  Future<void> deleteReminder(ReminderEntry entry) async {
    _reminders.remove(entry);
    await _saveReminders();
    NotificationService.cancelReminder(entry);
    emit(List.from(state));
  }

  Future<void> _loadReminders() async {
    final store = await _store;
    if (store == null) return;
    final list = store.getStringList(_Keys.reminders) ?? [];
    _reminders
      ..clear()
      ..addAll(list.map(ReminderEntry.fromJson));

    for (final r in _reminders) {
      await NotificationService.cancelReminder(r);
      await NotificationService.scheduleReminder(r);
    }
    emit(List.from(state));
  }

  Future<void> _saveReminders() async {
    final store = await _store;
    await store?.setStringList(
        _Keys.reminders, _reminders.map((e) => e.toJson()).toList());
  }

  // ─── LAB TESTS ─────────────────────────────────────────────────────────────

  List<LabTestEntry> _labTests = [];
  List<LabTestEntry> getLabTests() => _labTests;

  Future<void> _loadLabTests() async {
    final store = await _store;
    if (store == null) return;
    final list = store.getStringList(_Keys.labs) ?? [];
    _labTests = list.map(LabTestEntry.fromJson).toList();
  }

  Future<void> _saveLabTests() async {
    final store = await _store;
    await store?.setStringList(
        _Keys.labs, _labTests.map((e) => e.toJson()).toList());
  }

  Future<void> addLabTest(LabTestEntry entry) async {
    _labTests.add(entry);
    await _saveLabTests();
    emit(List.from(state));
  }

  Future<void> deleteLabTest(LabTestEntry entry) async {
    final file = File(entry.imagePath);
    if (await file.exists()) await file.delete();
    _labTests.remove(entry);
    await _saveLabTests();
    emit(List.from(state));
  }

  Future<Map<String, dynamic>> uploadLabTest(File imageFile) async {
    final token = await TokenStorage.getAccessToken();
    final uri = Uri.parse('http://10.0.2.2:3000/api/user/lab-test');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['test_type'] = 'blood_test'
      ..fields['result_date'] = DateTime.now().toIso8601String()
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: http.MediaType('image', 'jpeg'),
      ));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return {
        'success': true,
        'message': json['message'],
        'lab_test_id': json['lab_test_id'],
        'ocr_text': json['ocr_text'] ?? '',
        'ocr_lines': json['ocr_lines'] ?? [],
      };
    } else {
      final error = jsonDecode(body) as Map<String, dynamic>;
      throw Exception(error['message'] ?? 'Upload failed');
    }
  }

  // ─── APPOINTMENTS ──────────────────────────────────────────────────────────

  List<AppointmentEntry> _appointments = [];
  List<AppointmentEntry> getAppointments() => _appointments;

  Future<void> _loadAppointments() async {
    final store = await _store;
    if (store == null) return;
    final list = store.getStringList(_Keys.appts) ?? [];
    _appointments = list.map(AppointmentEntry.fromJson).toList();
    emit(List.from(state));
  }

  Future<void> _saveAppointments() async {
    final store = await _store;
    await store?.setStringList(
        _Keys.appts, _appointments.map((e) => e.toJson()).toList());
  }

  Future<void> addAppointment(AppointmentEntry entry) async {
    _appointments.add(entry);
    await _saveAppointments();
    emit(List.from(state));
  }

  Future<void> deleteAppointment(AppointmentEntry entry) async {
    _appointments.remove(entry);
    await _saveAppointments();
    emit(List.from(state));
  }

  // ─── TILES ─────────────────────────────────────────────────────────────────

  List<HealthTile> tiles = [];
  List<String> _tileKeys = [];
  List<String> get tileKeys => _tileKeys;
  bool hasTiles() => _tileKeys.isNotEmpty;

  Future<void> _loadTiles() async {
    final store = await _store;
    if (store == null) return;
    _tileKeys = store.getStringList(_Keys.tiles) ?? [];
    emit(List.from(state));
  }

  Future<void> _saveTiles() async {
    final store = await _store;
    await store?.setStringList(_Keys.tiles, _tileKeys);
  }

  Future<void> addTile(String labelKey) async {
    if (_tileKeys.contains(labelKey)) return;
    _tileKeys.add(labelKey);
    await _saveTiles();
    emit(List.from(state));
  }

  List<HealthTile> getTiles() => _tileKeys
      .map((key) => allTiles.firstWhere(
        (t) => t.labelKey == key,
    orElse: () => allTiles.first,
  ))
      .toList();

  // ─── Called by AuthCubit after login ──────────────────────────────────────

  Future<void> reloadForCurrentUser() async {
    _weightEntries = [];
    _glucoseEntries = [];
    _medicationEntries = [];
    _symptomEntries = [];
    _foodEntries = [];
    _reminders.clear();
    _labTests = [];
    _appointments = [];
    _tileKeys = [];
    emit([]);
    await _init();
  }
}
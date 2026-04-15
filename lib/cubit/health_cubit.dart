import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment_entry.dart';
import '../models/blood_pressure_entry.dart';
import '../models/food_entry.dart';
import '../models/labTest_entry.dart';
import '../models/med_entry.dart';
import '../models/symptom_entry.dart';
import '../models/weight_entry.dart';
import '../services/notification_service.dart';
import '../widgets/alarm_screen.dart';
import '../models/glucose_entry.dart';


class HealthCubit extends Cubit<List<BloodPressureEntry>> {
  static const _bpKey = 'blood_pressure_entries';
  static const _weightKey = 'weight_entries';
  static const _glucoseKey = 'glucose_entries';
  static const _medsKey = 'medication_entries';
  static const _symptomKey = 'symptom_entries';
  static const _foodKey = 'food_entries';
  static const _reminderKey = 'reminder_entries';
  static const _labKey = 'lab_test_entries';
  static const _appointmentsKey = 'appointments';



  HealthCubit() : super([]) {
    _loadEntries();
    _loadWeightEntries();
    _loadGlucoseEntries();
    _loadMedicationEntries();
    _loadSymptomEntries();
    _loadFoodEntries();
    _loadReminders();
    _loadAppointments();
  }

  DateTime selectedDate = DateTime.now();


  /// BLOOD PRESSURE


  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_bpKey) ?? [];
    final entries = list.map((e) => BloodPressureEntry.fromJson(e)).toList();
    emit(entries);
  }

  Future<void> _saveEntries(List<BloodPressureEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final list = entries.map((e) => e.toJson()).toList();
    await prefs.setStringList(_bpKey, list);
  }

  List<BloodPressureEntry> getEntries() => state;

  Future<void> addBloodPressure(BloodPressureEntry entry) async {
    final updated = List<BloodPressureEntry>.from(state)..add(entry);
    emit(updated);
    await _saveEntries(updated);
  }


  /// WEIGHT


  List<WeightEntry> _weightEntries = [];

  List<WeightEntry> getWeightEntries() => _weightEntries;

  Future<void> _loadWeightEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_weightKey) ?? [];
    _weightEntries = list.map((e) => WeightEntry.fromJson(e)).toList();
  }

  Future<void> _saveWeightEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _weightEntries.map((e) => e.toJson()).toList();
    await prefs.setStringList(_weightKey, list);
  }

  Future<void> addWeight(WeightEntry entry) async {
    _weightEntries.add(entry);
    await _saveWeightEntries();

    emit(List.from(state));
  }


  /// GLUCOSE


  List<GlucoseEntry> _glucoseEntries = [];

  List<GlucoseEntry> getGlucoseEntries() => _glucoseEntries;


  Future<void> _loadGlucoseEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_glucoseKey) ?? [];

    _glucoseEntries =
        list.map((e) => GlucoseEntry.fromJson(e)).toList();
  }

  Future<void> _saveGlucoseEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _glucoseEntries.map((e) => e.toJson()).toList();

    await prefs.setStringList(_glucoseKey, list);
  }

  Future<void> addGlucose(GlucoseEntry entry) async {
    _glucoseEntries.add(entry);

    await _saveGlucoseEntries();

    emit(List.from(state));
  }

  /// MEDICATION

  List<MedicationEntry> _medicationEntries = [];
  List<MedicationEntry> getMedicationEntries() => _medicationEntries;

  Future<void> _loadMedicationEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_medsKey) ?? [];
    _medicationEntries = list.map((e) => MedicationEntry.fromJson(e)).toList();
    emit(List.from(state));
  }

  Future<void> _saveMedicationEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _medicationEntries.map((e) => e.toJson()).toList();
    await prefs.setStringList(_medsKey, list);
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

  /// Symptoms

  List<SymptomEntry> _symptomEntries = [];

  List<SymptomEntry> getSymptomEntries() => _symptomEntries;

  Future<void> _loadSymptomEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_symptomKey) ?? [];
    _symptomEntries = list.map((e) => SymptomEntry.fromJson(e)).toList();
  }

  Future<void> _saveSymptomEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _symptomEntries.map((e) => e.toJson()).toList();
    await prefs.setStringList(_symptomKey, list);
  }

  Future<void> addSymptom(SymptomEntry entry) async {
    _symptomEntries.add(entry);
    await _saveSymptomEntries();

    emit(List.from(state)); // triggers UI rebuild
  }
  Future<void> deleteSymptom(SymptomEntry entry) async {
    _symptomEntries.remove(entry);

    await _saveSymptomEntries();

    emit(List.from(state));
  }


  /// FOOD LOG

  List<FoodEntry> _foodEntries = [];
  List<FoodEntry> getFoodEntries() => _foodEntries;

  Map<String, List<FoodEntry>> getFoodEntriesByMeal(DateTime date) {
    final dayEntries = _foodEntries.where((e) =>
    e.dateTime.year == date.year &&
        e.dateTime.month == date.month &&
        e.dateTime.day == date.day).toList();

    final Map<String, List<FoodEntry>> grouped = {};
    for (final e in dayEntries) {
      final key = e.mealType ?? 'Other';
      grouped.putIfAbsent(key, () => []).add(e);
    }
    return grouped;
  }

  Future<void> _loadFoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_foodKey) ?? [];
    _foodEntries = list.map((e) => FoodEntry.fromJson(e)).toList();
    emit(List.from(state));
  }

  Future<void> _saveFoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _foodEntries.map((e) => e.toJson()).toList();
    await prefs.setStringList(_foodKey, list);
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

  /// DATE (SHARED)

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    emit(List.from(state));
  }

  DateTime getSelectedDate() => selectedDate;

  final List<ReminderEntry> _reminders = [];
  List<ReminderEntry> getReminders() => _reminders;

  /// REMINDERS



  final Map<String, String> _reminderLogStatus = {};
  Map<String, String> get reminderLogStatus => _reminderLogStatus;

  String _logKey(ReminderEntry entry, int timeIndex, DateTime date) {
    return '${entry.createdAt.millisecondsSinceEpoch}_${timeIndex}_${date.year}${date.month}${date.day}';
  }

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
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_reminderKey) ?? [];
    _reminders.clear();
    _reminders.addAll(
      list.map((e) => ReminderEntry.fromJson(e)).toList(),
    );

    for (final r in _reminders) {
      NotificationService.scheduleReminder(r);
    }

    emit(List.from(state));

    for (final r in _reminders) {
      await NotificationService.cancelReminder(r);
      await NotificationService.scheduleReminder(r);
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _reminders.map((e) => e.toJson()).toList();
    await prefs.setStringList(_reminderKey, list);
  }

  ///    Lab Tests

  List<LabTestEntry> _labTests = [];
  List<LabTestEntry> getLabTests() => _labTests;

  Future<void> _loadLabTests() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_labKey) ?? [];

    _labTests = list.map((e) => LabTestEntry.fromJson(e)).toList();
  }

  Future<void> _saveLabTests() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _labTests.map((e) => e.toJson()).toList();

    await prefs.setStringList(_labKey, list);
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
/// Doctor appointment

  List<AppointmentEntry> _appointments = [];
  List<AppointmentEntry> getAppointments() => _appointments;

  Future<void> _loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_appointmentsKey) ?? [];
    _appointments = list.map((e) => AppointmentEntry.fromJson(e)).toList();
    emit(List.from(state));
  }

  Future<void> _saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _appointmentsKey, _appointments.map((e) => e.toJson()).toList());
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

}




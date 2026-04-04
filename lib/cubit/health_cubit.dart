import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/blood_pressure_entry.dart';
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


  HealthCubit() : super([]) {
    _loadEntries();
    _loadWeightEntries();
    _loadGlucoseEntries();
    _loadMedicationEntries();
    _loadSymptomEntries();
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

    emit(List.from(state)); // triggers UI rebuild
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




  /// DATE (SHARED)

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    emit(List.from(state));
  }

  DateTime getSelectedDate() => selectedDate;

  final List<ReminderEntry> _reminders = [];
  List<ReminderEntry> getReminders() => _reminders;

  /// REMINDERS
  void addReminder(ReminderEntry entry) {
    _reminders.add(entry);
    NotificationService.scheduleReminder(entry);
    emit(List.from(state));
  }

  void updateReminder(ReminderEntry old, ReminderEntry updated) {
    final index = _reminders.indexOf(old);
    if (index != -1) {
      _reminders[index] = updated;
      NotificationService.cancelReminder(old);
      NotificationService.scheduleReminder(updated);
      emit(List.from(state));
    }
  }

  void deleteReminder(ReminderEntry entry) {
    _reminders.remove(entry);
    NotificationService.cancelReminder(entry);
    emit(List.from(state));
  }
}

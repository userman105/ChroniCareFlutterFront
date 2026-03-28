import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/blood_pressure_entry.dart';
import '../models/weight_entry.dart';
import '../services/notification_service.dart';
import '../widgets/alarm_screen.dart';

class HealthCubit extends Cubit<List<BloodPressureEntry>> {
  static const _bpKey = 'blood_pressure_entries';
  static const _weightKey = 'weight_entries';

  HealthCubit() : super([]) {
    _loadEntries();
    _loadWeightEntries();
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


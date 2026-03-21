import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/blood_pressure_entry.dart';

class HealthCubit extends Cubit<List<BloodPressureEntry>> {
  static const _key = 'blood_pressure_entries';

  HealthCubit() : super([]) {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    final entries = list.map((e) => BloodPressureEntry.fromJson(e)).toList();
    emit(entries);
  }

  Future<void> _saveEntries(List<BloodPressureEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final list = entries.map((e) => e.toJson()).toList();
    await prefs.setStringList(_key, list);
  }

  Future<void> addBloodPressure(BloodPressureEntry entry) async {
    final updated = List<BloodPressureEntry>.from(state)..add(entry);
    emit(updated);
    await _saveEntries(updated);
  }

  List<BloodPressureEntry> getEntries() => state;
}
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/blood_pressure_entry.dart';
class HealthCubit extends Cubit<List<BloodPressureEntry>> {
  HealthCubit() : super([]);

  void addBloodPressure(BloodPressureEntry entry) {
    final updated = List<BloodPressureEntry>.from(state)..add(entry);
    emit(updated);
  }

  List<BloodPressureEntry> getEntries() => state;
}
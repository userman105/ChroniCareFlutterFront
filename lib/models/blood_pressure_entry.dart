class BloodPressureEntry {
  final int systolic;
  final int diastolic;
  final int? heartRate;
  final DateTime dateTime;
  final String? notes;

  BloodPressureEntry({
    required this.systolic,
    required this.diastolic,
    this.heartRate,
    this.notes,
    required this.dateTime,
  });
}
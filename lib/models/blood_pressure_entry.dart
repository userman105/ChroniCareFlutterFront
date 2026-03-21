import 'dart:convert';

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

  /// Convert the entry to a Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'heartRate': heartRate,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
    };
  }

  factory BloodPressureEntry.fromMap(Map<String, dynamic> map) {
    return BloodPressureEntry(
      systolic: map['systolic'],
      diastolic: map['diastolic'],
      heartRate: map['heartRate'],
      dateTime: DateTime.parse(map['dateTime']),
      notes: map['notes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory BloodPressureEntry.fromJson(String source) =>
      BloodPressureEntry.fromMap(json.decode(source));
}
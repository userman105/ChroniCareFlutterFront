import 'dart:convert';

class GlucoseEntry {
  final double value;
  final String unit;
  final DateTime dateTime;
  final String? notes;

  GlucoseEntry({
    required this.value,
    required this.unit,
    required this.dateTime,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'unit': unit,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
    };
  }

  factory GlucoseEntry.fromMap(Map<String, dynamic> map) {
    return GlucoseEntry(
      value: (map['value'] as num).toDouble(),
      unit: map['unit'],
      dateTime: DateTime.parse(map['dateTime']),
      notes: map['notes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory GlucoseEntry.fromJson(String source) =>
      GlucoseEntry.fromMap(json.decode(source));
}
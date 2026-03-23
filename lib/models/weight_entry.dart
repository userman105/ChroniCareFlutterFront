import 'dart:convert';

class WeightEntry {
  final double? kg;
  final double? lbs;
  final DateTime dateTime;
  final String? notes;

  WeightEntry({
    this.kg,
    this.lbs,
    required this.dateTime,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'kg': kg,
      'lbs': lbs,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
    };
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      kg: map['kg'] != null ? (map['kg'] as num).toDouble() : null,
      lbs: map['lbs'] != null ? (map['lbs'] as num).toDouble() : null,
      dateTime: DateTime.parse(map['dateTime']),
      notes: map['notes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory WeightEntry.fromJson(String source) =>
      WeightEntry.fromMap(json.decode(source));
}
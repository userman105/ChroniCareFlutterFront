import 'dart:convert';

class SymptomEntry {
  final String symptom;
  final int severity;
  final String? notes;
  final DateTime dateTime;

  SymptomEntry({
    required this.symptom,
    required this.severity,
    this.notes,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'symptom': symptom,
      'severity': severity,
      'notes': notes,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory SymptomEntry.fromMap(Map<String, dynamic> map) {
    return SymptomEntry(
      symptom: map['symptom'],
      severity: map['severity'] ?? 5,
      notes: map['notes'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }

  String toJson() => json.encode(toMap());

  factory SymptomEntry.fromJson(String source) =>
      SymptomEntry.fromMap(json.decode(source));
}
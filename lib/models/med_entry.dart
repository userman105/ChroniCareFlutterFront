import 'dart:convert';

class MedicationEntry {
  final String medicationName;   // from CSV search or custom
  final bool isCustom;           // true if user typed it manually
  final double dose;
  final String doseUnit;         // "mg", "ml", "mcg", "IU", etc.
  final String form;             // "tablet", "capsule", "injection", "syrup", etc.
  final int quantity;            // how many tablets/capsules taken
  final DateTime dateTime;
  final String? notes;

  MedicationEntry({
    required this.medicationName,
    required this.isCustom,
    required this.dose,
    required this.doseUnit,
    required this.form,
    required this.quantity,
    required this.dateTime,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicationName': medicationName,
      'isCustom': isCustom,
      'dose': dose,
      'doseUnit': doseUnit,
      'form': form,
      'quantity': quantity,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
    };
  }

  factory MedicationEntry.fromMap(Map<String, dynamic> map) {
    return MedicationEntry(
      medicationName: map['medicationName'],
      isCustom: map['isCustom'] ?? false,
      dose: (map['dose'] as num).toDouble(),
      doseUnit: map['doseUnit'],
      form: map['form'],
      quantity: map['quantity'] ?? 1,
      dateTime: DateTime.parse(map['dateTime']),
      notes: map['notes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MedicationEntry.fromJson(String source) =>
      MedicationEntry.fromMap(json.decode(source));
}
import 'dart:convert';

class AppointmentEntry {
  final String appointmentName;
  final String? location;
  final DateTime appointmentDateTime;
  final String? notes;
  final DateTime createdAt;

  AppointmentEntry({
    required this.appointmentName,
    this.location,
    required this.appointmentDateTime,
    this.notes,
    required this.createdAt,
  });

  String get status {
    final now = DateTime.now();
    if (appointmentDateTime.isAfter(now)) return 'upcoming';
    return 'past';
  }

  Map<String, dynamic> toMap() => {
    'appointmentName': appointmentName,
    'location': location,
    'appointmentDateTime': appointmentDateTime.toIso8601String(),
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppointmentEntry.fromMap(Map<String, dynamic> map) =>
      AppointmentEntry(
        appointmentName: map['appointmentName'],
        location: map['location'],
        appointmentDateTime: DateTime.parse(map['appointmentDateTime']),
        notes: map['notes'],
        createdAt: DateTime.parse(map['createdAt']),
      );

  String toJson() => json.encode(toMap());

  factory AppointmentEntry.fromJson(String source) =>
      AppointmentEntry.fromMap(json.decode(source));
}
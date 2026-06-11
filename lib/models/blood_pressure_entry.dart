import 'dart:convert';

class BloodPressureEntry {
  final int? serverId;
  final int systolic;
  final int diastolic;
  final int? heartRate;
  final DateTime dateTime;
  final String? notes;

  final bool isSynced;
  final String localId; // UUID generated client-side

  BloodPressureEntry({
    this.serverId,
    required this.systolic,
    required this.diastolic,
    this.heartRate,
    this.notes,
    required this.dateTime,
    required this.localId,
    this.isSynced = false,
  });

  BloodPressureEntry copyWith({
    int? serverId,
    int? systolic,
    int? diastolic,
    int? heartRate,
    String? notes,
    DateTime? dateTime,
    String? localId,
    bool? isSynced,
  }) =>
      BloodPressureEntry(
        serverId: serverId ?? this.serverId,
        systolic: systolic ?? this.systolic,
        diastolic: diastolic ?? this.diastolic,
        heartRate: heartRate ?? this.heartRate,
        notes: notes ?? this.notes,
        dateTime: dateTime ?? this.dateTime,
        localId: localId ?? this.localId,
        isSynced: isSynced ?? this.isSynced,
      );

  Map<String, dynamic> toMap() => {
    'serverId': serverId,
    'systolic': systolic,
    'diastolic': diastolic,
    'heartRate': heartRate,
    'dateTime': dateTime.toIso8601String(),
    'notes': notes,
    'localId': localId,
    'isSynced': isSynced,
  };

  Map<String, dynamic> toApiPayload() => {
    'type': 'blood_pressure',
    'data': {
      'systolic': systolic,
      'diastolic': diastolic,
      'notes': notes,
    },
  };

  factory BloodPressureEntry.fromMap(Map<String, dynamic> map) =>
      BloodPressureEntry(
        serverId: map['serverId'],
        systolic: map['systolic'],
        diastolic: map['diastolic'],
        heartRate: map['heartRate'],
        dateTime: DateTime.parse(map['dateTime']),
        notes: map['notes'],
        localId: map['localId'] ?? _fallbackId(map),
        isSynced: map['isSynced'] ?? false,
      );

  static String _fallbackId(Map<String, dynamic> map) =>
      '${map['dateTime']}_${map['systolic']}_${map['diastolic']}';

  String toJson() => json.encode(toMap());
  factory BloodPressureEntry.fromJson(String source) =>
      BloodPressureEntry.fromMap(json.decode(source));
}
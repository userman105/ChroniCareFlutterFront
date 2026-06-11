import 'dart:convert';
class GlucoseEntry {
  final int? serverId;       // GlucoseLevels.glucose_id
  final double value;        // glucose_level
  final String unit;         // 'mg/dL' | 'mmol/L'  (client-only display pref)
  final DateTime dateTime;   // measurement_time
  final String? notes;
  final String localId;
  final bool isSynced;

  GlucoseEntry({
    this.serverId,
    required this.value,
    required this.unit,
    required this.dateTime,
    this.notes,
    required this.localId,
    this.isSynced = false,
  });

  GlucoseEntry copyWith({
    int? serverId,
    double? value,
    String? unit,
    DateTime? dateTime,
    String? notes,
    String? localId,
    bool? isSynced,
  }) =>
      GlucoseEntry(
        serverId: serverId ?? this.serverId,
        value: value ?? this.value,
        unit: unit ?? this.unit,
        dateTime: dateTime ?? this.dateTime,
        notes: notes ?? this.notes,
        localId: localId ?? this.localId,
        isSynced: isSynced ?? this.isSynced,
      );

  double get valueInMgDl =>
      unit == 'mmol/L' ? value * 18.0182 : value;

  Map<String, dynamic> toApiPayload() => {
    'type': 'glucose',
    'data': {
      'glucose_level': valueInMgDl,
      'notes': notes,
    },
  };

  Map<String, dynamic> toMap() => {
    'serverId': serverId,
    'value': value,
    'unit': unit,
    'dateTime': dateTime.toIso8601String(),
    'notes': notes,
    'localId': localId,
    'isSynced': isSynced,
  };

  factory GlucoseEntry.fromMap(Map<String, dynamic> map) => GlucoseEntry(
    serverId: map['serverId'],
    value: (map['value'] as num).toDouble(),
    unit: map['unit'] ?? 'mg/dL',
    dateTime: DateTime.parse(map['dateTime']),
    notes: map['notes'],
    localId: map['localId'] ?? '${map['dateTime']}_${map['value']}',
    isSynced: map['isSynced'] ?? false,
  );

  String toJson() => json.encode(toMap());
  factory GlucoseEntry.fromJson(String source) =>
      GlucoseEntry.fromMap(json.decode(source));
}

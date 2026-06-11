import 'dart:convert';
class WeightEntry {
  final int? serverId;       // HealthMetrics.metric_id
  final double? kg;          // weight_kg
  final double? lbs;         // derived, display-only
  final double? heightCm;    // height_cm  (optional – can be sent once)
  final double? bmi;         // returned by server, stored locally
  final DateTime dateTime;   // recorded_date
  final String? notes;
  final String localId;
  final bool isSynced;

  WeightEntry({
    this.serverId,
    this.kg,
    this.lbs,
    this.heightCm,
    this.bmi,
    required this.dateTime,
    this.notes,
    required this.localId,
    this.isSynced = false,
  });

  WeightEntry copyWith({
    int? serverId,
    double? kg,
    double? lbs,
    double? heightCm,
    double? bmi,
    DateTime? dateTime,
    String? notes,
    String? localId,
    bool? isSynced,
  }) =>
      WeightEntry(
        serverId: serverId ?? this.serverId,
        kg: kg ?? this.kg,
        lbs: lbs ?? this.lbs,
        heightCm: heightCm ?? this.heightCm,
        bmi: bmi ?? this.bmi,
        dateTime: dateTime ?? this.dateTime,
        notes: notes ?? this.notes,
        localId: localId ?? this.localId,
        isSynced: isSynced ?? this.isSynced,
      );

  double? get kgValue => kg ?? (lbs != null ? lbs! / 2.20462 : null);

  Map<String, dynamic> toApiPayload() => {
    'type': 'health_metrics',
    'data': {
      'weight_kg': kgValue,
      if (heightCm != null) 'height_cm': heightCm,
      'notes': notes,
    },
  };

  Map<String, dynamic> toMap() => {
    'serverId': serverId,
    'kg': kg,
    'lbs': lbs,
    'heightCm': heightCm,
    'bmi': bmi,
    'dateTime': dateTime.toIso8601String(),
    'notes': notes,
    'localId': localId,
    'isSynced': isSynced,
  };

  factory WeightEntry.fromMap(Map<String, dynamic> map) => WeightEntry(
    serverId: map['serverId'],
    kg: map['kg'] != null ? (map['kg'] as num).toDouble() : null,
    lbs: map['lbs'] != null ? (map['lbs'] as num).toDouble() : null,
    heightCm:
    map['heightCm'] != null ? (map['heightCm'] as num).toDouble() : null,
    bmi: map['bmi'] != null ? (map['bmi'] as num).toDouble() : null,
    dateTime: DateTime.parse(map['dateTime']),
    notes: map['notes'],
    localId: map['localId'] ?? '${map['dateTime']}',
    isSynced: map['isSynced'] ?? false,
  );

  String toJson() => json.encode(toMap());
  factory WeightEntry.fromJson(String source) =>
      WeightEntry.fromMap(json.decode(source));
}
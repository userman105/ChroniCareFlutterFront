import 'dart:convert';

enum SyncOperationType { create, delete }
class OfflineQueueEntry {
  final String id;               // unique per queue entry, not per record
  final String modelType;        // 'blood_pressure' | 'glucose' | 'health_metrics' etc.
  final SyncOperationType operation;
  final Map<String, dynamic> payload; // the full API payload
  final String localRecordId;    // links back to the local model's localId
  final DateTime queuedAt;
  int retryCount;

  OfflineQueueEntry({
    required this.id,
    required this.modelType,
    required this.operation,
    required this.payload,
    required this.localRecordId,
    required this.queuedAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'modelType': modelType,
        'operation': operation.name,
        'payload': payload,
        'localRecordId': localRecordId,
        'queuedAt': queuedAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory OfflineQueueEntry.fromMap(Map<String, dynamic> map) =>
      OfflineQueueEntry(
        id: map['id'],
        modelType: map['modelType'],
        operation: SyncOperationType.values.byName(map['operation']),
        payload: Map<String, dynamic>.from(map['payload']),
        localRecordId: map['localRecordId'],
        queuedAt: DateTime.parse(map['queuedAt']),
        retryCount: map['retryCount'] ?? 0,
      );

  String toJson() => json.encode(toMap());
  factory OfflineQueueEntry.fromJson(String source) =>
      OfflineQueueEntry.fromMap(json.decode(source));
}

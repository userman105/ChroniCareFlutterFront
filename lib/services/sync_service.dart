import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../models/offline_queue_entry.dart';
import '../services/account_scoped_storage.dart';
import '../services/token_service.dart';
import '../services/api_client.dart';   // your existing Dio singleton

class SyncService {
  static const _queueKey = 'offline_sync_queue';
  static const int _maxRetries = 5;

  static final SyncService _instance = SyncService._();
  factory SyncService() => _instance;
  SyncService._();

  final Dio _dio = ApiClient.dio;
  final _uuid = const Uuid();

  final _statusController =
      StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatus => _statusController.stream;

  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  StreamSubscription? _connectivitySub;


  void init() {
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen(_onConnectivityChanged);
  }

  void dispose() {
    _connectivitySub?.cancel();
    _statusController.close();
  }

  Future<Map<String, dynamic>?> pushRecord({
    required String modelType,
    required Map<String, dynamic> apiPayload,
    required String localRecordId,
    String endpoint = '/api/user/log',
  }) async {
    final online = await _isOnline();

    if (online) {
      try {
        final result = await _postToServer(endpoint, apiPayload);
        return result;
      } on DioException catch (e) {
        if (_isTransient(e)) {
          await _enqueue(modelType, apiPayload, localRecordId, endpoint);
          return null;
        }
        rethrow; // permanent error (400, 401 etc.) – caller handles it
      }
    } else {
      await _enqueue(modelType, apiPayload, localRecordId, endpoint);
      return null;
    }
  }

  Future<void> drainQueue() async {
    final queue = await _loadQueue();
    if (queue.isEmpty) return;

    _emit(SyncStatus.syncing);

    final remaining = <OfflineQueueEntry>[];

    for (final entry in queue) {
      try {
        await _postToServer(entry.payload['_endpoint'] as String? ?? '/api/user/log',
            entry.payload);
      } on DioException catch (e) {
        entry.retryCount++;
        if (!_isTransient(e) || entry.retryCount >= _maxRetries) {
          _logFailure(entry, e);
        } else {
          remaining.add(entry);
        }
      } catch (_) {
        entry.retryCount++;
        if (entry.retryCount < _maxRetries) remaining.add(entry);
      }
    }

    await _saveQueue(remaining);
    _emit(remaining.isEmpty ? SyncStatus.idle : SyncStatus.pendingItems);
  }

  Future<int> pendingCount() async {
    final q = await _loadQueue();
    return q.length;
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    if (hasConnection) {
      drainQueue();
    } else {
      _emit(SyncStatus.offline);
    }
  }

  Future<List<OfflineQueueEntry>> _loadQueue() async {
    try {
      final store = await AccountScopedStorage.forCurrentUser();
      final raw = store.getStringList(_queueKey) ?? [];
      return raw.map((e) => OfflineQueueEntry.fromJson(e)).toList();
    } catch (_) {
      return []; // no active user yet
    }
  }

  Future<void> _saveQueue(List<OfflineQueueEntry> queue) async {
    try {
      final store = await AccountScopedStorage.forCurrentUser();
      await store.setStringList(
        _queueKey,
        queue.map((e) => e.toJson()).toList(),
      );
    } catch (_) {}
  }

  Future<void> _enqueue(
    String modelType,
    Map<String, dynamic> payload,
    String localRecordId,
    String endpoint,
  ) async {
    final queue = await _loadQueue();
    // Stamp the endpoint in the payload map so drainQueue can use it
    final enrichedPayload = Map<String, dynamic>.from(payload)
      ..['_endpoint'] = endpoint;

    queue.add(OfflineQueueEntry(
      id: _uuid.v4(),
      modelType: modelType,
      operation: SyncOperationType.create,
      payload: enrichedPayload,
      localRecordId: localRecordId,
      queuedAt: DateTime.now(),
    ));
    await _saveQueue(queue);
    _emit(SyncStatus.pendingItems);
  }


  Future<Map<String, dynamic>> _postToServer(
      String endpoint, Map<String, dynamic> payload) async {
    // Strip the internal _endpoint marker before sending
    final body = Map<String, dynamic>.from(payload)..remove('_endpoint');
    final response = await _dio.post(endpoint, data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool _isTransient(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return true;
    }
    final status = e.response?.statusCode;
    return status == null || status >= 500;
  }

  void _emit(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  void _logFailure(OfflineQueueEntry entry, Object error) {
    print('[SyncService] Permanently failed entry ${entry.id}: $error');
  }
}

enum SyncStatus {
  idle,
  syncing,
  pendingItems,
  offline,
}

import 'dart:async';
import 'package:dio/dio.dart';
import '../services/api_client.dart';

enum BackendStatus { connected, disconnected, checking }

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;
  ConnectivityService._();

  final _controller = StreamController<BackendStatus>.broadcast();
  Stream<BackendStatus> get status => _controller.stream;

  BackendStatus _current = BackendStatus.checking;
  BackendStatus get current => _current;

  Timer? _timer;

  void startPolling({Duration interval = const Duration(seconds: 15)}) {
    _check();
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _check());
  }

  void stopPolling() => _timer?.cancel();

  Future<void> _check() async {
    try {
      final baseUrl = ApiClient.dio.options.baseUrl
          .replaceAll(RegExp(r'/api/?$'), '');

      final response = await Dio().get(
        '$baseUrl/health',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      _emit(response.statusCode == 200
          ? BackendStatus.connected
          : BackendStatus.disconnected);
    } catch (_) {
      _emit(BackendStatus.disconnected);
    }
  }

  void _emit(BackendStatus s) {
    _current = s;
    _controller.add(s);
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
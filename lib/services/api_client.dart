import 'package:dio/dio.dart';
import 'token_service.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:3000/api",
       //baseUrl: "https://581d-41-34-187-18.ngrok-free.app/api",
      headers: {"Content-Type": "application/json"},
    ),
  );

  // Separate Dio without interceptors, to avoid infinite loops on refresh calls
  static final Dio _refreshDio = Dio(
   BaseOptions(baseUrl: "http://10.0.2.2:3000/api"),
    // BaseOptions(baseUrl: "https://581d-41-34-187-18.ngrok-free.app/api"),
  );

  static bool _isRefreshing = false;

  static void init() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final isAuthError = error.response?.statusCode == 401;
          final isGuest =
              (await TokenStorage.getAccessToken()) == 'guest_access_token';

          if (isAuthError && !isGuest && !_isRefreshing) {
            _isRefreshing = true;
            try {
              final refreshToken = await TokenStorage.getRefreshToken();
              if (refreshToken == null) {
                _isRefreshing = false;
                return handler.next(error);
              }

              final res = await _refreshDio.post('/auth/refresh-token', data: {
                'refresh_token': refreshToken,
              });

              final newAccessToken = res.data['access_token'] as String;
              await TokenStorage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: refreshToken, // unchanged
              );

              _isRefreshing = false;

              final retryOptions = error.requestOptions;
              retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

              final retryResponse = await dio.fetch(retryOptions);
              return handler.resolve(retryResponse);
            } catch (_) {
              _isRefreshing = false;
              return handler.next(error);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }
}
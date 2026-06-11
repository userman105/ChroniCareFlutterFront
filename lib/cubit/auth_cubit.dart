import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_client.dart';
import '../services/account_scoped_storage.dart';
import '../services/sync_service.dart';
import '../services/token_service.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}

class AuthOtpSent extends AuthState {
  final String email;
  AuthOtpSent(this.email);
}

class AuthNeedsVerification extends AuthState {
  final String email;
  AuthNeedsVerification(this.email);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}


class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final Dio _dio = ApiClient.dio;

  // Callback set by the widget tree so AuthCubit can trigger a HealthCubit
  // reload without a hard dependency on it.
  Future<void> Function()? onUserSwitched;


  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String gender,
    required String dateOfBirth,
  }) async {
    emit(AuthLoading());
    try {
      final names = fullName.trim().split(' ');
      final res = await _dio.post('/auth/register', data: {
        'first_name': names.first,
        'last_name': names.length > 1 ? names.sublist(1).join(' ') : '',
        'email': email,
        'password': password,
        'gender': gender,
        'date_of_birth': dateOfBirth,
      });

      if (res.statusCode == 201) {
        // Store profile data globally (not yet user-scoped – user not logged in)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_email', email);
        await prefs.setString('pending_name', fullName);
        emit(AuthOtpSent(email));
      } else {
        emit(AuthError(_msg(res.data)));
      }
    } on DioException catch (e) {
      emit(AuthError(_dioMsg(e)));
    } on TimeoutException {
      emit(AuthError('Request timed out'));
    } catch (_) {
      emit(AuthError('Unexpected error occurred'));
    }
  }


  Future<void> verifyOtp({required String email, required String otp}) async {
    emit(AuthLoading());
    try {
      final res = await _dio.post('/auth/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      if (res.statusCode == 200) {
        emit(AuthSuccess());
      } else {
        emit(AuthError(_msg(res.data)));
      }
    } on DioException catch (e) {
      emit(AuthError(_dioMsg(e)));
    } catch (_) {
      emit(AuthError('Unexpected error occurred'));
    }
  }

  Future<void> resendOtp(String email) async {
    emit(AuthLoading());
    try {
      await _dio.post('/auth/resend-otp', data: {'email': email});
      emit(AuthOtpSent(email));
    } on DioException catch (e) {
      emit(AuthError(_dioMsg(e)));
    } catch (_) {
      emit(AuthError('Failed to resend OTP'));
    }
  }


  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      if (email == 'guest' && password == 'guest') {
        await TokenStorage.saveTokens(
          accessToken: 'guest_access_token',
          refreshToken: 'guest_refresh_token',
        );

        // Use a stable guest user id so the namespace is consistent
        const guestUid = 'guest';
        await AccountScopedStorage.setActiveUser(guestUid);

        final store = await AccountScopedStorage.forCurrentUser();
        await store.setString('name', 'Guest User');
        await store.setString('email', 'guest@local');
        await store.setString('gender', 'N/A');
        await store.setString('birthday', '-- / -- / ----');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setBool('is_guest', true);

        SyncService().init();
        await onUserSwitched?.call();
        emit(AuthSuccess());
        return;
      }

      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      await TokenStorage.saveTokens(
        accessToken: res.data['access_token'],
        refreshToken: res.data['refresh_token'],
      );

      final user = res.data['user'] as Map<String, dynamic>;
      final userId = (res.data['user_id'] ?? user['user_id']).toString();

      // !! Critical: set the active user BEFORE touching scoped storage !!
      await AccountScopedStorage.setActiveUser(userId);

      // Save profile into the user-scoped namespace
      final store = await AccountScopedStorage.forCurrentUser();
      await store.setString(
          'name', '${user['first_name']} ${user['last_name']}');
      await store.setString('email', user['email'] as String);
      await store.setString(
          'gender', user['gender'] == true ? 'Male' : 'Female');

      if (user['date_of_birth'] != null) {
        final dob = DateTime.parse(user['date_of_birth'] as String);
        await store.setString(
          'birthday',
          '${dob.month.toString().padLeft(2, '0')} / '
              '${dob.day.toString().padLeft(2, '0')} / '
              '${dob.year}',
        );
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('is_guest', false);

      // Restart sync service and reload health data for this user
      SyncService().init();
      await onUserSwitched?.call();

      emit(AuthSuccess());
    } on DioException catch (e) {
      final data = e.response?.data;
      if (e.response?.statusCode == 403 &&
          data is Map &&
          data['message'] == 'Account not activated') {
        emit(AuthNeedsVerification(data['email'] as String));
        return;
      }
      emit(AuthError(_dioMsg(e)));
    } catch (_) {
      emit(AuthError('Login failed'));
    }
  }


  Future<void> logout({bool clearData = false}) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      final isGuest = prefs.getBool('is_guest') ?? false;
      if (!isGuest && refreshToken != null) {
        await _dio.post('/auth/logout', data: {'refresh_token': refreshToken});
      }
    } catch (e) {
      // Logout API failure is non-fatal
    }

    await TokenStorage.clear();

    if (clearData) {
      // Wipe all cached entries for this account
      await AccountScopedStorage.clearCurrentUserData();
    } else {
      // Just remove the session pointer; cache stays for re-login
      await AccountScopedStorage.clearSession();
    }

    await prefs.remove('is_logged_in');
    await prefs.remove('is_guest');

    emit(AuthInitial());
  }


  /// Reads profile fields from the current user's scoped store.
  Future<Map<String, String?>> getProfile() async {
    try {
      final store = await AccountScopedStorage.forCurrentUser();
      return {
        'name': store.getString('name'),
        'email': store.getString('email'),
        'gender': store.getString('gender'),
        'birthday': store.getString('birthday'),
      };
    } catch (_) {
      return {};
    }
  }


  String _msg(dynamic data) {
    if (data == null) return 'Unknown error';
    if (data is Map && data['message'] != null) return data['message'].toString();
    return data.toString();
  }

  String _dioMsg(DioException e) =>
      _msg(e.response?.data ?? e.message ?? 'Network error');



  Future<void> migrateOldDataIfNeeded(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    const migrationFlag = '__data_migrated_v2__';
    if (prefs.getBool(migrationFlag) == true) return;

    final oldKeys = [
      'blood_pressure_entries', 'weight_entries', 'glucose_entries',
      'medication_entries', 'symptom_entries', 'food_entries',
      'reminder_entries', 'lab_test_entries', 'appointments', 'health_tiles',
    ];

    await AccountScopedStorage.setActiveUser(userId);
    final store = await AccountScopedStorage.forCurrentUser();

    for (final key in oldKeys) {
      final data = prefs.getStringList(key);
      if (data != null && data.isNotEmpty) {
        await store.setStringList(key, data);
        await prefs.remove(key); // clean up old key
      }
    }

    await prefs.setBool(migrationFlag, true);
  }
}
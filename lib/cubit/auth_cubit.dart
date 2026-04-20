import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:chronic_care/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/token_service.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}

class AuthOtpSent extends AuthState {
  final String email;
  AuthOtpSent(this.email);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final Dio dio = ApiClient.dio;



  String _extractMessage(dynamic data) {
    if (data == null) return "Unknown error";

    if (data is Map && data["message"] != null) {
      return data["message"].toString();
    }

    if (data is String) {
      return data;
    }

    return data.toString();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String gender,
    required String dateOfBirth,
  }) async {
    emit(AuthLoading());

    try {
      final names = fullName.trim().split(" ");
      final firstName = names.first;
      final lastName =
      names.length > 1 ? names.sublist(1).join(" ") : "";

      final res = await dio.post(
        "/auth/register",
        data: {
          "first_name": firstName,
          "last_name": lastName,
          "email": email,
          "password": password,
          "gender": gender,
          "date_of_birth": dateOfBirth,
        },
      );

      if (res.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("email", email);
        await prefs.setString("name", fullName);
        await prefs.setString("gender", gender);
        await prefs.setString("dob", dateOfBirth);

        emit(AuthOtpSent(email));
      } else {
        emit(AuthError(_extractMessage(res.data)));
      }
    } on DioException catch (e) {
      emit(AuthError(_extractMessage(e.response?.data ?? e.message)));
    } on TimeoutException {
      emit(AuthError("Request timed out"));
    } catch (e) {
      emit(AuthError("Unexpected error occurred"));
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    emit(AuthLoading());

    try {
      final res = await dio.post(
        "/auth/verify-otp",
        data: {
          "email": email,
          "otp": otp,
        },
      );

      print("VERIFY OTP RESPONSE: ${res.data}");

      if (res.statusCode == 200) {
        emit(AuthSuccess());
      } else {
        emit(AuthError(_extractMessage(res.data)));
      }
    } on DioException catch (e) {
      print("DIO ERROR VERIFY OTP:");
      print(e.message);
      print(e.response?.data);
      print(e.response?.statusCode);

      emit(AuthError(_extractMessage(e.response?.data ?? e.message)));
    } catch (e) {
      print("UNKNOWN ERROR: $e");
      emit(AuthError("Unexpected error occurred"));
    }
  }

  Future<void> resendOtp(String email) async {
    emit(AuthLoading());

    try {
      await dio.post(
        "/auth/resend-otp",
        data: {"email": email},
      );

      emit(AuthOtpSent(email));
    } on DioException catch (e) {
      emit(AuthError(_extractMessage(e.response?.data ?? e.message)));
    } catch (_) {
      emit(AuthError("Failed to resend OTP"));
    }
  }

  Future<void> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    emit(AuthLoading());

    try {
      /// GUEST MODE (OFFLINE)

      if (email == "guest" && password == "guest") {
        await TokenStorage.saveTokens(
          accessToken: "guest_access_token",
          refreshToken: "guest_refresh_token",
        );

        await prefs.setString("name", "Guest User");
        await prefs.setString("email", "guest@local");
        await prefs.setString("gender", "N/A");
        await prefs.setString("birthday", "-- / -- / ----");

        await prefs.setBool("is_logged_in", true);
        await prefs.setBool("is_guest", true);

        emit(AuthSuccess());
        return; // 🚨 VERY IMPORTANT (prevents API call)
      }

      final res = await dio.post(
        "/auth/login",
        data: {
          "email": email,
          "password": password,
        },
      );

      await TokenStorage.saveTokens(
        accessToken: res.data["access_token"],
        refreshToken: res.data["refresh_token"],
      );

      final user = res.data["user"];

      await prefs.setString(
        "name",
        "${user["first_name"]} ${user["last_name"]}",
      );

      await prefs.setString("email", user["email"]);

      await prefs.setString(
        "gender",
        user["gender"] == true ? "Male" : "Female",
      );

      if (user["date_of_birth"] != null) {
        final dob = DateTime.parse(user["date_of_birth"]);
        final formatted =
            "${dob.month.toString().padLeft(2, '0')} / "
            "${dob.day.toString().padLeft(2, '0')} / "
            "${dob.year}";

        await prefs.setString("birthday", formatted);
      }

      /// flags
      await prefs.setBool("is_logged_in", true);
      await prefs.setBool("is_guest", false);

      emit(AuthSuccess());

    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? e.response?.data["message"]
          : e.message;

      emit(AuthError(msg ?? "Network error"));
    } catch (_) {
      emit(AuthError("Login failed"));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final refreshToken = await TokenStorage.getRefreshToken();

      if ((prefs.getBool("is_guest") ?? false) == false &&
          refreshToken != null) {
        await dio.post(
          "/auth/logout",
          data: {
            "refresh_token": refreshToken,
          },
        );
      }
    } catch (e) {
      print("Logout API failed: $e");

    }


    await TokenStorage.clear();
    await prefs.clear();

    emit(AuthInitial());
  }
}
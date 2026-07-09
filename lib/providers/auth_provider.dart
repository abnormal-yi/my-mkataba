import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_mkataba/core/constants.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/core/api_client.dart';

final _storage = const FlutterSecureStorage();
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final String? token;
  final bool isChecking;

  const AuthState({this.user, this.isLoading = false, this.error, this.token, this.isChecking = true});

  AuthState copyWith({User? user, bool? isLoading, String? error, String? token, bool? isChecking}) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        token: token ?? this.token,
        isChecking: isChecking ?? this.isChecking,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> checkAuth() async {
    state = state.copyWith(isChecking: true);
    try {
      final token = await _storage.read(key: AppConstants.jwtStorageKey);
      final userData = await _storage.read(key: AppConstants.userStorageKey);
      if (token != null && userData != null) {
        final user = User.fromJson(jsonDecode(userData) as Map<String, dynamic>);
        state = AuthState(user: user, token: token, isChecking: false);
      } else {
        state = const AuthState(isChecking: false);
      }
    } catch (_) {
      state = const AuthState(isChecking: false);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = buildApiClient();
      final res = await dio.post('/auth/login', data: {'email': email, 'password': password});
      final token = res.data['token'] as String;
      final user = User.fromJson(res.data['user']);
      await _storage.write(key: AppConstants.jwtStorageKey, value: token);
      await _storage.write(key: AppConstants.roleStorageKey, value: user.role.name);
      await _storage.write(key: AppConstants.userStorageKey, value: jsonEncode(user.toJson()));
      state = AuthState(user: user, token: token, isChecking: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setUser(User user, String token) {
    state = AuthState(user: user, token: token, isChecking: false);
  }

  Future<void> updateUser(User updated) async {
    await _storage.write(key: AppConstants.userStorageKey, value: jsonEncode(updated.toJson()));
    state = AuthState(user: updated, token: state.token, isChecking: false);
  }

  Future<String?> uploadProfilePhoto(String filePath) async {
    try {
      final dio = buildApiClient();
      final formData = FormData.fromMap({'photo': await MultipartFile.fromFile(filePath)});
      final res = await dio.post('/auth/upload-photo', data: formData);
      final url = res.data['photo_url'] as String;
      final updated = state.user!.copyWith(photoUrl: url);
      await updateUser(updated);
      return url;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.jwtStorageKey);
    await _storage.delete(key: AppConstants.roleStorageKey);
    await _storage.delete(key: AppConstants.userStorageKey);
    state = const AuthState(isChecking: false);
  }
}

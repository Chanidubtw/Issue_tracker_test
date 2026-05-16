import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _api;
  final SharedPreferences _prefs;

  const AuthRepositoryImpl(this._api, this._prefs);

  @override
  Future<User> login(String email, String password) async {
    final data = await _api.login(email, password);
    final token = data['token'] as String;
    await _prefs.setString(AppConstants.prefAuthTokenKey, token);
    await _prefs.setString(AppConstants.prefUserEmailKey, email);
    return User(email: email, token: token);
  }

  @override
  Future<void> logout() async {
    await _prefs.remove(AppConstants.prefAuthTokenKey);
    await _prefs.remove(AppConstants.prefUserEmailKey);
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = _prefs.getString(AppConstants.prefAuthTokenKey);
    final email = _prefs.getString(AppConstants.prefUserEmailKey);
    if (token == null || email == null) return null;
    return User(email: email, token: token);
  }
}

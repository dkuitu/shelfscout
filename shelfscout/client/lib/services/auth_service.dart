import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  Future<({User user, String token})> register(
      String email, String username, String password) async {
    final res = await _api.post('/auth/register', data: {
      'email': email,
      'username': username,
      'password': password,
    });
    final data = res.data as Map<String, dynamic>;
    final token = data['token'] as String;
    await _saveToken(token);
    return (user: User.fromJson(data['user']), token: token);
  }

  Future<({User user, String token})> login(
      String email, String password) async {
    final res = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = res.data as Map<String, dynamic>;
    final token = data['token'] as String;
    await _saveToken(token);
    return (user: User.fromJson(data['user']), token: token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
}

import '../models/badge.dart';
import '../models/user.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _api;

  UserService(this._api);

  Future<User> getProfile() async {
    final res = await _api.get('/users/profile');
    final data = res.data as Map<String, dynamic>;
    return User.fromJson(data['profile'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getStats() async {
    final res = await _api.get('/users/stats');
    final data = res.data as Map<String, dynamic>;
    return data['stats'] as Map<String, dynamic>;
  }

  Future<List<Badge>> getBadges() async {
    final res = await _api.get('/users/badges');
    final data = res.data as Map<String, dynamic>;
    final list = data['badges'] as List<dynamic>;
    return list
        .map((j) => Badge.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}

import '../models/crown.dart';
import 'api_client.dart';

class CrownService {
  final ApiClient _api;

  CrownService(this._api);

  Future<List<Crown>> getRegionCrowns(String regionId) async {
    final res = await _api.get('/crowns/region/$regionId');
    final data = res.data as Map<String, dynamic>;
    final list = data['crowns'] as List<dynamic>;
    return list
        .map((j) => Crown.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<Crown>> getUserCrowns() async {
    final res = await _api.get('/crowns/mine');
    final data = res.data as Map<String, dynamic>;
    final list = data['crowns'] as List<dynamic>;
    return list
        .map((j) => Crown.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getCrownHistory(String crownId) async {
    final res = await _api.get('/crowns/history/$crownId');
    return res.data as Map<String, dynamic>;
  }
}

import '../models/store.dart';
import 'api_client.dart';

class StoreService {
  final ApiClient _api;

  StoreService(this._api);

  Future<List<Store>> getNearbyStores(double lat, double lng,
      {int radius = 5000}) async {
    final res = await _api.get('/stores/nearby', queryParameters: {
      'lat': lat,
      'lng': lng,
      'radius': radius,
    });
    final data = res.data as Map<String, dynamic>;
    final list = data['stores'] as List<dynamic>;
    return list
        .map((j) => Store.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<Store> getStore(String id) async {
    final res = await _api.get('/stores/$id');
    final data = res.data as Map<String, dynamic>;
    return Store.fromJson(data['store'] as Map<String, dynamic>);
  }

  Future<Store> suggestStore(
      String name, String address, double lat, double lng,
      {String? chain}) async {
    final res = await _api.post('/stores/suggest', data: {
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      if (chain != null) 'chain': chain,
    });
    final data = res.data as Map<String, dynamic>;
    return Store.fromJson(data['store'] as Map<String, dynamic>);
  }
}

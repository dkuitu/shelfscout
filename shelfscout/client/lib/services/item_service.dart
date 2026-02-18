import '../models/item.dart';
import 'api_client.dart';

class ItemService {
  final ApiClient _api;

  ItemService(this._api);

  Future<List<Item>> getWeeklyItems() async {
    final res = await _api.get('/items/weekly');
    final data = res.data as Map<String, dynamic>;
    final list = data['items'] as List<dynamic>;
    return list
        .map((j) => Item.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<Item>> searchItems({String? query, String? categoryId}) async {
    final params = <String, dynamic>{};
    if (query != null && query.isNotEmpty) params['q'] = query;
    if (categoryId != null) params['category_id'] = categoryId;
    final res = await _api.get('/items/search', queryParameters: params);
    final data = res.data as Map<String, dynamic>;
    final list = data['items'] as List<dynamic>;
    return list
        .map((j) => Item.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<Item> createItem({
    required String name,
    required String categoryId,
    required String unit,
  }) async {
    final res = await _api.post('/items', data: {
      'name': name,
      'category_id': categoryId,
      'unit': unit,
    });
    final data = res.data as Map<String, dynamic>;
    return Item.fromJson(data['item'] as Map<String, dynamic>);
  }

  Future<List<Item>> getPendingItems() async {
    final res = await _api.get('/items/pending');
    final data = res.data as Map<String, dynamic>;
    final list = data['items'] as List<dynamic>;
    return list
        .map((j) => Item.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> voteOnItem(String itemId, String vote) async {
    final res = await _api.post('/items/$itemId/vote', data: {'vote': vote});
    return res.data as Map<String, dynamic>;
  }
}

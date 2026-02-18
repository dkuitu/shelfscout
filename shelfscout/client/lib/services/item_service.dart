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
}

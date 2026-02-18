import '../models/category.dart';
import 'api_client.dart';

class CategoryService {
  final ApiClient _api;

  CategoryService(this._api);

  Future<List<Category>> getAll() async {
    final res = await _api.get('/categories');
    final data = res.data as Map<String, dynamic>;
    final list = data['categories'] as List<dynamic>;
    return list
        .map((j) => Category.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}

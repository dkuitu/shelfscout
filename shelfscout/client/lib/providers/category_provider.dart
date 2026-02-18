import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/category.dart' as models;
import '../services/api_client.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService;

  List<models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoryProvider(ApiClient api) : _categoryService = CategoryService(api);

  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    if (_categories.isNotEmpty) return; // already cached
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await _categoryService.getAll();
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.message ?? 'Failed to load categories';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}

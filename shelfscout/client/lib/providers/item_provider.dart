import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/item.dart';
import '../services/api_client.dart';
import '../services/item_service.dart';

class ItemProvider extends ChangeNotifier {
  final ItemService _itemService;

  List<Item> _weeklyItems = [];
  List<Item> _searchResults = [];
  List<Item> _pendingItems = [];
  Item? _selectedItem;
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  ItemProvider(ApiClient api) : _itemService = ItemService(api);

  List<Item> get weeklyItems => _weeklyItems;
  List<Item> get searchResults => _searchResults;
  List<Item> get pendingItems => _pendingItems;
  Item? get selectedItem => _selectedItem;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;

  Future<void> loadWeeklyItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _weeklyItems = await _itemService.getWeeklyItems();
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.message ?? 'Failed to load weekly items';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectItem(Item? item) {
    _selectedItem = item;
    notifyListeners();
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
    searchItems();
  }

  Future<void> searchItems({String? query}) async {
    if (query != null) _searchQuery = query;
    _isSearching = true;
    notifyListeners();
    try {
      _searchResults = await _itemService.searchItems(
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        categoryId: _selectedCategoryId,
      );
      _isSearching = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.message ?? 'Search failed';
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<Item?> createItem({
    required String name,
    required String categoryId,
    required String unit,
  }) async {
    _error = null;
    try {
      final item = await _itemService.createItem(
        name: name,
        categoryId: categoryId,
        unit: unit,
      );
      return item;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('error')) {
        _error = data['error'] as String;
      } else {
        _error = e.message ?? 'Failed to create item';
      }
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> loadPendingItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _pendingItems = await _itemService.getPendingItems();
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.message ?? 'Failed to load pending items';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> voteOnItem(String itemId, String vote) async {
    try {
      await _itemService.voteOnItem(itemId, vote);
      _pendingItems.removeWhere((i) => i.id == itemId);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('error')) {
        _error = data['error'] as String;
      } else {
        _error = e.message ?? 'Vote failed';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

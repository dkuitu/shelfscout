import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/item.dart';
import '../services/api_client.dart';
import '../services/item_service.dart';

class ItemProvider extends ChangeNotifier {
  final ItemService _itemService;

  List<Item> _weeklyItems = [];
  Item? _selectedItem;
  bool _isLoading = false;
  String? _error;

  ItemProvider(ApiClient api) : _itemService = ItemService(api);

  List<Item> get weeklyItems => _weeklyItems;
  Item? get selectedItem => _selectedItem;
  bool get isLoading => _isLoading;
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
}

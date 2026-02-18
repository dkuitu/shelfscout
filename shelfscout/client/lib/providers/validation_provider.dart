import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/validation.dart';
import '../services/api_client.dart';
import '../services/validation_service.dart';

class ValidationProvider extends ChangeNotifier {
  final ValidationService _validationService;

  List<ValidationItem> _queue = [];
  bool _isLoading = false;
  String? _error;

  ValidationProvider(ApiClient api)
      : _validationService = ValidationService(api);

  List<ValidationItem> get queue => _queue;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadQueue() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _queue = await _validationService.getValidationQueue();
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.message ?? 'Failed to load validation queue';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitVote(String submissionId, ValidationVote vote,
      {String? reason}) async {
    _error = null;
    try {
      final voteStr = vote == ValidationVote.confirm ? 'confirm' : 'flag';
      await _validationService.submitValidation(submissionId, voteStr,
          reason: reason);
      _queue.removeWhere((item) => item.id == submissionId);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('error')) {
        _error = data['error'] as String;
      } else {
        _error = e.message ?? 'Failed to submit vote';
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

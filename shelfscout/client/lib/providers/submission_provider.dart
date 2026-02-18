import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/submission.dart';
import '../services/api_client.dart';
import '../services/submission_service.dart';

class SubmissionProvider extends ChangeNotifier {
  final SubmissionService _submissionService;

  List<Submission> _userSubmissions = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  SubmissionProvider(ApiClient api)
      : _submissionService = SubmissionService(api);

  List<Submission> get userSubmissions => _userSubmissions;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<bool> submitPrice({
    required String storeId,
    required String itemId,
    required double price,
    required String photoUrl,
    required double gpsLat,
    required double gpsLng,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      await _submissionService.createSubmission(
        storeId: storeId,
        itemId: itemId,
        price: price,
        photoUrl: photoUrl,
        gpsLat: gpsLat,
        gpsLng: gpsLng,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('error')) {
        _error = data['error'] as String;
      } else {
        _error = e.message ?? 'Failed to submit price';
      }
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUserSubmissions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _userSubmissions = await _submissionService.getUserSubmissions();
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.message ?? 'Failed to load submissions';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}

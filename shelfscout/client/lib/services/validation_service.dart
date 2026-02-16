import '../models/validation.dart';
import 'api_client.dart';

class ValidationService {
  final ApiClient _api;

  ValidationService(this._api);

  Future<List<ValidationItem>> getValidationQueue() async {
    final res = await _api.get('/validation/queue');
    final data = res.data as Map<String, dynamic>;
    final list = data['submissions'] as List<dynamic>;
    return list
        .map((j) => ValidationItem.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> submitValidation(
      String submissionId, String vote,
      {String? reason}) async {
    final res = await _api.post('/validation/$submissionId', data: {
      'vote': vote,
      if (reason != null) 'reason': reason,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getValidationStats() async {
    final res = await _api.get('/validation/stats');
    final data = res.data as Map<String, dynamic>;
    return data['stats'] as Map<String, dynamic>;
  }
}

import '../models/submission.dart';
import 'api_client.dart';

class SubmissionService {
  final ApiClient _api;

  SubmissionService(this._api);

  Future<Submission> createSubmission({
    required String storeId,
    required String itemId,
    required double price,
    String? photoUrl,
    required double gpsLat,
    required double gpsLng,
  }) async {
    final payload = <String, dynamic>{
      'store_id': storeId,
      'item_id': itemId,
      'price': price,
      'gps_lat': gpsLat,
      'gps_lng': gpsLng,
    };
    if (photoUrl != null && photoUrl.isNotEmpty) {
      payload['photo_url'] = photoUrl;
    }
    final res = await _api.post('/submissions', data: payload);
    final data = res.data as Map<String, dynamic>;
    return Submission.fromJson(data['submission'] as Map<String, dynamic>);
  }

  Future<List<Submission>> getUserSubmissions() async {
    final res = await _api.get('/submissions/mine');
    final data = res.data as Map<String, dynamic>;
    final list = data['submissions'] as List<dynamic>;
    return list
        .map((j) => Submission.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<Submission>> getStoreSubmissions(String storeId) async {
    final res = await _api.get('/submissions/store/$storeId');
    final data = res.data as Map<String, dynamic>;
    final list = data['submissions'] as List<dynamic>;
    return list
        .map((j) => Submission.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}

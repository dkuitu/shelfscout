import '../models/submission.dart';
import 'api_client.dart';

class SubmissionService {
  final ApiClient _api;

  SubmissionService(this._api);

  Future<Submission> createSubmission({
    required String storeId,
    required String itemId,
    required double price,
    required String photoUrl,
    required double gpsLat,
    required double gpsLng,
  }) async {
    final res = await _api.post('/submissions', data: {
      'store_id': storeId,
      'item_id': itemId,
      'price': price,
      'photo_url': photoUrl,
      'gps_lat': gpsLat,
      'gps_lng': gpsLng,
    });
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

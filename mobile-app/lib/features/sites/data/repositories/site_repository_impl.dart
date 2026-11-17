import '../../../../core/network/api_client.dart';
import '../../../../models/models.dart';
import '../../domain/repositories/site_repository.dart';

class SiteRepositoryImpl implements ISiteRepository {
  final IApiClient _apiClient;

  SiteRepositoryImpl({required IApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<Site>> getSites() async {
    final response = await _apiClient.get('/api/v1/sites');
    if (response is List) {
      return response.map((e) => Site.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Invalid server response for sites endpoint');
  }
}

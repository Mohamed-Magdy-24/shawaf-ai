import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/ws_client.dart';
import '../../../../models/models.dart';
import '../../domain/repositories/alert_repository.dart';

class AlertRepositoryImpl implements IAlertRepository {
  final IApiClient _apiClient;

  AlertRepositoryImpl({
    required IApiClient apiClient,
    IWsClient? wsClient,
  })  : _apiClient = apiClient;

  @override
  Future<List<SurveillanceEvent>> getAlertsInbox(String siteId) async {
    final response = await _apiClient.get('/api/v1/sites/$siteId/alerts');
    if (response is List) {
      return response
          .map((e) => SurveillanceEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (response is Map<String, dynamic>) {
      final list = (response['data'] ?? response['events'] ?? response['alerts']) as List? ?? [];
      return list
          .map((e) => SurveillanceEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<bool> executeAlertAction(
    String siteId,
    String eventId,
    String action,
    String note,
  ) async {
    final cleanAction = action.trim().toUpperCase();
    final cleanNote = note.trim();

    if (cleanAction == 'DISMISS' && cleanNote.length < 10) {
      throw ArgumentError('Audit note must be at least 10 characters for DISMISS action');
    }

    final response = await _apiClient.post(
      '/api/v1/sites/$siteId/alerts/$eventId/actions',
      body: {
        'action': cleanAction,
        'note': cleanNote,
      },
    );
    return response != null;
  }

  @override
  WebSocketChannel? connectWebSocket(
    String siteId,
    Function(SurveillanceEvent) onEvent,
  ) {
    // Falls back or delegates to ws client
    return null;
  }
}

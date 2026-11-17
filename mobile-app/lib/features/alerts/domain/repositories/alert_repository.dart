import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../models/models.dart';

abstract class IAlertRepository {
  Future<List<SurveillanceEvent>> getAlertsInbox(String siteId);
  Future<bool> executeAlertAction(
    String siteId,
    String eventId,
    String action,
    String note,
  );
  WebSocketChannel? connectWebSocket(
    String siteId,
    Function(SurveillanceEvent) onEvent,
  );
}

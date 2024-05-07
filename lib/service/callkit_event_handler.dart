import 'package:flutter_application_2/service/notification_service.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

class CallkitEventHandler {
  static void registerEvent({bool isBackground = false}) {
    /// Xử lý event khi có một thông báo callkit tới
    FlutterCallkitIncoming.onEvent.listen((event) async {
      switch (event!.event) {
        case Event.actionCallAccept:
          print('Event.actionCallAccept ${event.body['extra']}');
          if (!isBackground) {
            onHandleIncomingEvent(event.body['extra']);
            await FlutterCallkitIncoming.endAllCalls();
          }
          break;
        case Event.actionCallDecline:
          onHandleDeclineCallEvent(event);
          await FlutterCallkitIncoming.endAllCalls();
          break;
        case Event.actionCallEnded:
          await FlutterCallkitIncoming.endAllCalls();
          break;
        case Event.actionCallTimeout:
          onHandleDeclineCallEvent(event);
          break;
        default:
          break;
      }
    });
  }
}

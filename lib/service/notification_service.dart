import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_2/main.dart';
import 'package:flutter_application_2/service/callkit_event_handler.dart';
import 'package:flutter_application_2/service/fcm_service.dart';
import 'package:flutter_application_2/service/firebase_database.dart';
import 'package:flutter_application_2/video/homepage.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

void Function(Map body)? onRejectCall;

@pragma('vm:entry-point')
Future<void> backgroundHandler(RemoteMessage message) async {
  CallkitEventHandler.registerEvent();
  if (message.data['action'] == NOTIFICATION_ACTION.VIDEO_CALL) {
    await NotificationService.showCallkitIncoming(message);
  }
}

Future<void> onHandleIncomingEvent(Map extra) async {
  /// Xử lý cuộc gọi tới đã chấp nhận
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    if (extra["action"] == NOTIFICATION_ACTION.VIDEO_CALL) {
      final data = jsonDecode(extra['data'] as String) as Map;

      Navigator.of(navigatorKey.currentContext!).push(MaterialPageRoute(
        builder: (context) => HomePage(
          userType: 'V',
        ),
      ));
    }
  });
}

void onHandleDeclineCallEvent(CallEvent event) async {
  /// Xử lý cuộc gọi tới đã từ bỏ
  final extra = event.body['extra'] as Map;
  print('onHandleDeclineCallEvent 1');
  if (extra["action"] == NOTIFICATION_ACTION.VIDEO_CALL) {
    print('onHandleDeclineCallEvent 2');
    final data = jsonDecode(extra['data'] as String) as Map;
    final senderToken = data['sender_token'];
    print('onHandleDeclineCallEvent 3');
    if (senderToken != null) {
      print('onHandleDeclineCallEvent 4');
      print('channel id ${data['channel_id']}');
      await FcmService.instance.pushNotification(
          receiverToken: senderToken,
          action: NOTIFICATION_ACTION.END_CALL,
          data: {'channel_id': data['channel_id']});
      print('onHandleDeclineCallEvent 5');
    }
  }
}

class NotificationService {
  static FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseDataSource firebaseDataSource;
  String? fcmToken;

  NotificationService({required this.firebaseDataSource});

  Future<void> onHandleCallKitNotification() async {
    print('onHandleCallKitNotification');

    /// Xử lý cuộc gọi tới khi người dùng có thể chấp nhận cuộc gọi ở trạng thái kill app
    final callData = await FlutterCallkitIncoming.activeCalls();
    if (callData == null) return;
    if (callData is List) {
      if (callData.isEmpty) return;
      Map map = callData.first;
      await onHandleIncomingEvent(map['extra']);

      /// Xóa dữ liệu các cuộc gọi để lần sau vào không bị vào room
      FlutterCallkitIncoming.endAllCalls();
    }
  }

  Future<void> init() async {
    var settings = await _requestPermission();
    subscribeOnForegroundMessage();

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      fcmToken = await getToken();
      firebaseDataSource.registerUser(userId: userId, fcmToken: fcmToken ?? '');
      await _configFirebaseMessaging();
    }
  }

  Future<String?> getToken() async {
    if (Platform.isIOS) {
      var apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null) {
        return null;
      }
    }
    return _messaging.getToken();
  }

  Future<void> _configFirebaseMessaging() async {
    await _messaging.setAutoInitEnabled(true);
  }

  void subscribeOnForegroundMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      /// Xử lý phần noti của cuộc gọi
      print('subscribeOnForegroundMessage $message');
      if (message.data['action'] == NOTIFICATION_ACTION.VIDEO_CALL) {
        showCallkitIncoming(message);
      } else if (message.data["action"] == NOTIFICATION_ACTION.END_CALL) {
        final data = jsonDecode(message.data['data']) as Map;
        onRejectCall?.call(data);
      }
    });
  }

  Future<NotificationSettings> _requestPermission() async {
    _messaging = FirebaseMessaging.instance;
    var result = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );
    if (result.authorizationStatus == AuthorizationStatus.denied) {
      return result;
    }

    return result;
  }

  static Future<void> showCallkitIncoming(RemoteMessage message) async {
    final params = CallKitParams(
      id: message.messageId,
      nameCaller: message.notification?.title,
      appName: 'IOT Elevator',
      handle: '',
      type: 0,
      duration: 30000,
      textAccept: 'Chấp nhận',
      textDecline: 'Từ chối',
      extra: message.data,
      missedCallNotification: const NotificationParams(
        showNotification: false,
        isShowCallback: false,
      ),
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: 'assets/test.png',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: '',
        supportsVideo: false,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }
}

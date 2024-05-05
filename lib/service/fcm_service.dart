import 'package:dio/dio.dart';
import 'package:flutter_application_2/constant/app_constant.dart';
import 'package:flutter_application_2/main.dart';
import 'package:flutter_application_2/service/notification_service.dart';

class FcmService {
  final dio = Dio();

  FcmService._();

  static final FcmService instance = FcmService._();

  void pushCallKitNotification(String roomId,
      {String? receiverToken, String action = NOTIFICATION_ACTION.VIDEO_CALL}) {
    pushNotification(receiverToken: receiverToken, action: action, data: {
      "roomId": roomId,
      "sender_id": userId,
      "sender_token": locator.get<NotificationService>().fcmToken
    });
  }

  Future<void> pushNotification({
    String? receiverToken,
    String? action,
    Map<String, dynamic>? data,
  }) async {
    try {
      await dio.post(
        'https://fcm.googleapis.com/fcm/send',
        data: {
          "to": receiverToken ??
              "cKq4u0SGSz6eAM9c_Q5InC:APA91bHRdDCQONdivpaDxok5cEbCPwrL2LniMc8yohIYRDNBgQJIGaLoslvfXxc_-ddgr1SX_d8t3ZGYljEvaoVby5lCi5VWRYuaL2i9TQvhQfrdiaF4bvkF5o_xUxStNgWNrOdBfyNN",
          "data": {"action": action, "data": data}
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=${AppConstant.SERVER_KEY}',
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}

abstract class NOTIFICATION_ACTION {
  static const VIDEO_CALL = 'VIDEO_CALL';
  static const END_CALL = 'END_CALL';
}

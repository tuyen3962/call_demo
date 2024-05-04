import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/firebase_options.dart';
import 'package:flutter_application_2/service/callkit_event_handler.dart';
import 'package:flutter_application_2/service/firebase_database.dart';
import 'package:flutter_application_2/service/notification_service.dart';
import 'package:flutter_application_2/video/main.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

final locator = GetIt.instance;
final userId = const Uuid().v4();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  CallkitEventHandler.registerEvent();
  locator.registerSingleton<FirebaseDataSource>(FirebaseDataSource());

  final notificationService =
      NotificationService(firebaseDataSource: locator.get());
  await notificationService.init();
  locator.registerSingleton<NotificationService>(notificationService);
  runApp(const MyApp());
}

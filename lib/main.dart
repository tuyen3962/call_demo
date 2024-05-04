import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/firebase_options.dart';
import 'package:flutter_application_2/service/callkit_event_handler.dart';
import 'package:flutter_application_2/service/notification_service.dart';
// import 'package:flutter_application_2/video/join_room.dart';
import 'package:flutter_application_2/test/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.init();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  CallkitEventHandler.registerEvent();
  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: JoinScreen(),
//     );
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/firebase_options.dart';
import 'package:flutter_application_2/service/callkit_event_handler.dart';
import 'package:flutter_application_2/service/firebase_database.dart';
import 'package:flutter_application_2/service/notification_service.dart';
import 'package:flutter_application_2/video/homepage.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

final locator = GetIt.instance;
final userId = const Uuid().v4();
final navigatorKey = GlobalKey<NavigatorState>();

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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'CRIS live Streaming',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String userType = 'H';
  final NotificationService notification = locator.get();

  @override
  void initState() {
    super.initState();
    notification.onHandleCallKitNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
              width: 400,
              child: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      side: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const HomePage(userType: 'H')));
                },
                child: const Text("Host"),
              ),
            ),
            // const SizedBox(height: 16),
            // SizedBox(
            //   height: 50,
            //   width: 400,
            //   child: ElevatedButton(
            //     style: ButtonStyle(
            //       foregroundColor:
            //           MaterialStateProperty.all<Color>(Colors.white),
            //       backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //         const RoundedRectangleBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(15)),
            //           side: BorderSide(color: Colors.red),
            //         ),
            //       ),
            //     ),
            //     onPressed: () {
            //       Navigator.of(context).push(MaterialPageRoute(
            //           builder: (context) => const HomePage(userType: 'V')));
            //     },
            //     child: const Text("Viewer"),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}

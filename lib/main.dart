import 'package:bot_toast/bot_toast.dart';
import 'package:cm_tour/services/push_notification_service.dart';
import 'package:cm_tour/state/app_controller.dart';
import 'package:cm_tour/utils/tool_utility.dart';
import 'package:cm_tour/views/profile/notification_page.dart';
import 'package:cm_tour/views/shell/main_shell.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (error) {
    debugPrint('Firebase init skipped: $error');
  }

  final notifications = FlutterLocalNotificationsPlugin();
  PushNotificationService.instance.bind(notifications);
  await _setupNotifications(notifications);

  final app = AppController();
  await app.load();
  runApp(
    ChangeNotifierProvider.value(
      value: app,
      child: const TravelApp(),
    ),
  );

  try {
    await PushNotificationService.instance.start();
  } catch (error) {
    debugPrint('Push setup skipped: $error');
  }
}

Future<void> _setupNotifications(FlutterLocalNotificationsPlugin plugin) async {
  const android = AndroidInitializationSettings('@drawable/ic_stat_notify');
  const ios = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  await plugin.initialize(
    const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      navigatorKey.currentState?.push(
        MaterialPageRoute<void>(builder: (_) => const NotificationPage()),
      );
    },
  );
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ToolUtility.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: MaterialColor(
          ToolUtility.colorMainHax,
          ToolUtility.colorMainPrimarySwatch,
        ),
        fontFamily: ToolUtility.fontPromptRegular,
      ),
      home: const MainShell(),
    );
  }
}

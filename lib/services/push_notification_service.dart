import 'package:cm_tour/services/notification_inbox.dart';
import 'package:cm_tour/utils/tool_utility.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const _pushChannel = MethodChannel('cm_tour/push');
const _notifyIcon = '@drawable/ic_stat_notify';
const _channelId = 'cm_tour_general';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotificationService.instance.presentRemote(message);
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  FlutterLocalNotificationsPlugin? _localNotifications;
  bool _channelReady = false;
  String? _userTopic;
  DateTime? _appleMissAt;

  void bind(FlutterLocalNotificationsPlugin plugin) {
    _localNotifications = plugin;
  }

  Future<void> start() async {
    try {
      await _ensureChannel();
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: true,
        sound: false,
      );
      FirebaseMessaging.onMessage.listen(presentRemote);
      try {
        final token = await messaging.getToken();
        debugPrint('FCM token: $token');
      } catch (error) {
        debugPrint('FCM token skipped: $error');
      }
    } catch (error) {
      debugPrint('Push setup skipped: $error');
    }
  }

  Future<void> presentRemote(RemoteMessage message) async {
    final foreground =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    if (!foreground && message.notification != null) return;

    final title = _text(message.notification?.title) ??
        _text(message.data['title']) ??
        ToolUtility.appName;
    final body = _text(message.notification?.body) ??
        _text(message.data['body']) ??
        '';
    if (body.isEmpty && title == ToolUtility.appName) return;
    final text = body.isEmpty ? 'มีการแจ้งเตือนใหม่' : body;
    NotificationInbox.instance.add(title, text);
    await _showNotification(title, text);
  }

  Future<void> subscribeToUser(String userId) async {
    try {
      final safe = userId.replaceAll(RegExp(r'[^A-Za-z0-9\-_.~%]'), '');
      if (safe.isEmpty) return;
      final topic = 'cmtour_user_$safe';
      if (_userTopic == topic) return;
      if (!await _applePushReady()) return;
      if (_userTopic != null) {
        await FirebaseMessaging.instance.unsubscribeFromTopic(_userTopic!);
      }
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      _userTopic = topic;
      debugPrint('สมัครรับหัวข้อ $topic');
    } catch (error) {
      debugPrint('subscribe skipped: $error');
    }
  }

  Future<void> unsubscribeFromUser(String userId) async {
    try {
      final safe = userId.replaceAll(RegExp(r'[^A-Za-z0-9\-_.~%]'), '');
      if (safe.isEmpty) return;
      final topic = 'cmtour_user_$safe';
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      if (_userTopic == topic) _userTopic = null;
    } catch (error) {
      debugPrint('unsubscribe skipped: $error');
    }
  }

  String? _text(Object? value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    return text;
  }

  Future<bool> _applePushReady() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return true;
    final current = await FirebaseMessaging.instance.getAPNSToken();
    if (current != null && current.isNotEmpty) {
      _appleMissAt = null;
      return true;
    }
    final missed = _appleMissAt;
    if (missed != null &&
        DateTime.now().difference(missed) < const Duration(seconds: 8)) {
      return false;
    }
    String? problem;
    try {
      problem = await _pushChannel.invokeMethod<String>('registerApns');
    } catch (error) {
      problem = '$error';
    }
    for (var attempt = 0; attempt < 20; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final token = await FirebaseMessaging.instance.getAPNSToken();
      if (token != null && token.isNotEmpty) {
        _appleMissAt = null;
        return true;
      }
    }
    _appleMissAt = DateTime.now();
    final detail = problem == null || problem.isEmpty ? '' : ': $problem';
    debugPrint('APNs token ยังไม่มี จึงยังไม่สมัครรับหัวข้อ$detail');
    return false;
  }

  Future<void> _ensureChannel() async {
    final plugin = _localNotifications;
    if (plugin == null || _channelReady) return;
    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        'ทั่วไป',
        description: 'การแจ้งเตือนของ 24Travelling',
        importance: Importance.max,
      ),
    );
    _channelReady = true;
  }

  Future<void> _showNotification(String title, String body) async {
    await _ensureChannel();
    final plugin = _localNotifications;
    if (plugin == null) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'ทั่วไป',
        channelDescription: 'การแจ้งเตือนของ 24Travelling',
        importance: Importance.max,
        priority: Priority.high,
        icon: _notifyIcon,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: 'inbox',
    );
  }
}

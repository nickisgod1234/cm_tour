import 'package:cm_tour/models/catalog.dart';
import 'package:cm_tour/services/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends ChangeNotifier {
  AppController() {
    videos = [
      FeedVideo(
        id: 'v-tour',
        author: '@C250922-0002',
        title: 'คลิปทัวร์',
        likes: 2,
        views: 9,
        liked: true,
        videoUrl:
            'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      ),
      FeedVideo(
        id: 'v-river',
        author: '@24travelling',
        title: 'ล่องแก่งแม่น้ำ',
        likes: 18,
        views: 240,
        videoUrl:
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      ),
      FeedVideo(
        id: 'v-flower',
        author: '@24travelling',
        title: 'ทุ่งดอกไม้',
        likes: 41,
        views: 860,
        videoUrl:
            'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',
      ),
      FeedVideo(
        id: 'v-nature',
        author: '@cmguide',
        title: 'เที่ยวชมธรรมชาติ',
        likes: 27,
        views: 510,
        videoUrl: 'https://media.w3.org/2010/05/bunny/trailer.mp4',
      ),
      FeedVideo(
        id: 'v-evening',
        author: '@localtrip',
        title: 'ทริปตอนเย็น',
        likes: 63,
        views: 1204,
        videoUrl: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
      ),
      FeedVideo(
        id: 'v-short',
        author: '@24travelling',
        title: 'คลิปสั้นระหว่างทาง',
        likes: 9,
        views: 133,
        videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
      ),
    ];
  }

  static const _nameKey = 'name';
  static const _phoneKey = 'phone_number';
  static const _tokenKey = 'token_otp';
  static const _idKey = 'id';

  String? userName;
  String? phone;
  String? userId;
  String? token;
  late List<FeedVideo> videos;
  final List<CartLine> cart = [];
  final List<OrderRecord> orders = [];

  final List<TourPackage> packages = const [
    TourPackage(
      id: 'p1',
      name: 'แพคเกจชมช้าง',
      place: 'เชียงใหม่',
      price: 4500,
      discountPercent: 29,
      icon: Icons.park,
    ),
    TourPackage(
      id: 'p2',
      name: 'แพคเกจล่องแก่ง',
      place: 'กาญจนบุรี',
      price: 3200,
      discountPercent: 15,
      icon: Icons.water,
    ),
    TourPackage(
      id: 'p3',
      name: 'แพคเกจทะเลอันดามัน',
      place: 'ภูเก็ต',
      price: 8900,
      icon: Icons.beach_access,
    ),
    TourPackage(
      id: 'p4',
      name: 'แพคเกจวัดและเมืองเก่า',
      place: 'อยุธยา',
      price: 1900,
      discountPercent: 10,
      icon: Icons.account_balance,
    ),
  ];

  bool get isLoggedIn =>
      phone != null && phone!.isNotEmpty && token != null && token!.isNotEmpty;

  String get displayName {
    final name = userName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    return phone ?? '';
  }

  int get cartCount => cart.fold(0, (sum, line) => sum + line.qty);

  int get cartTotal =>
      cart.fold(0, (sum, line) => sum + line.item.salePrice * line.qty);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userName = prefs.getString(_nameKey);
      phone = prefs.getString(_phoneKey);
      userId = prefs.getString(_idKey);
      token = prefs.getString(_tokenKey);
      if (isLoggedIn) {
        await PushNotificationService.instance.subscribeToUser(userId ?? phone!);
      }
    } catch (error) {
      debugPrint('session skipped: $error');
    }
    notifyListeners();
  }

  Future<void> signIn({
    required String phoneNumber,
    required String otpToken,
    required String id,
    String? name,
  }) async {
    phone = phoneNumber.trim();
    token = otpToken;
    userId = id.trim().isEmpty ? phone : id.trim();
    final savedName = name?.trim() ?? '';
    userName = savedName.isEmpty ? null : savedName;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_phoneKey, phone!);
      await prefs.setString(_tokenKey, token!);
      await prefs.setString(_idKey, userId!);
      if (userName == null) {
        await prefs.remove(_nameKey);
      } else {
        await prefs.setString(_nameKey, userName!);
      }
    } catch (error) {
      debugPrint('session save skipped: $error');
    }
    await PushNotificationService.instance.subscribeToUser(userId!);
    notifyListeners();
  }

  Future<void> signOut() async {
    final previous = userId ?? phone;
    userName = null;
    phone = null;
    userId = null;
    token = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_nameKey);
      await prefs.remove(_phoneKey);
      await prefs.remove(_tokenKey);
      await prefs.remove(_idKey);
    } catch (error) {
      debugPrint('session clear skipped: $error');
    }
    if (previous != null && previous.isNotEmpty) {
      await PushNotificationService.instance.unsubscribeFromUser(previous);
    }
    notifyListeners();
  }

  void toggleLike(FeedVideo video) {
    video.liked = !video.liked;
    video.likes += video.liked ? 1 : -1;
    if (video.likes < 0) video.likes = 0;
    notifyListeners();
  }

  void addView(FeedVideo video) {
    video.views += 1;
    notifyListeners();
  }

  void addComment(FeedVideo video, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    video.comments.add(trimmed);
    notifyListeners();
  }

  void retryVideo(FeedVideo video) {
    final url = video.videoUrl;
    if (url == null || url.isEmpty) return;
    video.attempts += 1;
    video.errorText = null;
    notifyListeners();
  }

  void report(FeedVideo video) {
    video.reported = true;
    notifyListeners();
  }

  void publishVideo({required String title, required String author}) {
    videos.insert(
      0,
      FeedVideo(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        author: author,
        title: title.trim(),
        likes: 0,
        views: 0,
      ),
    );
    notifyListeners();
  }

  void addToCart(TourPackage item) {
    final index = cart.indexWhere((line) => line.item.id == item.id);
    if (index >= 0) {
      cart[index].qty += 1;
    } else {
      cart.add(CartLine(item));
    }
    notifyListeners();
  }

  void changeQty(CartLine line, int delta) {
    line.qty += delta;
    if (line.qty <= 0) cart.remove(line);
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  void checkout() {
    if (cart.isEmpty) return;
    orders.insert(
      0,
      OrderRecord(
        id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
        total: cartTotal,
        itemNames: cart
            .map((line) => '${line.item.name} x${line.qty}')
            .toList(growable: false),
        at: DateTime.now(),
      ),
    );
    cart.clear();
    notifyListeners();
  }
}

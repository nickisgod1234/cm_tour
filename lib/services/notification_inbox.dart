import 'package:cm_tour/models/catalog.dart';
import 'package:flutter/foundation.dart';

class NotificationInbox extends ChangeNotifier {
  NotificationInbox._();

  static final NotificationInbox instance = NotificationInbox._();

  final List<AppNotice> items = [];

  void add(String title, String body) {
    items.insert(
      0,
      AppNotice(title: title, body: body, at: DateTime.now()),
    );
    notifyListeners();
  }
}

import 'package:flutter/widgets.dart';

class TourPackage {
  const TourPackage({
    required this.id,
    required this.name,
    required this.place,
    required this.price,
    required this.icon,
    this.discountPercent,
  });

  final String id;
  final String name;
  final String place;
  final int price;
  final IconData icon;
  final int? discountPercent;

  int get salePrice {
    final discount = discountPercent;
    if (discount == null) return price;
    return (price * (100 - discount) / 100).round();
  }
}

class FeedVideo {
  FeedVideo({
    required this.id,
    required this.author,
    required this.title,
    this.videoUrl,
    this.errorText,
    this.likes = 0,
    this.views = 0,
    this.attempts = 0,
    this.maxAttempts = 2,
    this.liked = false,
  });

  final String id;
  final String author;
  final String title;
  final String? videoUrl;
  String? errorText;
  int likes;
  int views;
  int attempts;
  final int maxAttempts;
  bool liked;
  bool reported = false;
  final List<String> comments = [];
}

class CartLine {
  CartLine(this.item);

  final TourPackage item;
  int qty = 1;
}

class OrderRecord {
  OrderRecord({
    required this.id,
    required this.total,
    required this.itemNames,
    required this.at,
  });

  final String id;
  final int total;
  final List<String> itemNames;
  final DateTime at;
}

class AppNotice {
  AppNotice({required this.title, required this.body, required this.at});

  final String title;
  final String body;
  final DateTime at;
}

import 'package:cm_tour/widgets/app_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bottom bar shows the five main tabs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomBar(index: 0, onTap: (_) {}),
        ),
      ),
    );

    expect(find.text('ฟีดวิดีโอ'), findsOneWidget);
    expect(find.text('ร้านค้า'), findsOneWidget);
    expect(find.text('สร้างวิดีโอ'), findsOneWidget);
    expect(find.text('ตะกร้า'), findsOneWidget);
    expect(find.text('โปรไฟล์'), findsOneWidget);
  });
}

import 'package:cm_tour/state/app_controller.dart';
import 'package:cm_tour/utils/tool_utility.dart';
import 'package:cm_tour/views/cart/cart_page.dart';
import 'package:cm_tour/views/create/create_video_page.dart';
import 'package:cm_tour/views/feed/video_feed_page.dart';
import 'package:cm_tour/views/profile/profile_page.dart';
import 'package:cm_tour/views/shop/shop_page.dart';
import 'package:cm_tour/widgets/app_bottom_bar.dart';
import 'package:cm_tour/widgets/login_required_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  var _index = 0;

  Future<void> _select(int index) async {
    final app = context.read<AppController>();
    if (index == 2 && !app.isLoggedIn) {
      final ok = await showLoginRequiredDialog(context);
      if (!ok || !mounted) return;
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _index == 0 ? Colors.black : ToolUtility.colorPage,
      body: IndexedStack(
        index: _index,
        children: [
          const VideoFeedPage(),
          ShopPage(onOpenCart: () => setState(() => _index = 3)),
          CreateVideoPage(onPosted: () => setState(() => _index = 0)),
          const CartPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: AppBottomBar(index: _index, onTap: _select),
    );
  }
}

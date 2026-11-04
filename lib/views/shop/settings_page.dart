import 'package:cm_tour/state/app_controller.dart';
import 'package:cm_tour/utils/tool_utility.dart';
import 'package:cm_tour/views/profile/notification_page.dart';
import 'package:cm_tour/widgets/login_required_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return Scaffold(
      backgroundColor: ToolUtility.colorPage,
      appBar: AppBar(
        backgroundColor: ToolUtility.colorMain,
        foregroundColor: Colors.white,
        title: Text('ตั้งค่า', style: ToolUtility.prompt(18, color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            leading: const Icon(Icons.notifications_none),
            title: Text('การแจ้งเตือน', style: ToolUtility.prompt(15)),
            onTap: () => ToolUtility.gotoPageHasBack(context, const NotificationPage()),
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            leading: Icon(app.isLoggedIn ? Icons.person : Icons.login),
            title: Text(
              app.isLoggedIn ? app.displayName : 'เข้าระบบ',
              style: ToolUtility.prompt(15),
            ),
            onTap: () async {
              if (app.isLoggedIn) return;
              await showLoginRequiredDialog(context);
            },
          ),
        ],
      ),
    );
  }
}

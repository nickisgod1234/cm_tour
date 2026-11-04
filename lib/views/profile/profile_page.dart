import 'package:cm_tour/state/app_controller.dart';
import 'package:cm_tour/utils/tool_utility.dart';
import 'package:cm_tour/views/profile/notification_page.dart';
import 'package:cm_tour/widgets/login_required_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return ColoredBox(
      color: ToolUtility.colorPage,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: ToolUtility.colorMain,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.isLoggedIn ? app.displayName : 'ยังไม่ได้เข้าสู่ระบบ',
                        style: ToolUtility.prompt(18, weight: FontWeight.w700),
                      ),
                      if (app.isLoggedIn &&
                          (app.userName?.trim().isNotEmpty ?? false))
                        Text(app.phone!, style: ToolUtility.prompt(13, color: ToolUtility.colorGrey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
              leading: Icon(app.isLoggedIn ? Icons.logout : Icons.login),
              title: Text(app.isLoggedIn ? 'ออกจากระบบ' : 'เข้าระบบ', style: ToolUtility.prompt(15)),
              onTap: () async {
                if (app.isLoggedIn) {
                  await app.signOut();
                  if (context.mounted) ToolUtility.toast(context, true, 'ออกจากระบบแล้ว');
                  return;
                }
                await showLoginRequiredDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

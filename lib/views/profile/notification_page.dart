import 'package:cm_tour/services/notification_inbox.dart';
import 'package:cm_tour/utils/tool_utility.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: NotificationInbox.instance,
      builder: (context, _) {
        final items = NotificationInbox.instance.items;
        return Scaffold(
          backgroundColor: ToolUtility.colorPage,
          appBar: AppBar(
            backgroundColor: ToolUtility.colorMain,
            foregroundColor: Colors.white,
            title: Text(
              'การแจ้งเตือน',
              style: ToolUtility.prompt(18, color: Colors.white),
            ),
          ),
          body: items.isEmpty
              ? Center(
                  child: Text(
                    'ยังไม่มีการแจ้งเตือน',
                    style: ToolUtility.prompt(16, color: ToolUtility.colorGreyCustom6),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: ToolUtility.prompt(15, weight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(item.body, style: ToolUtility.prompt(14)),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat(ToolUtility.yyyyMMddDashHHmmss).format(item.at),
                            style: ToolUtility.prompt(12, color: ToolUtility.colorGrey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

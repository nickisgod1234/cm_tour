import 'package:cm_tour/state/app_controller.dart';
import 'package:cm_tour/utils/tool_utility.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppController>().orders;
    return Scaffold(
      backgroundColor: ToolUtility.colorPage,
      appBar: AppBar(
        backgroundColor: ToolUtility.colorMain,
        foregroundColor: Colors.white,
        title: Text('ประวัติสั่งซื้อ', style: ToolUtility.prompt(18, color: Colors.white)),
      ),
      body: orders.isEmpty
          ? Center(child: Text('ยังไม่มีประวัติสั่งซื้อ', style: ToolUtility.prompt(16)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final order = orders[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.id, style: ToolUtility.prompt(13, color: ToolUtility.colorGrey)),
                      const SizedBox(height: 4),
                      for (final name in order.itemNames)
                        Text(name, style: ToolUtility.prompt(15)),
                      const SizedBox(height: 6),
                      Text(
                        '${ToolUtility.money(order.total)} บาท',
                        style: ToolUtility.prompt(15, weight: FontWeight.w700, color: ToolUtility.colorMain),
                      ),
                      Text(
                        DateFormat(ToolUtility.ddMMyyyy).format(order.at),
                        style: ToolUtility.prompt(12, color: ToolUtility.colorGrey),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

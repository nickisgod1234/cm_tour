import 'package:cm_tour/state/app_controller.dart';
import 'package:cm_tour/utils/tool_utility.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return Scaffold(
      backgroundColor: ToolUtility.colorPage,
      appBar: AppBar(
        backgroundColor: ToolUtility.colorMain,
        foregroundColor: Colors.white,
        title: Text('การชำระเงิน', style: ToolUtility.prompt(18, color: Colors.white)),
      ),
      body: app.cart.isEmpty
          ? Center(child: Text('ไม่มีรายการให้ชำระ', style: ToolUtility.prompt(16)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final line in app.cart)
                  ListTile(
                    title: Text(line.item.name, style: ToolUtility.prompt(15)),
                    subtitle: Text('x${line.qty}', style: ToolUtility.prompt(13)),
                    trailing: Text(
                      '${ToolUtility.money(line.item.salePrice * line.qty)} บาท',
                      style: ToolUtility.prompt(14, weight: FontWeight.w700),
                    ),
                  ),
                const Divider(),
                Text(
                  'รวม ${ToolUtility.money(app.cartTotal)} บาท',
                  style: ToolUtility.prompt(18, weight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    app.checkout();
                    ToolUtility.toast(context, true, 'ชำระเงินแล้ว');
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: ToolUtility.colorAccent,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text('ยืนยันชำระเงิน', style: ToolUtility.prompt(16, color: Colors.white)),
                ),
              ],
            ),
    );
  }
}

import 'package:cm_tour/state/app_controller.dart';
import 'package:cm_tour/utils/tool_utility.dart';
import 'package:cm_tour/views/shop/payment_page.dart';
import 'package:cm_tour/widgets/login_required_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return ColoredBox(
      color: ToolUtility.colorPage,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 12, 16, 16),
            color: ToolUtility.colorCart,
            child: Row(
              children: [
                Text(
                  'ตะกร้าสินค้า',
                  style: ToolUtility.prompt(20, weight: FontWeight.w700),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: app.cart.isEmpty ? null : app.clearCart,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text('เคลียร์ตะกร้า', style: ToolUtility.prompt(13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: app.cart.isEmpty
                ? Center(
                    child: Text(
                      'ไม่มีสินค้าในตะกร้า',
                      style: ToolUtility.prompt(16),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final line in app.cart)
                        Card(
                          child: ListTile(
                            title: Text(line.item.name, style: ToolUtility.prompt(15, weight: FontWeight.w700)),
                            subtitle: Text(
                              '${ToolUtility.money(line.item.salePrice)} บาท',
                              style: ToolUtility.prompt(13),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => app.changeQty(line, -1),
                                  icon: const Icon(Icons.remove),
                                ),
                                Text('${line.qty}', style: ToolUtility.prompt(15)),
                                IconButton(
                                  onPressed: () => app.changeQty(line, 1),
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'รวม ${ToolUtility.money(app.cartTotal)} บาท',
                        style: ToolUtility.prompt(18, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () async {
                          if (!app.isLoggedIn) {
                            final ok = await showLoginRequiredDialog(context);
                            if (!ok || !context.mounted) return;
                          }
                          if (!context.mounted) return;
                          ToolUtility.gotoPageHasBack(context, const PaymentPage());
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: ToolUtility.colorAccent,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: Text('ไปชำระเงิน', style: ToolUtility.prompt(16, color: Colors.white)),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

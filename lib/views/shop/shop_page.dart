import 'package:cm_tour/models/catalog.dart';
import 'package:cm_tour/state/app_controller.dart';
import 'package:cm_tour/utils/tool_utility.dart';
import 'package:cm_tour/views/shop/contact_page.dart';
import 'package:cm_tour/views/shop/order_history_page.dart';
import 'package:cm_tour/views/shop/payment_page.dart';
import 'package:cm_tour/views/shop/settings_page.dart';
import 'package:cm_tour/widgets/login_required_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key, required this.onOpenCart});

  final VoidCallback onOpenCart;

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final _search = TextEditingController();
  var _query = '';
  var _sort = 'ชื่อ';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<TourPackage> _visible(AppController app) {
    final items = app.packages.where((item) {
      final text = '${item.name} ${item.place}'.toLowerCase();
      return text.contains(_query.toLowerCase());
    }).toList();
    if (_sort == 'ราคาต่ำ-สูง') {
      items.sort((a, b) => a.salePrice.compareTo(b.salePrice));
    } else if (_sort == 'ราคาสูง-ต่ำ') {
      items.sort((a, b) => b.salePrice.compareTo(a.salePrice));
    }
    return items;
  }

  Future<void> _pay(BuildContext context) async {
    final app = context.read<AppController>();
    if (!app.isLoggedIn) {
      final ok = await showLoginRequiredDialog(context);
      if (!ok || !context.mounted) return;
    }
    if (!context.mounted) return;
    ToolUtility.gotoPageHasBack(context, const PaymentPage());
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final items = _visible(app);
    return ColoredBox(
      color: ToolUtility.colorPage,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          _ShopHeaderCard(
            search: _search,
            onSearch: (value) => setState(() => _query = value),
            onSettings: () => ToolUtility.gotoPageHasBack(context, const SettingsPage()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Shortcut(icon: Icons.shopping_bag_outlined, label: 'ตะกร้าสินค้า', onTap: widget.onOpenCart),
                    _Shortcut(icon: Icons.account_balance_wallet_outlined, label: 'การชำระเงิน', onTap: () => _pay(context)),
                    _Shortcut(
                      icon: Icons.receipt_long_outlined,
                      label: 'ประวัติสั่งซื้อ',
                      onTap: () => ToolUtility.gotoPageHasBack(context, const OrderHistoryPage()),
                    ),
                    _Shortcut(
                      icon: Icons.chat_bubble_outline,
                      label: 'ติดต่อเรา',
                      onTap: () => ToolUtility.gotoPageHasBack(context, const ContactPage()),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _Banner(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _Chip(label: 'ทั้งหมด', selected: true, icon: Icons.check),
                    const SizedBox(width: 8),
                    const _Chip(label: 'สินค้า'),
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (value) => setState(() => _sort = value),
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'ชื่อ', child: Text('ชื่อ')),
                        PopupMenuItem(value: 'ราคาต่ำ-สูง', child: Text('ราคาต่ำ-สูง')),
                        PopupMenuItem(value: 'ราคาสูง-ต่ำ', child: Text('ราคาสูง-ต่ำ')),
                      ],
                      child: _Chip(label: _sort == 'ชื่อ' ? 'เรียงลำดับ' : _sort, icon: Icons.sort),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final item in items) _PackageCard(item: item),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopHeaderCard extends StatelessWidget {
  const _ShopHeaderCard({
    required this.search,
    required this.onSearch,
    required this.onSettings,
  });

  final TextEditingController search;
  final ValueChanged<String> onSearch;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 12, 16, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ToolUtility.colorMainDark, ToolUtility.colorMain],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.park, color: ToolUtility.colorMain),
              ),
              Expanded(
                child: Text(
                  ToolUtility.appName,
                  textAlign: TextAlign.center,
                  style: ToolUtility.prompt(22, color: Colors.white, weight: FontWeight.w600),
                ),
              ),
              Material(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
                child: IconButton(
                  onPressed: onSettings,
                  tooltip: 'ตั้งค่า',
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: search,
            onChanged: onSearch,
            style: ToolUtility.prompt(15),
            decoration: InputDecoration(
              hintText: 'ค้นหาสินค้า...',
              hintStyle: ToolUtility.prompt(15, color: const Color(0xFF9A9AA3)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF9A9AA3)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Icon(icon, size: 36, color: const Color(0xFF444444)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: ToolUtility.prompt(11)),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Row(
        children: const [
          Expanded(child: _Slide(color: Color(0xFF1B7A45), icon: Icons.park, title: 'ทัวร์ชมช้าง')),
          SizedBox(width: 8),
          Expanded(child: _Slide(color: Color(0xFF1A6C8A), icon: Icons.water, title: 'ล่องแก่ง')),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.color, required this.icon, required this.title});

  final Color color;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 42),
          const SizedBox(height: 8),
          Text(title, style: ToolUtility.prompt(14, color: Colors.white)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.selected = false, this.icon});

  final String label;
  final bool selected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? ToolUtility.colorAccent : const Color(0xFFE4E4E4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: selected ? ToolUtility.colorAccent : Colors.black54),
            const SizedBox(width: 4),
          ],
          Text(label, style: ToolUtility.prompt(13)),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.item});

  final TourPackage item;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppController>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: ToolUtility.colorCart,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(child: Icon(item.icon, size: 36, color: ToolUtility.colorMain)),
                if (item.discountPercent != null)
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: ToolUtility.colorRetry,
                      child: Text(
                        '-${item.discountPercent}%',
                        style: ToolUtility.prompt(12, color: Colors.white, weight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: ToolUtility.prompt(16, weight: FontWeight.w700)),
                Text(item.place, style: ToolUtility.prompt(13, color: ToolUtility.colorGreyCustom6)),
                const SizedBox(height: 6),
                Text(
                  '${ToolUtility.money(item.salePrice)} บาท',
                  style: ToolUtility.prompt(15, color: ToolUtility.colorMain, weight: FontWeight.w700),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      app.addToCart(item);
                      ToolUtility.toast(context, true, 'เพิ่มลงตะกร้าแล้ว');
                    },
                    child: Text('เพิ่มลงตะกร้า', style: ToolUtility.prompt(13, color: ToolUtility.colorMain)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

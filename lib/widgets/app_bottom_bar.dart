import 'package:cm_tour/utils/tool_utility.dart';
import 'package:flutter/material.dart';

class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.index,
    required this.onTap,
  });

  final int index;
  final ValueChanged<int> onTap;

  static const _idle = Color(0xFF9A9AA3);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(4, 4, 4, bottom + 6),
      child: Row(
        children: [
          _item(0, Icons.smart_display_outlined, Icons.smart_display, 'ฟีดวิดีโอ'),
          _item(1, Icons.storefront_outlined, Icons.storefront, 'ร้านค้า'),
          _center(),
          _item(3, Icons.shopping_cart_outlined, Icons.shopping_cart, 'ตะกร้า'),
          _item(4, Icons.person_outline, Icons.person, 'โปรไฟล์'),
        ],
      ),
    );
  }

  Widget _center() {
    final selected = index == 2;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: selected ? ToolUtility.colorAccent : Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              shadowColor: const Color(0x33000000),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.add,
                  size: 26,
                  color: selected ? Colors.white : ToolUtility.colorAccent,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'สร้างวิดีโอ',
              style: ToolUtility.prompt(
                11,
                weight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? ToolUtility.colorAccent : _idle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(int tab, IconData icon, IconData active, String label) {
    final selected = index == tab;
    final color = selected ? ToolUtility.colorAccent : _idle;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(tab),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: selected ? ToolUtility.colorAccent : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected ? active : icon,
                color: selected ? Colors.white : _idle,
                size: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: ToolUtility.prompt(
                11,
                weight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

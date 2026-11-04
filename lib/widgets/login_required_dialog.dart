import 'package:cm_tour/utils/tool_utility.dart';
import 'package:cm_tour/views/auth/login_page.dart';
import 'package:flutter/material.dart';

Future<bool> showLoginRequiredDialog(BuildContext context) async {
  final go = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFFF4F1F6),
        insetPadding: const EdgeInsets.symmetric(horizontal: 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.login, color: ToolUtility.colorRetry, size: 54),
              const SizedBox(height: 12),
              Text(
                'เข้าระบบ',
                style: ToolUtility.prompt(22, weight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'การดำเนินการนี้จำเป็นต้องเข้าระบบก่อน',
                textAlign: TextAlign.center,
                style: ToolUtility.prompt(14, color: const Color(0xFF6B6B6B)),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Color(0xFFD7D7D7)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('ยกเลิก', style: ToolUtility.prompt(15)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: ToolUtility.colorAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'ไปยังหน้าเข้าระบบ',
                        style: ToolUtility.prompt(14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  if (go != true || !context.mounted) return false;
  final loggedIn = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const LoginPage()),
  );
  return loggedIn == true;
}

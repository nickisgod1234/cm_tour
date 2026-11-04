import 'package:cm_tour/utils/tool_utility.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ToolUtility.colorPage,
      appBar: AppBar(
        backgroundColor: ToolUtility.colorMain,
        foregroundColor: Colors.white,
        title: Text('ติดต่อเรา', style: ToolUtility.prompt(18, color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('สอบถามแพคเกจทัวร์ได้ที่นี่', style: ToolUtility.prompt(16, weight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: _message,
            minLines: 4,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'ข้อความ',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (_message.text.trim().isEmpty) {
                ToolUtility.toast(context, false, 'กรอกข้อความก่อนส่ง');
                return;
              }
              _message.clear();
              ToolUtility.toast(context, true, 'ส่งข้อความแล้ว');
            },
            style: FilledButton.styleFrom(
              backgroundColor: ToolUtility.colorAccent,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text('ส่งข้อความ', style: ToolUtility.prompt(16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

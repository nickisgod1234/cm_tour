import 'package:cm_tour/state/app_controller.dart';
import 'package:cm_tour/utils/tool_utility.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateVideoPage extends StatefulWidget {
  const CreateVideoPage({super.key, required this.onPosted});

  final VoidCallback onPosted;

  @override
  State<CreateVideoPage> createState() => _CreateVideoPageState();
}

class _CreateVideoPageState extends State<CreateVideoPage> {
  final _title = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _post() {
    final app = context.read<AppController>();
    if (_title.text.trim().isEmpty) {
      ToolUtility.toast(context, false, 'ใส่ชื่อคลิปก่อนโพสต์');
      return;
    }
    final author = '@${app.displayName}';
    app.publishVideo(title: _title.text, author: author);
    _title.clear();
    ToolUtility.toast(context, true, 'โพสต์คลิปแล้ว');
    widget.onPosted();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ToolUtility.colorPage,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('สร้างวิดีโอ', style: ToolUtility.prompt(22, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'คลิปที่โพสต์จะไปแสดงที่ฟีดหน้าแรก',
              style: ToolUtility.prompt(14, color: ToolUtility.colorGreyCustom6),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _title,
              decoration: InputDecoration(
                labelText: 'ชื่อคลิป',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 180,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'พื้นที่พรีวิวคลิป',
                style: ToolUtility.prompt(14, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _post,
              style: FilledButton.styleFrom(
                backgroundColor: ToolUtility.colorAccent,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text('โพสต์ลงฟีด', style: ToolUtility.prompt(16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

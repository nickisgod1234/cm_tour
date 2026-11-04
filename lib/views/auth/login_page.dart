import 'dart:async';

import 'package:cm_tour/config/config_prod.dart';
import 'package:cm_tour/services/auth_service.dart';
import 'package:cm_tour/state/app_controller.dart';
import 'package:cm_tour/utils/tool_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phone = TextEditingController();
  final _pin = TextEditingController();
  final _auth = AuthService(baseUrl: Config.apiUrlotpsever);
  Timer? _timer;
  var _refno = '';
  var _seconds = 0;
  var _busy = false;

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _pin.dispose();
    super.dispose();
  }

  bool get _canResend => _seconds == 0 && !_busy;

  void _countDown() {
    _timer?.cancel();
    setState(() => _seconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_seconds <= 1) {
        timer.cancel();
        setState(() => _seconds = 0);
        return;
      }
      setState(() => _seconds -= 1);
    });
  }

  static const _staffPhone = '0616590324';
  static const _applePhone = '0001112345';
  static const _passcode = '123456';

  bool _isLocalPhone(String phone) {
    return phone == _staffPhone || phone == _applePhone;
  }

  String? _validPhone() {
    final phone = _phone.text.trim();
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) return null;
    return phone;
  }

  Future<void> _requestOtp() async {
    final phone = _validPhone();
    if (phone == null) {
      ToolUtility.toast(context, false, 'กรอกเบอร์โทร 10 หลัก');
      return;
    }
    if (_isLocalPhone(phone)) {
      setState(() => _refno = 'DEMO');
      ToolUtility.toast(context, true, 'เบอร์นี้เข้าได้โดยไม่ส่ง SMS');
      return;
    }
    setState(() => _busy = true);
    await _auth.checkPhoneNumber(phone);
    final refno = await _auth.sendOtp(phone);
    if (!mounted) return;
    setState(() => _busy = false);
    if (refno == null || refno.isEmpty) {
      ToolUtility.toast(context, false, 'ส่งรหัสไม่สำเร็จ ลองใหม่อีกครั้ง');
      return;
    }
    setState(() => _refno = refno);
    _countDown();
    ToolUtility.toast(context, true, 'ส่ง OTP แล้ว รหัสอ้างอิง $refno');
  }

  Future<void> _signInStaff(String phone) async {
    setState(() => _busy = true);
    final user = await _auth.checkPhoneNumber(phone);
    if (!mounted) return;
    setState(() => _busy = false);
    await context.read<AppController>().signIn(
          phoneNumber: phone,
          otpToken: 'local_session',
          id: user?['id']?.toString() ?? phone,
          name: user?['name']?.toString(),
        );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _verify() async {
    final phone = _validPhone();
    final pin = _pin.text.trim();
    if (phone == null || pin.isEmpty) {
      ToolUtility.toast(context, false, 'กรอกเบอร์โทรและรหัส OTP');
      return;
    }
    if (phone == _staffPhone && pin == _passcode) {
      await _signInStaff(phone);
      return;
    }
    if (phone == _applePhone && pin == _passcode) {
      await context.read<AppController>().signIn(
            phoneNumber: phone,
            otpToken: 'demo_token',
            id: '999',
          );
      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    }
    if (_isLocalPhone(phone)) {
      ToolUtility.toast(context, false, 'รหัสไม่ถูกต้อง');
      return;
    }
    setState(() => _busy = true);
    final response = await _auth.verifyOtp(phone, pin);
    if (!mounted) return;
    setState(() => _busy = false);
    final accepted = response['success'] == true ||
        response['success'] == 1 ||
        response['success'] == '1' ||
        response['success'] == 'true';
    if (!accepted) {
      ToolUtility.toast(
        context,
        false,
        response['message']?.toString() ?? 'ยืนยัน OTP ไม่สำเร็จ',
      );
      return;
    }
    final id = response['id']?.toString() ?? '';
    await context.read<AppController>().signIn(
          phoneNumber: phone,
          otpToken: response['token']?.toString() ?? 'otp',
          id: id,
          name: response['name']?.toString(),
        );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ToolUtility.colorPage,
      appBar: AppBar(
        backgroundColor: ToolUtility.colorMain,
        foregroundColor: Colors.white,
        title: Text('เข้าระบบ', style: ToolUtility.prompt(18, color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'กรอกเบอร์โทรเพื่อรับ OTP',
            style: ToolUtility.prompt(16, weight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'สมัครใหม่ใช้แค่เบอร์โทร ยืนยันรหัสแล้วสร้างวิดีโอหรือเข้าโปรไฟล์ได้เลย',
            style: ToolUtility.prompt(13, color: ToolUtility.colorGreyCustom6),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            enabled: _refno.isEmpty && !_busy,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: _field('เบอร์โทรศัพท์'),
          ),
          if (_refno.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'รหัสอ้างอิง $_refno',
              style: ToolUtility.prompt(14, weight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pin,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _field('รหัส OTP'),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _canResend ? _requestOtp : null,
                child: Text(
                  _seconds == 0 ? 'ขอรหัสใหม่' : 'ขอรหัสใหม่ใน $_seconds วินาที',
                  style: ToolUtility.prompt(13, color: ToolUtility.colorMain),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : (_refno.isEmpty ? _requestOtp : _verify),
            style: FilledButton.styleFrom(
              backgroundColor: ToolUtility.colorAccent,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    _refno.isEmpty ? 'ขอรหัส OTP' : 'ยืนยันและเข้าใช้งาน',
                    style: ToolUtility.prompt(16, color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  InputDecoration _field(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

bool _ok(dynamic value) {
  return value == true || value == 1 || value == '1' || value == 'true';
}

class AuthService {
  AuthService({required this.baseUrl});

  final String baseUrl;

  Future<Map<String, dynamic>?> checkPhoneNumber(String phoneNumber) async {
    final url = Uri.parse('$baseUrl/login_phone_local/check_phone.php');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({'phone_number': phoneNumber}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('ตรวจสอบเบอร์ไม่สำเร็จ');
      }
      final data = jsonDecode(response.body);
      if (_ok(data['success']) && data['data']?['status'] == 'exists') {
        final user = data['data'];
        if (user is Map<String, dynamic>) return user;
        if (user is Map) return Map<String, dynamic>.from(user);
      }
    } catch (error) {
      debugPrint('check phone skipped: $error');
    }
    return null;
  }

  Future<String?> sendOtp(String phoneNumber) async {
    final url = Uri.parse('$baseUrl/login_phone_local/request_otp.php');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({'phone_number': phoneNumber}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('ส่ง OTP ไม่สำเร็จ');
      }
      final data = jsonDecode(response.body);
      if (_ok(data['success'])) {
        return data['refno']?.toString();
      }
      throw Exception(data['message']?.toString() ?? 'ส่ง OTP ไม่สำเร็จ');
    } catch (error) {
      debugPrint('send otp skipped: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String pin) async {
    final url = Uri.parse('$baseUrl/login_phone_local/verify_otp.php');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'phone_number': phoneNumber,
          'pin': pin,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return {'success': false, 'message': 'ตอบกลับไม่ถูกต้อง'};
    } catch (error) {
      debugPrint('verify otp skipped: $error');
      return {'success': false, 'message': error.toString()};
    }
  }
}

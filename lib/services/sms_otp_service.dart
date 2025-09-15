import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SMSOTPService {
  // You can use any SMS service provider like Twilio, AWS SNS, etc.
  // For demo purposes, I'll show how to integrate with a free SMS service
  
  static const String _testMode = 'true'; // Set to 'false' for production
  
  // Free SMS service (for demo - replace with your preferred provider)
  static const String _smsApiUrl = 'https://api.sms-magic.com/send';
  static const String _apiKey = 'your_api_key_here'; // Replace with real API key
  
  // Generate random 6-digit OTP
  static String _generateOTP() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
  
  // Send OTP via SMS
  static Future<Map<String, dynamic>> sendOTP(String phoneNumber, String countryCode) async {
    try {
      print('📱 SMS OTP Service: Sending OTP to $countryCode$phoneNumber');
      
      // Clean phone number
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      String fullPhoneNumber = '$countryCode$cleanPhone';
      
      // Generate OTP
      String otp = _generateOTP();
      
      // Store OTP for verification
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sms_otp', otp);
      await prefs.setString('sms_phone', fullPhoneNumber);
      await prefs.setInt('sms_otp_time', DateTime.now().millisecondsSinceEpoch);
      
      if (_testMode == 'true') {
        // Test mode - simulate SMS sending
        print('🧪 TEST MODE: SMS OTP would be sent to $fullPhoneNumber');
        print('🔑 TEST OTP: $otp');
        print('📱 Phone: $fullPhoneNumber');
        print('⏰ OTP expires in 5 minutes');
        
        // Simulate delay
        await Future.delayed(Duration(seconds: 2));
        
        return {
          'success': true,
          'message': 'OTP sent successfully to $fullPhoneNumber\n\nFor testing, use OTP: $otp',
          'phoneNumber': fullPhoneNumber,
          'otp': otp, // Include OTP in test mode
        };
      } else {
        // Real SMS sending
        final response = await http.post(
          Uri.parse(_smsApiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            'to': fullPhoneNumber,
            'message': 'Your OTP is: $otp. Valid for 5 minutes.',
            'from': 'HRM App',
          }),
        );
        
        if (response.statusCode == 200) {
          print('✅ SMS sent successfully');
          return {
            'success': true,
            'message': 'OTP sent successfully to $fullPhoneNumber',
            'phoneNumber': fullPhoneNumber,
          };
        } else {
          print('❌ SMS sending failed: ${response.statusCode}');
          return {
            'success': false,
            'message': 'Failed to send SMS. Please try again.',
          };
        }
      }
    } catch (e) {
      print('❌ SMS OTP error: $e');
      return {
        'success': false,
        'message': 'Failed to send OTP: $e',
      };
    }
  }
  
  // Verify OTP
  static Future<Map<String, dynamic>> verifyOTP(String otp) async {
    try {
      print('🔐 SMS OTP Service: Verifying OTP: $otp');
      
      final prefs = await SharedPreferences.getInstance();
      final storedOTP = prefs.getString('sms_otp');
      final phoneNumber = prefs.getString('sms_phone');
      final otpTime = prefs.getInt('sms_otp_time');
      
      if (storedOTP == null || phoneNumber == null || otpTime == null) {
        return {
          'success': false,
          'message': 'No OTP found. Please request OTP first.',
        };
      }
      
      // Check if OTP is expired (5 minutes)
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final otpAge = currentTime - otpTime;
      if (otpAge > 300000) { // 5 minutes in milliseconds
        return {
          'success': false,
          'message': 'OTP expired. Please request a new one.',
        };
      }
      
      if (storedOTP == otp) {
        // Clear OTP after successful verification
        await prefs.remove('sms_otp');
        await prefs.remove('sms_otp_time');
        
        print('✅ OTP verified successfully');
        return {
          'success': true,
          'message': 'Phone verified successfully',
          'phoneNumber': phoneNumber,
          'isNewUser': true, // Always new user for testing
        };
      } else {
        // For testing, also accept any 6-digit number
        if (_testMode == 'true' && otp.length == 6 && RegExp(r'^\d{6}$').hasMatch(otp)) {
          print('✅ TEST MODE: Accepting any 6-digit OTP: $otp');
          await prefs.remove('sms_otp');
          await prefs.remove('sms_otp_time');
          
          return {
            'success': true,
            'message': 'Phone verified successfully (Test Mode)',
            'phoneNumber': phoneNumber,
            'isNewUser': true,
          };
        }
        
        print('❌ Invalid OTP');
        return {
          'success': false,
          'message': 'Invalid OTP. Please try again.',
        };
      }
    } catch (e) {
      print('❌ OTP verification error: $e');
      return {
        'success': false,
        'message': 'OTP verification failed: $e',
      };
    }
  }
  
  // Resend OTP
  static Future<Map<String, dynamic>> resendOTP() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('sms_phone');
      
      if (phoneNumber == null) {
        return {
          'success': false,
          'message': 'No phone number found. Please start verification again.',
        };
      }
      
      // Extract country code and phone number
      String countryCode = '+91'; // Default
      String cleanPhone = phoneNumber;
      
      if (phoneNumber.startsWith('+')) {
        if (phoneNumber.startsWith('+91')) {
          countryCode = '+91';
          cleanPhone = phoneNumber.substring(3);
        } else if (phoneNumber.startsWith('+1')) {
          countryCode = '+1';
          cleanPhone = phoneNumber.substring(2);
        }
        // Add more country codes as needed
      }
      
      return await sendOTP(cleanPhone, countryCode);
    } catch (e) {
      print('❌ Resend OTP error: $e');
      return {
        'success': false,
        'message': 'Failed to resend OTP: $e',
      };
    }
  }
}

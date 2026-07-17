import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vendor_store_app/models/vendor.dart';
import 'package:http/http.dart' as http;
import 'package:vendor_store_app/provider/vendor_provider.dart';
import 'package:vendor_store_app/services/manage_http_response.dart';
import 'package:vendor_store_app/views/global_variables.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_store_app/views/screens/authentication/login_screen.dart';
import 'package:vendor_store_app/views/screens/main_vendor_screen.dart';

final providerContainer = ProviderContainer();

class VendorAuthController {
  Future<void> signUpVendor({
    required context,
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      Vendor vendor = Vendor(
        id: '',
        fullName: fullName,
        email: email,
        state: '',
        city: '',
        locality: '',
        role: '',
        password: password,
        token: '',
      );

      http.Response response = await http.post(
        Uri.parse("$uri/api/vendor/signup"),
        body: vendor.toJson(),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      //manage http response to handle http response base on their status code
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Vendor Account Created');
        },
      );
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }

  //fucntion to consume the backend vendor signin api
  Future<void> signInVendor({
    required String email,
    required String password,
    required context,
    required WidgetRef ref,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse("$uri/api/vendor/signin"),
        body: jsonEncode({"email": email, "password": password}),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();

          // 1. Giải mã body response thô từ server
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          String token = responseData['token'];

          // Lưu token riêng vào preferences
          await preferences.setString('auth_token', token);

          // 2. Lấy Map dữ liệu vendor ra
          final Map<String, dynamic> vendorMap = responseData['vendor'];

          // 🌟 BƯỚC QUAN TRỌNG: Gán thêm token trực tiếp vào map này trước khi chuyển đổi
          vendorMap['token'] = token;

          // 3. Tiến hành mã hóa lại thành JSON string
          final vendorJson = jsonEncode(vendorMap);

          // Cập nhật trạng thái vào Riverpod Provider (lúc này token đã tồn tại bên trong!)
          ref.read(vendorProvider.notifier).setVendor(vendorJson);

          // Lưu chuỗi vendor hoàn chỉnh vào preferences phòng trường hợp cần dùng lại
          await preferences.setString('vendor', vendorJson);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainVendorScreen()),
            (route) => false,
          );
          showSnackBar(context, 'Logged in successfully');

          final currentVendor = ref.read(vendorProvider);
          print(
            "DEBUG: Dữ liệu Vendor sau khi fix: id=${currentVendor?.id}, token=${currentVendor?.token}",
          );
        },
      );
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }

  //Signout
  Future<void> signOutuser({required context, required WidgetRef ref}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      //clear the token and user from SharedPref
      await preferences.remove('auth_token');
      await preferences.remove('user');
      //clear the user state
      ref.read(vendorProvider.notifier).signOut();
      //navigate the user back to the login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LoginScreen();
          },
        ),
        (route) => false,
      );

      showSnackBar(context, 'signout successfully');
    } catch (error) {
      showSnackBar(context, 'error signing out');
    }
  }
}

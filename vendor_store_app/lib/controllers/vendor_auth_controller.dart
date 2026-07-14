import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vendor_store_app/models/vendor.dart';
import 'package:http/http.dart' as http;
import 'package:vendor_store_app/provider/vendor_provider.dart';
import 'package:vendor_store_app/services/manage_http_response.dart';
import 'package:vendor_store_app/views/global_variables.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
          String token = jsonDecode(response.body)['token'];
          await preferences.setString('auth_token', token);

          final vendorJson = jsonEncode(jsonDecode(response.body)['vendor']);

          // DÙNG REF ĐỂ CẬP NHẬT TRẠNG THÁI (Đừng dùng providerContainer)
          ref.read(vendorProvider.notifier).setVendor(vendorJson);

          await preferences.setString('vendor', vendorJson);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainVendorScreen()),
            (route) => false,
          );
          showSnackBar(context, 'Logged in successfully');
          final currentVendor = ref.read(vendorProvider);
          print("DEBUG: Sau khi đăng nhập, dữ liệu Vendor là: $currentVendor");
        },
      );
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }
}

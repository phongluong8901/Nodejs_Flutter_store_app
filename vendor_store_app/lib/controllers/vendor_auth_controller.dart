import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vendor_store_app/models/vendor.dart';
import 'package:http/http.dart' as http;
import 'package:vendor_store_app/services/manage_http_response.dart';
import 'package:vendor_store_app/views/global_variables.dart';
import 'package:vendor_store_app/views/screens/main_vendor_screen.dart';

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
        onSuccess: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) {
                return MainVendorScreen();
              },
            ),
            (route) => false,
          );

          showSnackBar(context, 'Logged in successfully');
        },
      );
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }
}

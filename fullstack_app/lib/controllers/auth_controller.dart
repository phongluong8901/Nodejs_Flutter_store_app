import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fullstack_app/models/user.dart';
import 'package:fullstack_app/services/manage_http_response.dart';
import 'package:fullstack_app/views/global_variables.dart';
import 'package:fullstack_app/views/screens/authentication_screens/login_screen.dart';
import 'package:fullstack_app/views/screens/main_screen.dart';
import 'package:http/http.dart' as http;

class AuthController {
  // Register user
  Future<void> signUpUsers({
    required context,
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      User user = User(
        id: '',
        fullName: fullName,
        email: email,
        state: '',
        city: '',
        locality: '',
        password: password,
        token: '',
      );

      http.Response response = await http.post(
        Uri.parse('$uri/api/signup'),
        body: jsonEncode(user.toMap()),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
          showSnackBar(context, 'Account has been created successfully!');
        },
      );
    } catch (e) {
      print("Signup error: $e");
      showSnackBar(context, "An error occurred: $e");
    }
  }

  // Signin user function
  Future<void> signInUsers({
    required context,
    required String email,
    required String password,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse("$uri/api/signin"),
        body: jsonEncode({'email': email, 'password': password}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
            (route) => false,
          );
          showSnackBar(context, "Login successful!");
        },
      );
    } catch (e) {
      print("Login error: $e");
      showSnackBar(context, "An error occurred: $e");
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fullstack_app/models/user.dart';
import 'package:fullstack_app/provider/user_provider.dart';
import 'package:fullstack_app/services/manage_http_response.dart';
import 'package:fullstack_app/views/global_variables.dart';
import 'package:fullstack_app/views/screens/authentication_screens/login_screen.dart';
import 'package:fullstack_app/views/screens/main_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final providerContainer = ProviderContainer();

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
        onSuccess: () async {
          //Access sharedPreference for token and user data storage
          SharedPreferences preferences = await SharedPreferences.getInstance();
          //Extract the authentication tolen from response body
          String token = jsonDecode(response.body)['token'];
          //Store the auth token security in shaprePrefre...
          await preferences.setString('auth_token', token);
          //Encode the user data received from the backend as json
          final userJson = jsonEncode(jsonDecode(response.body)['user']);
          //updaet the application state with the user data using revipod
          providerContainer.read(userProvider.notifier).setUser(userJson);
          //store the data in sharePreferene for future use
          await preferences.setString('user', userJson);

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

  //Signout
  Future<void> signOutuser({required context}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      //clear the token and user from SharedPref
      await preferences.remove('auth_token');
      await preferences.remove('user');
      //clear the user state
      providerContainer.read(userProvider.notifier).signOut();
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

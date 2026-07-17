import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fullstack_app/models/user.dart';
import 'package:fullstack_app/provider/deliverd_order_count_provider.dart';
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
    required BuildContext context,
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
    required BuildContext context,
    required String email,
    required String password,
    required WidgetRef ref,
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
  Future<void> signOutuser({required context, required WidgetRef ref}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      //clear the token and user from SharedPref
      await preferences.remove('auth_token');
      await preferences.remove('user');
      //clear the user state
      ref.read(userProvider.notifier).signOut();
      ref.read(deliveredOrderCountProvider.notifier).resetCount();
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

  //update user's state, city, locality
  Future<void> updateUserLocation({
    required BuildContext context,
    required String id,
    required String state,
    required String city,
    required String locality,
    required WidgetRef ref,
  }) async {
    try {
      //make an HTTP PUT request to update user's state, city and locality
      final http.Response response = await http.put(
        Uri.parse("$uri/api/users/$id"),
        //encode the update data(state, city and locality) as json object
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'state': state, 'city': city, 'locality': locality}),
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          //Decode the updated user data from the response body
          //this converts the json String response into Darrt Map
          final updatedUser = jsonDecode(response.body);
          //Access Shared preference for local data storage
          //shared preference allow us to store data persisitently on the device
          SharedPreferences preferences = await SharedPreferences.getInstance();
          //encode the update user data as json String
          //this prepares the data for storage in shared preferences
          final userJson = jsonEncode(updatedUser);
          //update the application state with the update user data user in Revipod
          //this ensures the app reflects the most recent user data
          ref.read(userProvider.notifier).setUser(userJson);
          //store the updated user data in shared preference for future user
          //this allows the app to retrive the user data even after the app restarts
          await preferences.setString('user', userJson);
        },
      );
    } catch (e) {
      //catch any error that occure during the the prcoess
      //show an error message to user if the update fails
      showSnackBar(context, 'Error updateing location');
    }
  }

  //Verify Otp Method

  Future<void> verifyOtp({
    required BuildContext context,
    required String email,
    required String otp,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/verify-otp'),
        body: jsonEncode({"email": email, 'otp': otp}),
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
                return LoginScreen();
              },
            ),
            (route) => false,
          );
          showSnackBar(context, 'Account verified . Please log in.');
        },
      );
    } catch (e) {
      showSnackBar(context, 'Error verifying  OTP:  $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:fullstack_app/controllers/auth_controller.dart';

class AccountScreen extends StatelessWidget {
  final AuthController _authController = AuthController();
  AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _authController.signOutuser(context: context);
          },
          child: Text('SignOut'),
        ),
      ),
    );
  }
}

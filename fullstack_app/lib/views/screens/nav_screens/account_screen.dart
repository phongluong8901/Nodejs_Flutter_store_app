import 'package:flutter/material.dart';
import 'package:fullstack_app/controllers/auth_controller.dart';
import 'package:fullstack_app/views/screens/detail/screens/order_screen.dart';

class AccountScreen extends StatelessWidget {
  final AuthController _authController = AuthController();
  AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await _authController.signOutuser(context: context);
              },
              child: Text('SignOut'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return OrderScreen();
                    },
                  ),
                );
              },
              child: Text('My Orders'),
            ),
          ],
        ),
      ),
    );
  }
}

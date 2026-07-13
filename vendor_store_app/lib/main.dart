import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_store_app/provider/vendor_provider.dart';
import 'package:vendor_store_app/views/screens/authentication/login_screen.dart';
import 'package:vendor_store_app/views/screens/main_vendor_screen.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  Future<void> _checkTokenAndSetUser(WidgetRef ref) async {
    //obtain an instance of sharePreference for local data storage
    SharedPreferences preferences = await SharedPreferences.getInstance();
    //retrive the authentication tolen and user data stored locally
    String? token = preferences.getString('auth_token');
    String? userJson = preferences.getString('user');
    //if both token and user data are avaible, update the user state
    if (token != null && userJson != null) {
      ref.read(vendorProvider.notifier).setVendor(userJson);
    } else {
      ref.read(vendorProvider.notifier).signOut();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: FutureBuilder(
        future: _checkTokenAndSetUser(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final user = ref.watch(vendorProvider);
          return user != null ? MainVendorScreen() : LoginScreen();
        },
      ),
    );
  }
}

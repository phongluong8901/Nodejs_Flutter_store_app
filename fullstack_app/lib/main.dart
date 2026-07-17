import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fullstack_app/provider/user_provider.dart';
import 'package:fullstack_app/views/screens/authentication_screens/login_screen.dart';
import 'package:fullstack_app/views/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // // 1. Cấu hình Key chung (Dành cho Mobile)
  // Stripe.publishableKey =
  //     "pk_test_51TdRBT4bsbafdwTKe77spZOszzceWxMbjZw8qu36hXlEjGC95d4X1sx769ENyz17KjCCXt72azgdLh6B4lmZswbL00bJWGrwsY";
  // await Stripe.instance.applySettings();

  // // 2. Cấu hình RIÊNG cho Web nếu app đang chạy trên Chrome
  // if (kIsWeb) {
  //   WebStripe.instance.initialise(
  //     publishableKey:
  //         "pk_test_51TdRBT4bsbafdwTKe77spZOszzceWxMbjZw8qu36hXlEjGC95d4X1sx769ENyz17KjCCXt72azgdLh6B4lmZswbL00bJWGrwsY",
  //   );
  // }
  //Run the flutter app warapped in a ProviderScope for manage state
  runApp(ProviderScope(child: const MyApp()));
}

//root widget of the appocation, a consumerWidget to consume state change
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  //method to check the token and set the user data if available
  Future<void> _checkTokenAndSetUser(WidgetRef ref) async {
    //obtain an instance of sharePreference for local data storage
    SharedPreferences preferences = await SharedPreferences.getInstance();
    //retrive the authentication tolen and user data stored locally
    String? token = preferences.getString('auth_token');
    String? userJson = preferences.getString('user');
    //if both token and user data are avaible, update the user state
    if (token != null && userJson != null) {
      ref.read(userProvider.notifier).setUser(userJson);
    } else {
      ref.read(userProvider.notifier).signOut();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User store',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // home: LoginScreen(),
      // home: MainScreen(),
      home: FutureBuilder(
        future: _checkTokenAndSetUser(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final user = ref.watch(userProvider);
          return user != null ? MainScreen() : LoginScreen();
        },
      ),
    );
  }
}

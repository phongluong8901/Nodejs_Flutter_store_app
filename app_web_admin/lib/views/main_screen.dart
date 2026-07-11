import 'package:app_web_admin/views/side_bar_screens/banner_screen.dart';
import 'package:app_web_admin/views/side_bar_screens/buyers_screen.dart';
import 'package:app_web_admin/views/side_bar_screens/category_screen.dart';
import 'package:app_web_admin/views/side_bar_screens/orders_screen.dart';
import 'package:app_web_admin/views/side_bar_screens/products_screen.dart';
import 'package:app_web_admin/views/side_bar_screens/subcategory_screen.dart';
import 'package:app_web_admin/views/side_bar_screens/vendors_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget _selectedScreen = const VendorsScreen();

  void screenSelector(AdminMenuItem item) {
    switch (item.route) {
      case VendorsScreen.id:
        setState(() => _selectedScreen = const VendorsScreen());
        break;
      case BuyersScreen.id:
        setState(() => _selectedScreen = const BuyersScreen());
        break;
      case OrdersScreen.id:
        setState(() => _selectedScreen = const OrdersScreen());
        break;
      case CategoryScreen.id:
        setState(() => _selectedScreen = const CategoryScreen());
        break;
      case SubCategoryScreen.id:
        setState(() => _selectedScreen = const SubCategoryScreen());
        break;
      case BannerScreen.id:
        setState(() => _selectedScreen = const BannerScreen());
        break;
      case ProductsScreen.id:
        setState(() => _selectedScreen = const ProductsScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      sideBar: SideBar(
        backgroundColor: const Color(0xFFF8F9FA), // Màu nền sidebar nhẹ nhàng
        activeBackgroundColor: Colors.blue.withOpacity(0.1),
        borderColor: Colors.grey.shade300,
        iconColor: Colors.blueAccent,
        textStyle: const TextStyle(color: Colors.black87, fontSize: 16),
        activeTextStyle: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),

        // --- HEADER CỦA SIDEBAR ---
        header: Container(
          height: 80,
          width: double.infinity,
          color: Colors.blueAccent,
          child: const Center(
            child: Text(
              "ADMIN PANEL",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // --- FOOTER CỦA SIDEBAR ---
        footer: Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            "v1.0.0 © 2026",
            style: TextStyle(color: Colors.grey),
          ),
        ),

        items: const [
          AdminMenuItem(
            title: 'Vendors',
            route: VendorsScreen.id,
            icon: CupertinoIcons.person_3,
          ),
          AdminMenuItem(
            title: 'Buyers',
            route: BuyersScreen.id,
            icon: CupertinoIcons.person,
          ),
          AdminMenuItem(
            title: 'Orders',
            route: OrdersScreen.id,
            icon: CupertinoIcons.shopping_cart,
          ),
          AdminMenuItem(
            title: 'Categories',
            route: CategoryScreen.id,
            icon: Icons.category,
          ),
          AdminMenuItem(
            title: 'Sub Categories',
            route: SubCategoryScreen.id,
            icon: Icons.category_outlined,
          ),
          AdminMenuItem(
            title: 'Upload Banners',
            route: BannerScreen.id,
            icon: Icons.upload,
          ),
          AdminMenuItem(
            title: 'Products',
            route: ProductsScreen.id,
            icon: Icons.store,
          ),
        ],
        selectedRoute: VendorsScreen.id,
        onSelected: (item) => screenSelector(item),
      ),
      body: _selectedScreen,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fullstack_app/views/screens/nav_screens/widgets/banner_widget.dart';
import 'package:fullstack_app/views/screens/nav_screens/widgets/category_item_widget.dart';
import 'package:fullstack_app/views/screens/nav_screens/widgets/header_widget.dart';
import 'package:fullstack_app/views/screens/nav_screens/widgets/popular_product_widget.dart';
import 'package:fullstack_app/views/screens/nav_screens/widgets/reuseble_text_widget.dart';
import 'package:fullstack_app/views/screens/nav_screens/widgets/top_rating_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.20,
        ),
        child: const HeaderWidget(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HeaderWidget(),
            BannerWidget(),
            CategoryItemWidget(),
            ReusableTextWidget(
              title: 'Top Rated Products',
              subtitle: 'view all',
            ),
            TopRatedProductWidget(),
            ReusableTextWidget(title: 'Polular Products', subtitle: 'view all'),
            PopularProductWidget(),
          ],
        ),
      ),
    );
  }
}

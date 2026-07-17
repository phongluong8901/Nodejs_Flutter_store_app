import 'package:flutter/material.dart';
import 'package:fullstack_app/controllers/product_controller.dart';
import 'package:fullstack_app/models/product.dart';
import 'package:fullstack_app/views/screens/nav_screens/widgets/product_item_widget.dart';

class SearchProductScreen extends StatefulWidget {
  const SearchProductScreen({super.key});

  @override
  State<SearchProductScreen> createState() => _SearchProductScreenState();
}

class _SearchProductScreenState extends State<SearchProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductController _productController = ProductController();

  List<Product> _searchedProducts = [];
  bool _isLoading = false;

  void _searchProducts() async {
    setState(() {
      _isLoading = true; //show loading indicator
    });

    try {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        final products = await _productController.searchProducts(query);
        setState(() {
          _searchedProducts = products;
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    //set the number of colume in grid base on the screen width
    //if the screen with is less than 600 pixels(e.g.. a phone), use columns
    //if the screen is 600 pixels ore more (e.g .. a table ),use 4 column
    final crossAxisCount = screenWidth < 600 ? 2 : 4;

    //set the aspect ratio(width-to-heigth ratio) of each grid item base on the screen width

    //for smaller screen(<600 pixels) use a ration of 3.4(taller items)

    //for larger screen(>=600 pixels), use a ratio of 4.5(more square-shaped items)

    final childAspectRatio = screenWidth < 600 ? 3 / 4 : 4 / 5;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: "search products ...",
            suffixIcon: IconButton(
              onPressed: _searchProducts,
              icon: const Icon(Icons.search),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_searchedProducts.isEmpty)
            const Center(child: Text('No Product Found'))
          else
            Expanded(
              child: GridView.builder(
                itemCount: _searchedProducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final product = _searchedProducts[index];
                  return ProductItemWidget(product: product);
                },
              ),
            ),
        ],
      ),
    );
  }
}

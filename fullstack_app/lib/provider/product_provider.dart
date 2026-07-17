import 'package:flutter_riverpod/legacy.dart';
import 'package:fullstack_app/models/product.dart';

class ProductProvider extends StateNotifier<List<Product>> {
  ProductProvider() : super([]);

  //set the list of products
  void setProducts(List<Product> product) {
    state = product;
  }
}

final productProvider = StateNotifierProvider<ProductProvider, List<Product>>((
  ref,
) {
  return ProductProvider();
});

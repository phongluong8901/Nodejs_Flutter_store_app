import 'package:flutter_riverpod/legacy.dart';
import 'package:vendor_store_app/models/product.dart';

class ProductProvider extends StateNotifier<List<Product>> {
  ProductProvider() : super([]);

  // Gán danh sách sản phẩm tải từ server về
  void setProducts(List<Product> product) {
    state = product;
  }

  // THÊM HÀM NÀY: Cập nhật thông tin của 1 sản phẩm cụ thể ngay trên máy khách
  void updateSingleProduct(Product updatedProduct) {
    state = [
      for (final product in state)
        if (product.id == updatedProduct.id) updatedProduct else product,
    ];
  }
}

final productProvider = StateNotifierProvider<ProductProvider, List<Product>>((
  ref,
) {
  return ProductProvider();
});

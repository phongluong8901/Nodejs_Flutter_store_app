import 'dart:convert';

import 'package:fullstack_app/models/product.dart';
import 'package:fullstack_app/views/global_variables.dart';
import 'package:http/http.dart' as http;

class ProductController {
  //define a functin that return a future containing list of the product  model object
  Future<List<Product>> loadPopularProducts() async {
    try {
      http.Response response = await http.get(
        Uri.parse(
          "$uri/api/popular-products",
        ), // Đảm bảo URL đã đúng là 'popular'
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      if (response.statusCode == 200) {
        // BƯỚC QUAN TRỌNG:
        // Kiểm tra xem dữ liệu là List hay Map bằng cách in ra
        // print("DỮ LIỆU NHẬN ĐƯỢC: ${response.body}");

        final dynamic decodedData = json.decode(response.body);

        List<dynamic> productList;

        // Nếu API trả về { "product": [...] } thì nó là Map
        if (decodedData is Map<String, dynamic>) {
          productList = decodedData['product'];
        }
        // Nếu API trả về thẳng [...] thì nó là List
        else {
          productList = decodedData as List<dynamic>;
        }

        List<Product> products = productList
            .map((item) => Product.fromMap(item as Map<String, dynamic>))
            .toList();

        return products;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception("Failed to load popular products");
      }
    } catch (e) {
      throw Exception("Error loading product: $e");
    }
  }

  Future<List<Product>> loadProductByCategory(String category) async {
    try {
      // 1. Gán response vào biến
      http.Response response = await http.get(
        Uri.parse('$uri/api/products-by-category/$category'),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      // 2. Kiểm tra nếu thành công
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // 3. Map từ danh sách JSON sang danh sách đối tượng Product
        List<Product> products = data
            .map((item) => Product.fromMap(item as Map<String, dynamic>))
            .toList();

        return products;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        // Trả về danh sách rỗng hoặc throw Exception nếu có lỗi
        throw Exception(
          "Failed to load products by category: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error loading products by category: $e");
    }
  }

  Future<List<Product>> loadProductsBySubcategory(String subCategory) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/products-by-subcategory/$subCategory'),
        headers: <String, String>{
          'Content-Type': 'application/json; chartset=UTF-8 ',
        },
      );
      print('subcategory product response..${response.body}');
      if (response.statusCode == 200) {
        //Decode the json response body into a list  of dynamic object
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        //map each items in the list to product model object which we can use

        List<Product> relatedProducts = data
            .map((product) => Product.fromMap(product as Map<String, dynamic>))
            .toList();
        return relatedProducts;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        //if status code is not 200 , throw an execption   indicating failure to load the popular products
        throw Exception('Failed to load subcategory products');
      }
    } catch (e) {
      throw Exception('Error subcategory product : $e');
    }
  }

  //display related prododuct by sucbategory
  Future<List<Product>> loadRelatedProductsBySubcategory(
    String productId,
  ) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/related-products-by-subcategory/$productId'),
        headers: <String, String>{
          'Content-Type': 'application/json; chartset=UTF-8 ',
        },
      );
      if (response.statusCode == 200) {
        //Decode the json response body into a list  of dynamic object
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        //map each items in the list to product model object which we can use

        List<Product> relatedProducts = data
            .map((product) => Product.fromMap(product as Map<String, dynamic>))
            .toList();
        return relatedProducts;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        //if status code is not 200 , throw an execption   indicating failure to load the popular products
        throw Exception('Failed to load related products');
      }
    } catch (e) {
      throw Exception('Error related product : $e');
    }
  }

  //method to get the top 10 highest-rated products
  Future<List<Product>> loadTopRatedProduct() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/top-rated-products'),
        headers: <String, String>{
          'Content-Type': 'application/json; chartset=UTF-8 ',
        },
      );

      if (response.statusCode == 200) {
        //Decode the json response body into a list  of dynamic object
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        //map each items in the list to product model object which we can use

        List<Product> topRatedProducts = data
            .map((product) => Product.fromMap(product as Map<String, dynamic>))
            .toList();
        return topRatedProducts;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        //if status code is not 200 , throw an execption   indicating failure to load the popular products
        throw Exception('Failed to load top Rated  products');
      }
    } catch (e) {
      throw Exception('Error related product : $e');
    }
  }
}

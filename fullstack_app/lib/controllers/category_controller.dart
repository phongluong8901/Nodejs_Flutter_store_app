import 'dart:convert';
import 'package:fullstack_app/models/category.dart'; // Đảm bảo import đúng file
import 'package:fullstack_app/views/global_variables.dart';
import 'package:http/http.dart' as http;

class CategoryController {
  Future<List<CategoryModel>> loadCategories() async {
    try {
      final response = await http.get(Uri.parse('$uri/api/categories'));

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        List<dynamic> data;
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map) {
          data = responseData['categories'] ?? [];
        } else {
          data = [];
        }

        return data
            .map((category) => CategoryModel.fromJson(category))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Lỗi chi tiết: $e");
      return [];
    }
  }
}

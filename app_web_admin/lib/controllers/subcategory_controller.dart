import 'dart:convert';
import 'dart:typed_data';
import 'package:app_web_admin/global_variable.dart';
import 'package:app_web_admin/models/subcategory.dart';
import 'package:app_web_admin/services/manage_http_response.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SubCategoryController {
  final String cloudName = 'detbxbjxd';
  final String uploadPreset = 'nodejs_store_app';

  // Sử dụng một instance client để tái sử dụng kết nối
  final http.Client _client = http.Client();

  /// Upload ảnh lên Cloudinary
  Future<String?> uploadToCloudinary(Uint8List bytes, String folder) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/upload',
      );
      var request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'subcat_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['secure_url'];
      }
      debugPrint("Cloudinary Error: ${response.body}");
      return null;
    } catch (e) {
      debugPrint("Upload Error: $e");
      return null;
    }
  }

  /// Upload SubCategory tới Backend
  Future<void> uploadSubCategory({
    required String categoryId,
    required String categoryName,
    required String subCategoryName,
    required Uint8List? image,
    required BuildContext context,
  }) async {
    try {
      String imageUrl = "";
      if (image != null) {
        imageUrl = await uploadToCloudinary(image, 'subcategories') ?? "";
      }

      final response = await _client.post(
        Uri.parse("$uri/api/subcategories"),
        body: jsonEncode({
          "categoryId": categoryId,
          "categoryName": categoryName,
          "subCategoryName": subCategoryName,
          "image": imageUrl,
        }),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () =>
            showSnackBar(context, 'SubCategory saved successfully!'),
      );
    } catch (e) {
      showSnackBar(context, 'Error: $e', isSuccess: false);
    }
  }

  /// Lấy danh sách SubCategory theo categoryName
  Future<List<SubCategoryModel>> getSubCategories(String categoryName) async {
    try {
      // Encode tên category để tránh lỗi ký tự đặc biệt trên URL
      final encodedCategory = Uri.encodeComponent(categoryName);
      final response = await _client.get(
        Uri.parse("$uri/api/category/$encodedCategory/subcategories"),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Sử dụng .map an toàn hơn, lọc bỏ các items null
        return data.map((item) => SubCategoryModel.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        debugPrint("No subcategories found for: $categoryName");
        return [];
      }

      debugPrint("Server error: ${response.statusCode} - ${response.body}");
      return [];
    } catch (e) {
      debugPrint("Exception in getSubCategories: $e");
      return [];
    }
  }

  // Giải phóng client khi không dùng nữa
  void dispose() {
    _client.close();
  }

  // get all subcategory

  Future<List<SubCategoryModel>> loadSubCategories() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/subcategories'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        List<SubCategoryModel> subCategories = data
            .map((subcategory) => SubCategoryModel.fromJson(subcategory))
            .toList();

        return subCategories;
      } else {
        throw Exception('failed to upload Subcategory');
      }
    } catch (e) {
      throw Exception('error loading Subcategory: $e');
    }
  }
}

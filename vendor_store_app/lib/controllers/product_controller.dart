import 'dart:convert';
import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_store_app/models/product.dart';
import 'package:vendor_store_app/services/manage_http_response.dart';
import 'package:http/http.dart' as http;
import 'package:vendor_store_app/views/global_variables.dart';
import 'dart:typed_data'; // Quan trọng cho Web
import 'package:flutter/foundation.dart' show kIsWeb; // Để check Web
import 'package:shared_preferences/shared_preferences.dart';

class ProductController {
  Future<void> uploadProduct({
    required String productName,
    required int productPrice,
    required int quantity,
    required String description,
    required String category,
    required String vendorId,
    required String fullName,
    required String subCategory,
    required List<XFile>? pickedImages, // Vẫn nhận File để tương thích code cũ
    required context,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('auth_token');
    if (pickedImages != null && pickedImages.isNotEmpty) {
      final cloudinary = CloudinaryPublic("detbxbjxd", "nodejs_vendor_app");
      List<String> images = [];

      try {
        for (var i = 0; i < pickedImages.length; i++) {
          CloudinaryResponse response;

          if (kIsWeb) {
            // Dành cho Web: đọc bytes từ đường dẫn
            final bytes = await pickedImages[i].readAsBytes();
            response = await cloudinary.uploadFile(
              CloudinaryFile.fromBytesData(
                bytes,
                identifier: pickedImages[i].path.split('/').last,
                folder: productName,
              ),
            );
          } else {
            // Dành cho Mobile: dùng đường dẫn file
            response = await cloudinary.uploadFile(
              CloudinaryFile.fromFile(
                pickedImages[i].path,
                folder: productName,
              ),
            );
          }
          images.add(response.secureUrl);
        }

        // Logic gửi lên server...
        final Product product = Product(
          id: '',
          productName: productName,
          productPrice: productPrice,
          quantity: quantity,
          description: description,
          category: category,
          vendorId: vendorId,
          fullName: fullName,
          subCategory: subCategory,
          images: images,
        );

        http.Response response = await http.post(
          Uri.parse("$uri/api/add-product"),
          body: jsonEncode(product.toMap()),
          headers: <String, String>{
            "Content-Type": "application/json; charset=UTF-8",
            'x-auth-token': token!,
          },
        );

        if (context.mounted) {
          manageHttpResponse(
            response: response,
            context: context,
            onSuccess: () {
              showSnackBar(context, 'Product Uploaded');
            },
          );
        }
      } catch (e) {
        showSnackBar(context, 'Error uploading: $e');
      }
    } else {
      showSnackBar(context, 'Select Image');
    }
  }
}

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

  // ================= CẦN THÊM MỚI =================

  // Hàm 2: Lấy toàn bộ sản phẩm của Vendor phục vụ màn hình chỉnh sửa sản phẩm
  Future<List<Product>> getVendorProducts({
    required String vendorId,
    required context,
  }) async {
    List<Product> productList = [];
    try {
      http.Response response = await http.get(
        Uri.parse("$uri/api/products/vendor/$vendorId"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      if (context.mounted) {
        manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () {
            // Kiểm tra và parse data từ backend trả về mảng danh sách sản phẩm
            final List<dynamic> data = jsonDecode(response.body);
            for (var item in data) {
              productList.add(Product.fromMap(item));
            }
          },
        );
      }
    } catch (e) {
      showSnackBar(context, 'Error loading products: $e');
    }
    return productList;
  }

  // Hàm 3: Chỉnh sửa sản phẩm hiện tại (Đồng bộ với Route PUT /api/edit-product/:productId)
  Future<void> updateProduct({
    required String productId,
    required String productName,
    required int productPrice,
    required int quantity,
    required String description,
    required String category,
    required String subCategory,
    required List<String> existingImages, // Giữ các ảnh cũ không thay đổi
    required List<XFile>?
    newPickedImages, // Ảnh mới chọn thêm từ Vendor App (nếu có)
    required String
    token, // THAY ĐỔI: Truyền trực tiếp token từ vendorProvider vào đây
    required context,
    required Function
    onSuccess, // Callback để reload UI sau khi cập nhật thành công
  }) async {
    try {
      // 1. Kiểm tra nếu token trống thì dừng lại luôn để tránh lỗi ClientException
      if (token.isEmpty) {
        showSnackBar(context, 'Phiên đăng nhập hết hạn. Vui lòng thử lại!');
        return;
      }

      List<String> finalImages = List.from(existingImages);

      // Nếu người dùng chọn thêm ảnh mới trong màn hình chỉnh sửa thì upload lên Cloudinary
      if (newPickedImages != null && newPickedImages.isNotEmpty) {
        final cloudinary = CloudinaryPublic("detbxbjxd", "nodejs_vendor_app");
        for (var i = 0; i < newPickedImages.length; i++) {
          CloudinaryResponse response;
          if (kIsWeb) {
            final bytes = await newPickedImages[i].readAsBytes();
            response = await cloudinary.uploadFile(
              CloudinaryFile.fromBytesData(
                bytes,
                identifier: newPickedImages[i].path.split('/').last,
                folder: productName,
              ),
            );
          } else {
            response = await cloudinary.uploadFile(
              CloudinaryFile.fromFile(
                newPickedImages[i].path,
                folder: productName,
              ),
            );
          }
          finalImages.add(response.secureUrl);
        }
      }

      // Xây dựng body dữ liệu gửi lên API chỉnh sửa
      final Map<String, dynamic> updateData = {
        'productName': productName,
        'productPrice': productPrice,
        'quantity': quantity,
        'description': description,
        'category': category,
        'subCategory': subCategory,
        'images': finalImages,
      };

      // Thực hiện gửi dữ liệu lên Server NodeJS
      http.Response response = await http.put(
        Uri.parse("$uri/api/edit-product/$productId"),
        body: jsonEncode(updateData),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          'x-auth-token': token, // Dùng token truyền từ Provider
        },
      );

      print("Dữ liệu thô từ Server: ${response.body}");

      if (context.mounted) {
        manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, 'Cập nhật sản phẩm thành công!');
            onSuccess(); // Kích hoạt callback refresh danh sách ở màn hình View
          },
        );
      }
    } catch (e) {
      showSnackBar(context, 'Lỗi khi cập nhật sản phẩm: $e');
    }
  }
}

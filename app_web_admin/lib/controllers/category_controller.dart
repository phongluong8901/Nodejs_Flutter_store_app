import 'dart:typed_data';
import 'package:app_web_admin/global_variable.dart';
import 'package:app_web_admin/models/category.dart';
import 'package:app_web_admin/services/manage_http_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryController {
  final String cloudName = 'detbxbjxd';
  final String uploadPreset = 'nodejs_store_app';

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
          filename: 'cat_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        final result = json.decode(
          utf8.decode(await response.stream.toBytes()),
        );
        return result['secure_url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Hàm mới để xử lý cả Cloud URL và Local File
  Future<void> uploadCategoryWithUrls({
    Uint8List? localImage,
    Uint8List? localBanner,
    String? cloudImage,
    String? cloudBanner,
    required String name,
    required context,
  }) async {
    try {
      // Ưu tiên chọn Cloud URL, nếu không có mới upload local
      String finalImageUrl =
          cloudImage ??
          (await uploadToCloudinary(localImage!, 'categories') ?? "");
      String finalBannerUrl =
          cloudBanner ??
          (localBanner != null
              ? await uploadToCloudinary(localBanner, 'banners') ?? ""
              : "");

      Category category = Category(
        id: "",
        name: name,
        image: finalImageUrl,
        banner: finalBannerUrl,
      );

      http.Response response = await http.post(
        Uri.parse("$uri/api/categories"),
        body: jsonEncode(category.toJson()),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Category saved successfully!');
        },
      );
    } catch (e) {
      showSnackBar(context, 'Error: $e', isSuccess: false);
    }
  }

  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse("$uri/api/categories"));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['categories'];
      return data.map((item) => Category.fromJson(item)).toList();
    }
    return [];
  }

  // Thêm vào CategoryController
  Future<List<String>> getBannerUrls() async {
    try {
      final response = await http.get(Uri.parse("$uri/api/banner"));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        // Giả sử server trả về list các object có trường 'image'
        return data.map((item) => item['image'] as String).toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }
}

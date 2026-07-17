import 'dart:convert';
import 'dart:typed_data';
import 'package:app_web_admin/global_variable.dart';
import 'package:app_web_admin/models/banner.dart'; // Đảm bảo bạn đã có Model Banner
import 'package:app_web_admin/services/manage_http_response.dart';
import 'package:http/http.dart' as http;

class BannerController {
  final String cloudName = 'detbxbjxd';
  final String uploadPreset = 'nodejs_store_app';

  // Upload to Cloudinary
  Future<String?> uploadToCloudinary(Uint8List bytes) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/upload',
      );
      var request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'banners';
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'banner_${DateTime.now().millisecondsSinceEpoch}.jpg',
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

  // Upload Banner to Server
  Future<void> uploadBanner({
    required Uint8List pickedImage,
    required context,
  }) async {
    try {
      String? imageUrl = await uploadToCloudinary(pickedImage);

      if (imageUrl == null) {
        showSnackBar(context, 'Banner upload failed!', isSuccess: false);
        return;
      }

      // Tạo đối tượng JSON đơn giản gửi lên server
      var bannerData = jsonEncode({'image': imageUrl});

      http.Response response = await http.post(
        Uri.parse("$uri/api/banner"),
        body: bannerData,
        headers: {"Content-Type": "application/json; charset=UTF-8"},
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Banner uploaded successfully!');
        },
      );
    } catch (e) {
      showSnackBar(context, 'Error: $e', isSuccess: false);
    }
  }

  // Fetch Banners
  Future<List<BannerModel>> getBanners() async {
    final response = await http.get(Uri.parse("$uri/api/banner"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => BannerModel.fromJson(item)).toList();
    }
    return [];
  }

  // load or get banner images

  Future<List<BannerModel>> loadBanners() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/banner'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<BannerModel> banners = data
            .map((banner) => BannerModel.fromJson(banner))
            .toList();
        return banners;
      } else {
        throw Exception('Failed to load banner');
      }
    } catch (e) {
      throw Exception('Error loading banner:$e');
    }
  }
}

import 'package:app_web_admin/controllers/banner_controller.dart';
import 'package:app_web_admin/models/banner.dart'; // Đã đổi tên model
import 'package:app_web_admin/services/manage_http_response.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BannerScreen extends StatefulWidget {
  static const String id = 'banner-screen';
  const BannerScreen({super.key});

  @override
  State<BannerScreen> createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> {
  final BannerController _bannerController = BannerController();
  List<BannerModel> _banners = [];
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    final data = await _bannerController.getBanners();
    if (mounted) setState(() => _banners = data);
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result != null) {
      setState(() => _image = result.files.first.bytes);
    }
  }

  Future<void> _saveBanner() async {
    if (_image == null) return;
    setState(() => _isLoading = true);
    await _bannerController.uploadBanner(
      pickedImage: _image!,
      context: context,
    );
    if (mounted) {
      setState(() {
        _isLoading = false;
        _image = null;
      });
      _fetchBanners();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Banners',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const Divider(thickness: 1, height: 30),

          // Vùng chọn ảnh
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 400,
                    height: 200, // Chiều cao banner
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _image != null
                        ? Image.memory(_image!, fit: BoxFit.cover)
                        : const Icon(Icons.add_photo_alternate, size: 50),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _image == null ? _pickImage : _saveBanner,
                    child: Text(
                      _image == null ? 'Pick Banner Image' : 'Save Banner',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
          const Text(
            'Banner List',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Grid hiển thị banner (tỷ lệ 3:1 hoặc 2:1 cho banner ngang)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _banners.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Banner to hơn nên để 2 cột
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 3, // Tỷ lệ rộng 3 : cao 1
            ),
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(_banners[index].image, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

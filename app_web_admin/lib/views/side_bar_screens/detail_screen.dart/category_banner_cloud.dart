import 'package:app_web_admin/controllers/category_controller.dart';
import 'package:app_web_admin/models/category.dart';
import 'package:flutter/material.dart';

class CloudLibraryDialog extends StatefulWidget {
  final bool isBanner;
  const CloudLibraryDialog({super.key, required this.isBanner});

  @override
  State<CloudLibraryDialog> createState() => _CloudLibraryDialogState();
}

class _CloudLibraryDialogState extends State<CloudLibraryDialog> {
  List<String> _cloudUrls = [];
  bool _isLoading = true;
  final CategoryController _controller = CategoryController();

  @override
  void initState() {
    super.initState();
    _loadCloudImages();
  }

  Future<void> _loadCloudImages() async {
    try {
      List<String> urls = [];

      if (widget.isBanner) {
        // GỌI ĐÚNG SERVICE BANNER
        urls = await _controller.getBannerUrls();
      } else {
        // GỌI SERVICE CATEGORY
        List<Category> categories = await _controller.getCategories();
        for (var cat in categories) {
          if (cat.image.isNotEmpty) urls.add(cat.image);
        }
      }

      if (mounted) {
        setState(() {
          _cloudUrls = urls.toSet().toList(); // Loại bỏ trùng lặp nếu có
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tùy chỉnh tỉ lệ khung hình theo loại ảnh
    double aspectRatio = widget.isBanner ? 2.0 : 1.0;
    int crossAxisCount = widget.isBanner ? 2 : 4;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.isBanner ? "Chọn Banner từ kho" : "Chọn Ảnh từ kho",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _cloudUrls.isEmpty
                  ? const Center(child: Text("Không có ảnh nào trong kho"))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: _cloudUrls.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () =>
                              Navigator.pop(context, _cloudUrls[index]),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blueAccent.withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _cloudUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

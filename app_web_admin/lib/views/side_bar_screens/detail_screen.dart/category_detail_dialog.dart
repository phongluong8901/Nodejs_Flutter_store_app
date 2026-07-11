import 'package:app_web_admin/models/category.dart';
import 'package:flutter/material.dart';

class CategoryDetailDialog extends StatelessWidget {
  final Category category;

  const CategoryDetailDialog({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        width: 450,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Header (Banner)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    category.banner.isNotEmpty
                        ? category.banner
                        : category.image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Nút đóng đặt trên ảnh
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                    ),
                  ),
                ),
              ],
            ),

            // 2. Nội dung Avatar và Tên
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Transform.translate(
                    offset: const Offset(0, -60), // Nổi avatar đè lên banner
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage(category.image),
                      ),
                    ),
                  ),

                  // Tên danh mục (Đẩy lên cao vì avatar bị dịch chuyển)
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Column(
                      children: [
                        Text(
                          category.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text(
                          "Thông tin chi tiết về danh mục này sẽ được cập nhật tại đây.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

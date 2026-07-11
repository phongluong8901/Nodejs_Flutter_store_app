import 'dart:ui'; // Bắt buộc cho BackdropFilter
import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140, // Điều chỉnh độ cao cho phù hợp
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/icons/searchBanner.jpeg',
          ), // File ảnh nền của bạn
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        children: [
          // 1. Thanh tìm kiếm Glassmorphism
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Hiệu ứng mờ
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // Độ trong suốt
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ), // Viền trắng mờ
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter text', // HintText của bạn
                      hintStyle: const TextStyle(
                        color: Colors.white70,
                      ), // Màu hint text
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ), // Icon tìm kiếm màu trắng
                      suffixIcon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                      ), // Icon camera màu trắng
                      border:
                          InputBorder.none, // Xóa viền mặc định của TextField
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ), // Căn giữa nội dung
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 2. Các nút Icon (Bấm được và đẹp hơn)
          _buildClickableIconCircle(Icons.notifications_none, () {
            // Xử lý khi nhấn vào Chuông
            print("Đã click Chuông!");
          }),
          const SizedBox(width: 8),
          _buildClickableIconCircle(Icons.chat_bubble_outline, () {
            // Xử lý khi nhấn vào Message
            print("Đã click Message!");
          }),
        ],
      ),
    );
  }

  // Widget bo tròn icon, bấm được và có hiệu ứng ripple
  Widget _buildClickableIconCircle(IconData icon, VoidCallback onTap) {
    return Container(
      width: 44, // Điều chỉnh kích thước vùng chứa
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // Màu trong suốt
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ), // Viền trắng mờ
      ),
      child: Material(
        color: Colors.transparent, // Material transparent để InkWell hoạt động
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22), // Bo góc cho hiệu ứng ripple
          child: Icon(icon, color: Colors.white, size: 22), // Icon màu trắng
        ),
      ),
    );
  }
}

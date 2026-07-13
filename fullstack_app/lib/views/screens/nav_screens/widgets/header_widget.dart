import 'dart:ui'; // Bắt buộc cho BackdropFilter
import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final VoidCallback? onBack; // Thêm tham số này

  const HeaderWidget({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/icons/searchBanner.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        children: [
          // Kiểm tra nếu có onBack thì hiển thị nút quay lại
          if (onBack != null) ...[
            _buildClickableIconCircle(Icons.arrow_back, onBack!),
            const SizedBox(width: 12),
          ],

          // Thanh tìm kiếm
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter text',
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      suffixIcon: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Các nút khác
          _buildClickableIconCircle(Icons.notifications_none, () {}),
          const SizedBox(width: 8),
          _buildClickableIconCircle(Icons.chat_bubble_outline, () {}),
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

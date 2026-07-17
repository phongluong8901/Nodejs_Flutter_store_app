import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_store_app/controllers/vendor_auth_controller.dart';
import 'package:vendor_store_app/provider/vendor_provider.dart';
import 'package:vendor_store_app/views/screens/nav_screens/orders_screen.dart';

class VendorProfileScreen extends ConsumerStatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  _VendorProfileScreenState createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends ConsumerState<VendorProfileScreen> {
  final VendorAuthController _vendorAuthController = VendorAuthController();

  // Dialog Đăng Xuất Cao Cấp
  void showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          actionsPadding: const EdgeInsets.all(16),
          title: Text(
            'Đăng xuất tài khoản?',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng của nhà bán hàng không?',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[200]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Hủy',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _vendorAuthController.signOutuser(
                        context: context,
                        ref: ref,
                      );
                    },
                    child: Text(
                      "Đăng xuất",
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Hàm "Vẽ Tay" Từng Dòng Menu Tinh Tế
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDanger ? Colors.red[50]?.withOpacity(0.4) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDanger ? Colors.red[100]! : Colors.grey[100]!,
            width: 1,
          ),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDanger ? Colors.red[100] : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDanger ? Colors.redAccent : color,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDanger ? Colors.red[700] : Colors.black87,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: isDanger ? Colors.red[300] : Colors.grey[400],
            size: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(vendorProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- HEADER VẼ TAY HIỆN ĐẠI ---
            Stack(
              alignment: Alignment.center,
              children: [
                // Khối Gradient Background bo cong phía dưới
                Container(
                  height: 280,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                ),

                // Icon Thông báo phía trên
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),

                // Block Avatar & Thông tin User ở tâm Header
                Positioned(
                  bottom: 30,
                  child: Column(
                    children: [
                      // Avatar với Khung viền nổi bật
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                "https://cdn.pixabay.com/photo/2014/04/03/10/32/businessman-310819_1280.png",
                              ),
                            ),
                          ),
                          // Nút Chỉnh sửa ảnh thu nhỏ
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.deepPurple,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Tên Vendor
                      Text(
                        (user?.fullName != null && user!.fullName.isNotEmpty)
                            ? user.fullName
                            : 'Nhà bán hàng',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Email/Số Điện thoại hoặc Trạng thái
                      Text(
                        (user?.state != null && user!.state.isNotEmpty)
                            ? 'Khu vực: ${user.state}'
                            : 'Khu vực hoạt động',
                        style: GoogleFonts.montserrat(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // --- PHẦN THÂN: DANH SÁCH MENU ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quản lý bán hàng',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildMenuItem(
                    icon: Icons.local_shipping_outlined,
                    title: 'Theo dõi đơn hàng',
                    color: Colors.deepPurple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderScreen(),
                        ),
                      );
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.history_rounded,
                    title: 'Lịch sử giao dịch',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),
                  const Text(
                    'Cài đặt tài khoản',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Đăng xuất tài khoản',
                    color: Colors.amber[800]!,
                    onTap: () => showSignOutDialog(context),
                  ),

                  _buildMenuItem(
                    icon: Icons.delete_forever_rounded,
                    title: 'Xóa vĩnh viễn tài khoản',
                    color: Colors.redAccent,
                    isDanger: true,
                    onTap: () {
                      // Logic xóa tài khoản nếu cần thiết
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

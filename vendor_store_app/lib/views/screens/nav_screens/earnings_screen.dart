import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_store_app/controllers/order_controller.dart';
import 'package:vendor_store_app/provider/order_provider.dart';
import 'package:vendor_store_app/provider/total_earnings_provider.dart';
import 'package:vendor_store_app/provider/vendor_provider.dart';
import 'package:intl/intl.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  _EarningsScreenState createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Hàm tải dữ liệu doanh thu & đơn hàng
  Future<void> _fetchOrders() async {
    final user = ref.read(vendorProvider);
    if (user != null) {
      setState(() {
        _isLoading = true;
      });
      final OrderController orderController = OrderController();
      try {
        final orders = await orderController.loadOrders(vendorId: user.id);
        ref.read(orderProvider.notifier).setOrders(orders);
        ref.read(totalEarningsProvider.notifier).calculateEarnings(orders);
      } catch (e) {
        debugPrint("Error fetching orders: $e");
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendor = ref.watch(vendorProvider);
    final totalEarning = ref.watch(totalEarningsProvider);

    // Định dạng tiền tệ đẹp mắt (ví dụ: $1,250.00 hoặc có thể đổi sang VND tùy ý)
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2);
    final totalEarningsValue = totalEarning['totalEarnings'] ?? 0.0;
    final totalOrdersValue = totalEarning['totalOrders'] ?? 0;

    return Scaffold(
      backgroundColor:
          Colors.grey[50], // Nền xám nhạt cao cấp giúp các thẻ nổi bật hơn
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            // Avatar với viền Gradient siêu mỏng tinh tế
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Text(
                  vendor?.fullName.isNotEmpty == true
                      ? vendor!.fullName[0].toUpperCase()
                      : 'V',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Tên chào mừng gọn gàng
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Xin chào!",
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    vendor?.fullName ?? "Nhà bán hàng",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _fetchOrders,
            icon: const Icon(Icons.refresh_rounded, color: Colors.deepPurple),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        color: Colors.deepPurple,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề trang
                    Text(
                      "Tổng quan doanh thu",
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- CARD HERO: TỔNG DOANH THU (GRADIENT) ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.deepPurple, Colors.purpleAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "TỔNG DOANH THU",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currencyFormat.format(totalEarningsValue),
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Cập nhật trực tiếp từ hệ thống",
                            style: GoogleFonts.montserrat(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- GRID CÁC CHỈ SỐ PHỤ THỐNG KÊ ---
                    Row(
                      children: [
                        // Thẻ thống kê tổng số đơn hàng
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey[100]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Colors.blue[600],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Tổng đơn hàng",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$totalOrdersValue',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Thẻ thống kê hiệu suất hoặc hiệu quả (Mẫu thêm vào để giao diện cân đối)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey[100]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.trending_up_rounded,
                                    color: Colors.green[600],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Hiệu suất bán",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Ổn định",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // --- CHÚ THÍCH / GỢI Ý MẸO CHO VENDOR ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[50]?.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.deepPurple[100]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: Colors.deepPurple[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Bí quyết: Xử lý đơn hàng nhanh chóng giúp cải thiện uy tín cửa hàng và tăng trưởng doanh thu đáng kể!",
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.deepPurple[900],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

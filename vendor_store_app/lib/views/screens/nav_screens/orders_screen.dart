import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_store_app/controllers/order_controller.dart';
import 'package:vendor_store_app/models/order.dart';
import 'package:vendor_store_app/provider/order_provider.dart';
import 'package:vendor_store_app/provider/vendor_provider.dart';
import 'package:vendor_store_app/views/screens/detail/screens/order_detail_screen.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch dữ liệu sau khi màn hình dựng xong để tránh xung đột state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders();
    });
  }

  Future<void> _fetchOrders() async {
    final user = ref.read(vendorProvider);
    if (user != null) {
      final OrderController orderController = OrderController();
      try {
        final orders = await orderController.loadOrders(vendorId: user.id);
        if (mounted) {
          ref.read(orderProvider.notifier).setOrders(orders);
        }
      } catch (e) {
        debugPrint("Error fetching orders: $e");
      }
    }
  }

  Future<void> _deleteOrder(String orderId) async {
    final OrderController orderController = OrderController();
    try {
      await orderController.deleteOrder(id: orderId, context: context);
      if (mounted) {
        _fetchOrders(); // Reload lại danh sách
      }
    } catch (e) {
      debugPrint("Error deleting order: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);

    // Sử dụng bảng màu Deep Purple cao cấp đồng bộ với màn hình Edit/Profile
    const Color primaryColor = Colors.deepPurple;
    final Color cardBackground =
        Colors.white; // Hoặc dùng màu nền card của app bạn
    final Color textPrimary = Colors.grey.shade900;
    final Color textSecondary = Colors.grey.shade600;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FE,
      ), // Nền xám trắng nhạt cực kỳ sạch sẽ và cao cấp
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          'My Orders',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        actions: [
          // Nút chuông thông báo tối giản, không dùng hình ảnh cứng
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: textPrimary,
                    size: 26,
                  ),
                ),
                if (orders.isNotEmpty)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: orders.isEmpty
          ? Center(
              child: Text(
                'No Orders Found',
                style: GoogleFonts.montserrat(
                  color: textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.builder(
              itemCount: orders.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final Order order = orders[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailScreen(order: order),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. ẢNH SẢN PHẨM: Bo góc tròn mượt, background nhạt
                            Container(
                              width: 85,
                              height: 85,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  order.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.image_outlined,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // 2. CHI TIẾT ĐƠN HÀNG
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Trạng thái đơn hàng kiểu Badge tối giản mềm mại
                                      _buildStatusBadge(order, primaryColor),

                                      // Nút xóa gọn gàng bằng Icon gốc
                                      IconButton(
                                        onPressed: () => _deleteOrder(order.id),
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.red.shade400,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    order.productName,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    order.category,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      color: textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "\$${order.productPrice.toStringAsFixed(2)}",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          primaryColor, // Nhấn giá bằng tông Deep Purple cực sang
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Hàm helper vẽ Tag trạng thái đồng nhất phong cách hiện đại
  Widget _buildStatusBadge(Order order, Color primaryColor) {
    Color badgeColor;
    String statusText;

    if (order.delivered == true) {
      badgeColor = const Color(0xFF10B981); // Xanh lá tinh tế
      statusText = "Delivered";
    } else if (order.processing == true) {
      badgeColor = primaryColor; // Dùng màu Deep Purple chủ đạo cho Processing
      statusText = "Processing";
    } else {
      badgeColor = const Color(0xFFEF4444); // Đỏ pastel nhạt
      statusText = "Cancelled";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withOpacity(0.2), width: 1),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.montserrat(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

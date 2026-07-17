import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_store_app/controllers/order_controller.dart';
import 'package:vendor_store_app/models/order.dart';
import 'package:vendor_store_app/provider/order_provider.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  final OrderController _orderController = OrderController();

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);

    // Tìm order hiện tại từ provider để đảm bảo UI luôn đồng bộ
    final currentOrder = orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    // Hệ màu đồng bộ thương hiệu
    const Color primaryColor = Colors.deepPurple;
    final Color textPrimary = Colors.grey.shade900;
    final Color textSecondary = Colors.grey.shade600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Nền xám nhạt cao cấp
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Details',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. THÀNH PHẦN THÔNG TIN SẢN PHẨM ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh sản phẩm bo góc 12px có nền nhạt cực sang
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            currentOrder.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Chi tiết Text bên phải
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentOrder.productName,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentOrder.category,
                              style: GoogleFonts.montserrat(
                                color: textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "\$${currentOrder.productPrice.toStringAsFixed(2)}",
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Color(0xFFF1F3F9), height: 1),
                  ),
                  // Trạng thái đơn hàng dạng Badge tinh giản
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Status",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                      _buildStatusBadge(currentOrder, primaryColor),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 2. ĐỊA CHỈ GIAO HÀNG (DELIVERY ADDRESS) ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        color: primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Delivery Address',
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Họ tên người nhận nổi bật
                  Text(
                    currentOrder.fullName,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Địa chỉ chi tiết dễ đọc
                  Text(
                    "${currentOrder.locality}, ${currentOrder.city}, ${currentOrder.state}",
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 3. NÚT XỬ LÝ HÀNH ĐỘNG (Dưới cùng) ---
            if (currentOrder.processing) ...[
              Row(
                children: [
                  // Nút Cancel (Màu đỏ nhạt, viền tinh tế)
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.red.shade200,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: Colors.red.shade600,
                        ),
                        onPressed: () async {
                          await _orderController.cancelOrder(
                            id: currentOrder.id,
                            context: context,
                          );
                          ref
                              .read(orderProvider.notifier)
                              .updateOrderStatus(
                                currentOrder.id,
                                processing: false,
                                delivered: false,
                              );
                        },
                        child: Text(
                          "Cancel Order",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nút Delivered (Màu Deep Purple thương hiệu)
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await _orderController.updateDeliveryStatus(
                            id: currentOrder.id,
                            context: context,
                          );
                          ref
                              .read(orderProvider.notifier)
                              .updateOrderStatus(
                                currentOrder.id,
                                processing: false,
                                delivered: true,
                              );
                        },
                        child: Text(
                          "Set Delivered",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Hàm helper vẽ Tag trạng thái tối giản cao cấp (như màn hình trước)
  Widget _buildStatusBadge(Order order, Color primaryColor) {
    Color badgeColor;
    String statusText;

    if (order.delivered == true) {
      badgeColor = const Color(0xFF10B981); // Xanh lá
      statusText = "Delivered";
    } else if (order.processing == true) {
      badgeColor = primaryColor; // Tím chủ đạo
      statusText = "Processing";
    } else {
      badgeColor = const Color(0xFFEF4444); // Đỏ
      statusText = "Cancelled";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withOpacity(0.2), width: 1),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.montserrat(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

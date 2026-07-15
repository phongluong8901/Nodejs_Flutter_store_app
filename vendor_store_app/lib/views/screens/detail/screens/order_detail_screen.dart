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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentOrder.productName,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HÌNH ẢNH & THÔNG TIN ---
            Container(
              width: 335,
              height: 153,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFEFF0F2)),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 13,
                    top: 9,
                    child: Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBCC5FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.network(
                        currentOrder.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 101,
                    top: 14,
                    child: SizedBox(
                      width: 216,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentOrder.productName,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            currentOrder.category,
                            style: GoogleFonts.montserrat(
                              color: const Color(0xFF7F808C),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "\$${currentOrder.productPrice.toStringAsFixed(2)}",
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 13,
                    top: 113,
                    child: Container(
                      width: 100,
                      height: 25,
                      decoration: BoxDecoration(
                        color: currentOrder.delivered
                            ? const Color(0xFF3C55EF)
                            : currentOrder.processing
                            ? Colors.purple
                            : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          currentOrder.delivered
                              ? "Delivered"
                              : currentOrder.processing
                              ? "Processing"
                              : "Cancelled",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- ĐỊA CHỈ & HÀNH ĐỘNG ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 336,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFEFF0F2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Address',
                      style: GoogleFonts.montserrat(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${currentOrder.state} ${currentOrder.city} ${currentOrder.locality}",
                    ),
                    Text(
                      "To : ${currentOrder.fullName}",
                      style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),

                    // Nút bấm: Sử dụng null để làm mờ (disabled)
                    if (currentOrder.processing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: currentOrder.delivered
                                ? null
                                : () async {
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
                            child: const Text("Delivered"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
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
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

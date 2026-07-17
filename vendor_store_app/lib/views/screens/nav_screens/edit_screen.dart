import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_store_app/controllers/product_controller.dart';
import 'package:vendor_store_app/models/product.dart';
import 'package:vendor_store_app/provider/vendor_product_provider.dart';
import 'package:vendor_store_app/provider/vendor_provider.dart';
import 'package:vendor_store_app/views/screens/detail/screens/edit_detail_screen.dart';

class EditScreen extends ConsumerStatefulWidget {
  const EditScreen({super.key});

  @override
  ConsumerState<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends ConsumerState<EditScreen> {
  final ProductController _productController = ProductController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVendorProducts();
    });
  }

  Future<void> _loadVendorProducts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final vendor = ref.read(vendorProvider);
    final String vendorId = vendor?.id ?? '';

    if (vendorId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Text(
              'Không tìm thấy thông tin Vendor. Vui lòng đăng nhập lại.',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
            ),
          ),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    try {
      List<Product> fetchedProducts = await _productController
          .getVendorProducts(vendorId: vendorId, context: context);
      if (mounted) {
        ref.read(productProvider.notifier).setProducts(fetchedProducts);
      }
    } catch (e) {
      debugPrint("Error loading vendor products: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);

    // Bảng màu hệ thống đồng nhất
    const Color primaryColor = Colors.deepPurple;
    final Color textPrimary = Colors.grey.shade900;
    final Color textSecondary = Colors.grey.shade600;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FE,
      ), // Nền xám trắng nhạt đồng bộ cao cấp
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          'Quản lý sản phẩm',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        actions: [
          // Nút refresh mượt mà hơn với Icon của hệ thống mới
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.sync_rounded, color: textPrimary, size: 24),
              onPressed: _loadVendorProducts,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                strokeWidth: 3,
              ),
            )
          : products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bạn chưa đăng bán sản phẩm nào.',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      color: textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: products.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final product = products[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VendorEditDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // 1. ẢNH SẢN PHẨM: Bo góc mượt 12px, có màu nền mờ sang trọng
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: product.images.isNotEmpty
                                    ? Image.network(
                                        product.images[0],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                                color: Colors.grey,
                                              );
                                            },
                                      )
                                    : const Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // 2. THÔNG TIN CHI TIẾT SẢN PHẨM
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.productName,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // Nhãn số lượng tồn kho tinh giản
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.widgets_outlined,
                                        size: 13,
                                        color: textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Tồn kho: ${product.quantity}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          color: textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Giá tiền nổi bật với màu Deep Purple
                                  Text(
                                    "\$${product.productPrice.toStringAsFixed(2)}",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 3. NÚT EDIT (Tối giản với vòng tròn icon mảnh cao cấp)
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                color: primaryColor,
                                size: 18,
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
}

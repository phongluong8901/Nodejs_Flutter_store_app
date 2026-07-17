import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_store_app/controllers/product_controller.dart';
import 'package:vendor_store_app/models/product.dart';
import 'package:vendor_store_app/provider/vendor_product_provider.dart';
import 'package:vendor_store_app/provider/vendor_provider.dart';

class VendorEditDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const VendorEditDetailScreen({Key? key, required this.product})
    : super(key: key);

  @override
  ConsumerState<VendorEditDetailScreen> createState() =>
      _VendorEditDetailScreenState();
}

class _VendorEditDetailScreenState
    extends ConsumerState<VendorEditDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductController _productController = ProductController();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _subCategoryController;

  List<XFile> _newPickedImages = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.productName);
    _priceController = TextEditingController(
      text: widget.product.productPrice.toString(),
    );
    _quantityController = TextEditingController(
      text: widget.product.quantity.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.product.description,
    );
    _categoryController = TextEditingController(text: widget.product.category);
    _subCategoryController = TextEditingController(
      text: widget.product.subCategory,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _subCategoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        _newPickedImages.addAll(selectedImages);
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newPickedImages.removeAt(index);
    });
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final int newPrice = int.parse(_priceController.text.trim());
    final int newQuantity = int.parse(_quantityController.text.trim());

    final vendor = ref.read(vendorProvider);
    final String token = vendor?.token ?? '';

    await _productController.updateProduct(
      productId: widget.product.id,
      productName: _nameController.text.trim(),
      productPrice: newPrice,
      quantity: newQuantity,
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      subCategory: _subCategoryController.text.trim(),
      existingImages: widget.product.images,
      newPickedImages: _newPickedImages.isEmpty ? null : _newPickedImages,
      token: token,
      context: context,
      onSuccess: () {
        final updatedProduct = Product(
          id: widget.product.id,
          productName: _nameController.text.trim(),
          productPrice: newPrice,
          quantity: newQuantity,
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim(),
          vendorId: widget.product.vendorId,
          fullName: widget.product.fullName,
          subCategory: _subCategoryController.text.trim(),
          images: widget.product.images,
        );

        ref.read(productProvider.notifier).updateSingleProduct(updatedProduct);

        if (mounted) {
          Navigator.pop(context);
        }
      },
    );

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(prefixIcon, color: Colors.deepPurple[400], size: 22),
          filled: true,
          fillColor: Colors.grey[50],
          alignLabelWithHint: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Chỉnh sửa sản phẩm',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[100], height: 1),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PHẦN HÌNH ẢNH ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hình ảnh sản phẩm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _isSaving ? null : _pickImages,
                        icon: const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 18,
                        ),
                        label: const Text('Thêm ảnh'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Gallery xem trước ảnh
                  Container(
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    padding: const EdgeInsets.all(12),
                    child:
                        (widget.product.images.isEmpty &&
                            _newPickedImages.isEmpty)
                        ? Center(
                            child: Text(
                              'Không có hình ảnh nào',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          )
                        : ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              // Vẽ danh sách ảnh cũ (Online)
                              ...widget.product.images.map((url) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        url,
                                        width: 86,
                                        height: 86,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 86,
                                                  color: Colors.grey[100],
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),

                              // Vẽ danh sách ảnh mới chọn (Local) có nút xóa nhanh
                              ..._newPickedImages.asMap().entries.map((entry) {
                                int idx = entry.key;
                                XFile file = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.file(
                                            File(file.path),
                                            width: 86,
                                            height: 86,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: () => _removeNewImage(idx),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                  ),
                  const SizedBox(height: 25),

                  // --- PHẦN THÔNG TIN CHI TIẾT ---
                  const Text(
                    'Thông tin cơ bản',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildTextField(
                    controller: _nameController,
                    label: 'Tên sản phẩm*',
                    prefixIcon: Icons.shopping_bag_outlined,
                    validator: (val) => val == null || val.isEmpty
                        ? 'Vui lòng điền tên sản phẩm'
                        : null,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _priceController,
                          label: 'Giá bán*',
                          prefixIcon: Icons.attach_money_rounded,
                          keyboardType: TextInputType.number,
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Nhập giá' : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildTextField(
                          controller: _quantityController,
                          label: 'Số lượng kho*',
                          prefixIcon: Icons.inventory_2_outlined,
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || val.isEmpty
                              ? 'Nhập số lượng'
                              : null,
                        ),
                      ),
                    ],
                  ),

                  _buildTextField(
                    controller: _categoryController,
                    label: 'Danh mục',
                    prefixIcon: Icons.grid_view_rounded,
                  ),

                  _buildTextField(
                    controller: _subCategoryController,
                    label: 'Danh mục phụ',
                    prefixIcon: Icons.layers_outlined,
                  ),

                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Mô tả chi tiết sản phẩm',
                    prefixIcon: Icons.description_outlined,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // --- NÚT LƯU GRADIENT CỐ ĐỊNH Ở DƯỚI CÙNG ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : _submitUpdate,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    height: 54,
                    alignment: Alignment.center,
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save_as_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Lưu Thay Đổi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

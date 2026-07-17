import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_store_app/controllers/category_controller.dart';
import 'package:vendor_store_app/controllers/product_controller.dart';
import 'package:vendor_store_app/controllers/subcategory_controller.dart';
import 'package:vendor_store_app/models/category.dart';
import 'package:vendor_store_app/models/subcategory.dart';
import 'package:vendor_store_app/provider/vendor_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProductController _productController = ProductController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  late Future<List<CategoryModel>> futureCategories;
  Future<List<Subcategory>>? futureSubcategories;
  CategoryModel? selectedCategory;
  Subcategory? selectedSubcategory;

  bool isLoading = false;
  final ImagePicker picker = ImagePicker();
  List<XFile> images = [];

  @override
  void initState() {
    super.initState();
    futureCategories = CategoryController().loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descController.dispose();
    super.dispose();
  }

  chooseImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => images.add(pickedFile));
    }
  }

  void removeImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  void getSubcategoryByCategory(value) {
    setState(() {
      selectedSubcategory = null;
      futureSubcategories = SubcategoryController()
          .getSubCategoriesByCategoryName(value.name);
    });
  }

  // Hàm vẽ chung cho thiết kế của các Input Field
  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey[600],
      ),
      prefixIcon: Icon(prefixIcon, color: Colors.deepPurple, size: 20),
      suffixText: suffixText,
      suffixStyle: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendorData = ref.read(vendorProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Thêm sản phẩm",
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề phần chọn ảnh
              Text(
                "Hình ảnh sản phẩm",
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // --- GRID SELECTION ẢNH ĐẸP MẮT ---
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: images.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Thẻ thêm ảnh (Dashed-style look)
                    return GestureDetector(
                      onTap: chooseImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.deepPurple.withOpacity(0.3),
                            style: BorderStyle.solid,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Colors.deepPurple,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Thêm ảnh",
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Các ảnh đã được chọn có nút xóa nhanh
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: kIsWeb
                              ? Image.network(
                                  images[index - 1].path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(images[index - 1].path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => removeImage(index - 1),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 25),

              // Tiêu đề phần thông tin chi tiết
              Text(
                "Thông tin chi tiết",
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // --- PHÂN LOẠI (DROPDOWN) CHỌN CATEGORY ---
              FutureBuilder<List<CategoryModel>>(
                future: futureCategories,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Center(
                        child: LinearProgressIndicator(
                          color: Colors.deepPurple,
                        ),
                      ),
                    );
                  }
                  return DropdownButtonFormField<CategoryModel>(
                    dropdownColor: Colors.white,
                    style: GoogleFonts.montserrat(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                    decoration: _buildInputDecoration(
                      labelText: 'Danh mục chính',
                      prefixIcon: Icons.category_outlined,
                    ),
                    items: snapshot.data!
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              c.name,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() => selectedCategory = v);
                      getSubcategoryByCategory(v);
                    },
                    validator: (v) =>
                        v == null ? 'Vui lòng chọn danh mục chính' : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // --- PHÂN LOẠI (DROPDOWN) CHỌN SUBCATEGORY ---
              if (futureSubcategories != null) ...[
                FutureBuilder<List<Subcategory>>(
                  future: futureSubcategories,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Center(
                          child: LinearProgressIndicator(
                            color: Colors.deepPurple,
                          ),
                        ),
                      );
                    }
                    return DropdownButtonFormField<Subcategory>(
                      dropdownColor: Colors.white,
                      style: GoogleFonts.montserrat(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      decoration: _buildInputDecoration(
                        labelText: 'Danh mục phụ',
                        prefixIcon: Icons.layers_outlined,
                      ),
                      items: snapshot.data!
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s.subCategoryName,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedSubcategory = v),
                      validator: (v) =>
                          v == null ? 'Vui lòng chọn danh mục phụ' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // --- TÊN SẢN PHẨM ---
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _buildInputDecoration(
                  labelText: 'Tên sản phẩm',
                  prefixIcon: Icons.shopping_bag_outlined,
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Vui lòng nhập tên sản phẩm' : null,
              ),
              const SizedBox(height: 16),

              // --- GIÁ CẢ & SỐ LƯỢNG (ROW) ---
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _buildInputDecoration(
                        labelText: 'Giá bán',
                        prefixIcon: Icons.attach_money_rounded,
                        suffixText: '\$',
                      ),
                      validator: (v) => v!.isEmpty ? 'Nhập giá' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _buildInputDecoration(
                        labelText: 'Số lượng',
                        prefixIcon: Icons.inventory_2_outlined,
                      ),
                      validator: (v) => v!.isEmpty ? 'Nhập kho' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- MÔ TẢ SẢN PHẨM ---
              TextFormField(
                controller: _descController,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                maxLength: 500,
                maxLines: 4,
                decoration: _buildInputDecoration(
                  labelText: 'Mô tả chi tiết',
                  prefixIcon: Icons.description_outlined,
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Vui lòng nhập mô tả sản phẩm' : null,
              ),
              const SizedBox(height: 30),

              // --- NÚT SUBMIT ĐĂNG TẢI GRADIENT ĐẲNG CẤP ---
              GestureDetector(
                onTap: () async {
                  if (vendorData == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Vui lòng đăng nhập trước!"),
                      ),
                    );
                    return;
                  }
                  if (selectedCategory == null || selectedSubcategory == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Hãy chọn đầy đủ Danh mục chính và phụ!"),
                      ),
                    );
                    return;
                  }
                  if (images.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Vui lòng chọn ít nhất 1 ảnh sản phẩm!"),
                      ),
                    );
                    return;
                  }

                  if (_formKey.currentState!.validate()) {
                    setState(() => isLoading = true);
                    await _productController.uploadProduct(
                      productName: _nameController.text,
                      productPrice: int.tryParse(_priceController.text) ?? 0,
                      quantity: int.tryParse(_quantityController.text) ?? 0,
                      description: _descController.text,
                      category: selectedCategory!.name,
                      vendorId: vendorData.id,
                      fullName: vendorData.fullName,
                      subCategory: selectedSubcategory!.subCategoryName,
                      pickedImages: images,
                      context: context,
                    );
                    if (mounted) {
                      setState(() {
                        isLoading = false;
                        // Reset form sau khi tải thành công
                        images.clear();
                        _nameController.clear();
                        _priceController.clear();
                        _quantityController.clear();
                        _descController.clear();
                        selectedCategory = null;
                        selectedSubcategory = null;
                      });
                    }
                  }
                },
                child: Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            "ĐĂNG TẢI SẢN PHẨM",
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}

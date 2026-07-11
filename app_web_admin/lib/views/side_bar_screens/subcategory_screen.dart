import 'dart:typed_data';
import 'package:app_web_admin/controllers/category_controller.dart';
import 'package:app_web_admin/controllers/subcategory_controller.dart';
import 'package:app_web_admin/models/category.dart';
import 'package:app_web_admin/models/subcategory.dart';
import 'package:app_web_admin/views/side_bar_screens/detail_screen.dart/category_banner_cloud.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SubCategoryScreen extends StatefulWidget {
  static const String id = 'subcategory-screen';
  const SubCategoryScreen({super.key});

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  final CategoryController _categoryController = CategoryController();
  final SubCategoryController _subCategoryController = SubCategoryController();

  List<Category> _categories = [];
  List<SubCategory> _subCategories = [];
  Category? _selectedCategory;
  Uint8List? _image;
  String? _selectedImageUrl;
  String _subCategoryName = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final categories = await _categoryController.getCategories();
    if (mounted) setState(() => _categories = categories);
  }

  Future<void> _fetchSubCategories(String categoryName) async {
    setState(() => _isLoading = true); // Thêm loading nếu cần
    final data = await _subCategoryController.getSubCategories(categoryName);

    if (mounted) {
      setState(() {
        _subCategories = data;
        _isLoading = false;
      });
      // Kiểm tra log để biết tại sao không hiển thị
      print("Số lượng subcategory nhận được: ${_subCategories.length}");
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) {
      setState(() {
        _image = result.files.first.bytes;
        _selectedImageUrl = null;
      });
    }
  }

  void _handleCloudSelection() async {
    final String? url = await showDialog<String>(
      context: context,
      builder: (context) => const CloudLibraryDialog(isBanner: false),
    );
    if (url != null) {
      setState(() {
        _selectedImageUrl = url;
        _image = null;
      });
    }
  }

  Future<void> _saveSubCategory() async {
    if (_selectedCategory == null ||
        _subCategoryName.isEmpty ||
        (_image == null && _selectedImageUrl == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields!")));
      return;
    }

    setState(() => _isLoading = true);
    await _subCategoryController.uploadSubCategory(
      categoryId: _selectedCategory!.id,
      categoryName: _selectedCategory!.name,
      subCategoryName: _subCategoryName,
      image: _image,
      context: context,
    );
    setState(() => _isLoading = false);
    if (_selectedCategory != null) _fetchSubCategories(_selectedCategory!.name);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sub-Category Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const Divider(height: 40, thickness: 1),
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  DropdownButtonFormField<Category>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categories
                        .map(
                          (e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedCategory = val);
                      if (val != null) _fetchSubCategories(val.name);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildImagePicker(),
                  const SizedBox(height: 20),
                  TextFormField(
                    onChanged: (val) => _subCategoryName = val,
                    decoration: const InputDecoration(
                      labelText: 'Sub-Category Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveSubCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'SAVE SUB-CATEGORY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Existing Sub-Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _subCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final sub = _subCategories[index];
              // Sửa lỗi URL bị dấu cách ở đây
              final cleanUrl = sub.image.replaceAll(' ', '');
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          cleanUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        sub.subCategoryName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _image != null
                ? Image.memory(_image!, fit: BoxFit.cover)
                : (_selectedImageUrl != null
                      ? Image.network(
                          _selectedImageUrl!.replaceAll(' ', ''),
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image, size: 40, color: Colors.grey)),
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload),
                label: const Text("Local Image"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _handleCloudSelection,
                icon: const Icon(Icons.cloud),
                label: const Text("Cloud Library"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

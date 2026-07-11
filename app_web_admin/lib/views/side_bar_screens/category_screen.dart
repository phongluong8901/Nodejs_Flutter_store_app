import 'package:app_web_admin/controllers/category_controller.dart';
import 'package:app_web_admin/models/category.dart';
import 'package:app_web_admin/services/manage_http_response.dart';
import 'package:app_web_admin/views/side_bar_screens/detail_screen.dart/category_banner_cloud.dart';
import 'package:app_web_admin/views/side_bar_screens/detail_screen.dart/category_detail_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  static const String id = 'category-screen';
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CategoryController _categoryController = CategoryController();

  List<Category> _categories = [];
  String categoryName = '';
  Uint8List? _image;
  Uint8List? _bannerImage;
  bool _isLoading = false;

  String? _selectedImageUrl;
  String? _selectedBannerUrl;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final data = await _categoryController.getCategories();
    if (mounted) setState(() => _categories = data);
  }

  void _handleCloudSelection(bool isBanner) async {
    final String? url = await showDialog<String>(
      context: context,
      builder: (context) =>
          CloudLibraryDialog(isBanner: isBanner), // Truyền cờ vào đây
    );

    if (url != null) {
      setState(() {
        if (isBanner) {
          _selectedBannerUrl = url;
          _bannerImage = null; // Reset local image
        } else {
          _selectedImageUrl = url;
          _image = null; // Reset local image
        }
      });
    }
  }

  Future<void> pickImage(bool isBanner) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result != null) {
      setState(() {
        if (isBanner) {
          _bannerImage = result.files.first.bytes;
          _selectedBannerUrl = null;
        } else {
          _image = result.files.first.bytes;
          _selectedImageUrl = null;
        }
      });
    }
  }

  void _showDetailDialog(BuildContext context, Category cat) {
    showDialog(
      context: context,
      builder: (context) => CategoryDetailDialog(category: cat),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate() ||
        (_image == null && _selectedImageUrl == null))
      return;

    setState(() => _isLoading = true);

    await _categoryController.uploadCategoryWithUrls(
      localImage: _image,
      localBanner: _bannerImage,
      cloudImage: _selectedImageUrl,
      cloudBanner: _selectedBannerUrl,
      name: categoryName,
      context: context,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _image = null;
        _bannerImage = null;
        _selectedImageUrl = null;
        _selectedBannerUrl = null;
      });
      _formKey.currentState!.reset();
      _fetchCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const Divider(thickness: 1, height: 30),
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildImagePicker(
                          label: 'Image',
                          image: _image,
                          cloudUrl: _selectedImageUrl,
                          onPickLocal: () => pickImage(false),
                          onPickCloud: () => _handleCloudSelection(false),
                        ),
                        const SizedBox(width: 20),
                        _buildImagePicker(
                          label: 'Banner',
                          image: _bannerImage,
                          cloudUrl: _selectedBannerUrl,
                          onPickLocal: () => pickImage(true),
                          onPickCloud: () => _handleCloudSelection(true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: 400,
                      child: TextFormField(
                        onChanged: (val) => categoryName = val,
                        validator: (val) => val!.isEmpty ? 'Enter name' : null,
                        decoration: const InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveCategory,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Category'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Category List',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) =>
                _buildCategoryCard(_categories[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category cat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              SizedBox(
                height: constraints.maxHeight * 0.4,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: cat.banner.isNotEmpty
                      ? Image.network(cat.banner, fit: BoxFit.cover)
                      : Container(color: Colors.grey.shade200),
                ),
              ),
              SizedBox(
                height: constraints.maxHeight * 0.3,
                child: Center(
                  child: CircleAvatar(
                    radius: constraints.maxHeight * 0.12,
                    backgroundImage: NetworkImage(cat.image),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: FittedBox(
                        child: Text(
                          cat.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showDetailDialog(context, cat),
                      child: const Text("View"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImagePicker({
    required String label,
    required Uint8List? image,
    required String? cloudUrl,
    required VoidCallback onPickLocal,
    required VoidCallback onPickCloud,
  }) {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: image != null
              ? Image.memory(image, fit: BoxFit.cover)
              : (cloudUrl != null
                    ? Image.network(cloudUrl, fit: BoxFit.cover)
                    : const Icon(Icons.image_outlined, size: 50)),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton(onPressed: onPickLocal, child: Text(label)),
            const SizedBox(width: 5),
            ElevatedButton(
              onPressed: onPickCloud,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Cloud'),
            ),
          ],
        ),
      ],
    );
  }
}

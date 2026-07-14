import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // Controllers thay vì biến late để tránh lỗi khởi tạo
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

  chooseImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => images.add(pickedFile));
    }
  }

  void getSubcategoryByCategory(value) {
    setState(() {
      selectedSubcategory = null;
      futureSubcategories = SubcategoryController()
          .getSubCategoriesByCategoryName(value.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vendorData = ref.read(vendorProvider);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              itemCount: images.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                return index == 0
                    ? Center(
                        child: IconButton(
                          onPressed: chooseImage,
                          icon: const Icon(Icons.add),
                        ),
                      )
                    : kIsWeb
                    ? Image.network(images[index - 1].path)
                    : Image.file(File(images[index - 1].path));
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Dropdowns
                  FutureBuilder<List<CategoryModel>>(
                    future: futureCategories,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const CircularProgressIndicator();
                      return DropdownButtonFormField<CategoryModel>(
                        decoration: const InputDecoration(
                          labelText: 'Select Category',
                        ),
                        items: snapshot.data!
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() => selectedCategory = v);
                          getSubcategoryByCategory(v);
                        },
                        validator: (v) => v == null ? 'Required' : null,
                      );
                    },
                  ),
                  if (futureSubcategories != null)
                    FutureBuilder<List<Subcategory>>(
                      future: futureSubcategories,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const CircularProgressIndicator();
                        return DropdownButtonFormField<Subcategory>(
                          decoration: const InputDecoration(
                            labelText: 'Select Subcategory',
                          ),
                          items: snapshot.data!
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.subCategoryName),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => selectedSubcategory = v),
                          validator: (v) => v == null ? 'Required' : null,
                        );
                      },
                    ),

                  // Text Fields
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLength: 500,
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 20),

                  InkWell(
                    onTap: () async {
                      if (vendorData == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please login first")),
                        );
                        return;
                      }
                      if (selectedCategory == null ||
                          selectedSubcategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Select category/subcategory"),
                          ),
                        );
                        return;
                      }
                      if (images.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Pick at least one image"),
                          ),
                        );
                        return;
                      }

                      if (_formKey.currentState!.validate()) {
                        setState(() => isLoading = true);
                        await _productController.uploadProduct(
                          productName: _nameController.text,
                          productPrice:
                              int.tryParse(_priceController.text) ?? 0,
                          quantity: int.tryParse(_quantityController.text) ?? 0,
                          description: _descController.text,
                          category: selectedCategory!.name,
                          vendorId: vendorData.id,
                          fullName: vendorData.fullName,
                          subCategory: selectedSubcategory!.subCategoryName,
                          pickedImages: images,
                          context: context,
                        );
                        setState(() => isLoading = false);
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 200,
                      color: Colors.blueAccent,
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "UPLOAD PRODUCT",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

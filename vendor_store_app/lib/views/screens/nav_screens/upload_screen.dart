import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_store_app/controllers/category_controller.dart';
import 'package:vendor_store_app/controllers/subcategory_controller.dart';
import 'package:vendor_store_app/models/category.dart';
import 'package:vendor_store_app/models/subcategory.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Future<List<CategoryModel>> futureCategories;
  Future<List<Subcategory>>? futureSubcategories;
  CategoryModel? selectedCategory;
  Subcategory? selectedSubcategory;

  @override
  void initState() {
    super.initState();
    futureCategories = CategoryController().loadCategories();
  }

  final ImagePicker picker = ImagePicker();
  List<File> images = [];

  chooseImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => images.add(File(pickedFile.path)));
    }
  }

  getSubcategoryByCategory(value) {
    setState(() {
      selectedSubcategory = null;
      futureSubcategories = SubcategoryController()
          .getSubCategoriesByCategoryName(value.name);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    : Image.file(images[index - 1]);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Dropdown
                  SizedBox(
                    width: 200,
                    child: FutureBuilder<List<CategoryModel>>(
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
                  ),
                  const SizedBox(height: 10),

                  // Subcategory Dropdown
                  futureSubcategories == null
                      ? const SizedBox()
                      : SizedBox(
                          width: 200,
                          child: FutureBuilder<List<Subcategory>>(
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
                        ),

                  // Fields: Name, Price, Quantity
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),

                  // Description
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      maxLength: 500,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Product Description',
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // InkWell Upload Button
                  InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        print("Đang upload dữ liệu...");
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "UPLOAD PRODUCT",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

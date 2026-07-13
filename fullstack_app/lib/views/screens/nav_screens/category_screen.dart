import 'package:flutter/material.dart';
import 'package:fullstack_app/controllers/category_controller.dart';
import 'package:fullstack_app/controllers/subcategory_controller.dart';
import 'package:fullstack_app/models/category.dart';
import 'package:fullstack_app/models/subcategory.dart';
import 'package:fullstack_app/views/screens/nav_screens/widgets/header_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<CategoryModel>> futureCategories;
  CategoryModel? _selectedCategory;
  List<Subcategory> _subcategories = [];
  final SubcategoryController _subcategoryController = SubcategoryController();

  @override
  void initState() {
    super.initState();
    futureCategories = CategoryController().loadCategories();
  }

  Future<void> _loadSubcategories(String categoryName) async {
    final subcategories = await _subcategoryController
        .getSubCategoriesByCategoryName(categoryName);
    setState(() {
      _subcategories = subcategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: HeaderWidget(),
      ),
      body: Row(
        children: [
          // Sidebar danh mục
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey.shade50,
              child: FutureBuilder<List<CategoryModel>>(
                future: futureCategories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }
                  final categories = snapshot.data ?? [];
                  return ListView.separated(
                    itemCount: categories.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      bool isSelected = _selectedCategory == category;
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedCategory = category);
                          _loadSubcategories(category.name);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Text(
                            category.name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected ? Colors.blue : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Nội dung chi tiết danh mục
          Expanded(
            flex: 5,
            child: _selectedCategory == null
                ? const Center(child: Text("Chọn một danh mục để xem chi tiết"))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Banner
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            _selectedCategory!.banner,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 160,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "Danh mục con",
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _subcategories.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15,
                                childAspectRatio: 0.9,
                              ),
                          itemBuilder: (context, index) {
                            final sub = _subcategories[index];
                            return Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        sub.image.replaceAll(' ', ''),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  sub.subCategoryName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

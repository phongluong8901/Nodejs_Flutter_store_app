import 'package:flutter/material.dart';
import 'package:fullstack_app/controllers/subcategory_controller.dart'; // Đảm bảo đường dẫn này đúng
import 'package:fullstack_app/models/category.dart';
import 'package:fullstack_app/models/subcategory.dart';
import 'package:fullstack_app/views/screens/detail/screens/widgets/inner_banner_widget.dart';
import 'package:fullstack_app/views/screens/detail/screens/widgets/inner_header_widget.dart';
import 'package:fullstack_app/views/screens/detail/screens/widgets/subcategory_tile_widget.dart';

class InnerCategoryScreen extends StatefulWidget {
  final CategoryModel category; // Dùng model Category của bạn

  const InnerCategoryScreen({super.key, required this.category});

  @override
  State<InnerCategoryScreen> createState() => _InnerCategoryScreenState();
}

class _InnerCategoryScreenState extends State<InnerCategoryScreen> {
  final SubcategoryController _controller = SubcategoryController();
  late Future<List<Subcategory>> _subCategoriesFuture;

  @override
  void initState() {
    super.initState();
    // Gọi controller để lấy dữ liệu subcategory dựa trên tên danh mục
    _subCategoriesFuture = _controller.getSubCategoriesByCategoryName(
      widget.category.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const InnerHeaderWidget(),

            // Dùng banner từ model Category truyền vào
            InnerBannerWidget(image: widget.category.banner),

            FutureBuilder<List<Subcategory>>(
              future: _subCategoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Có lỗi xảy ra khi tải dữ liệu'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(child: Text('Danh mục này chưa có mục con')),
                  );
                }

                final subCategories = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subCategories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                    itemBuilder: (context, index) {
                      final sub = subCategories[index];
                      return SubcategoryTileWidget(
                        image: sub.image,
                        title: sub.subCategoryName,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

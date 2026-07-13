import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fullstack_app/controllers/category_controller.dart';
import 'package:fullstack_app/models/category.dart';
import 'package:fullstack_app/views/screens/detail/screens/inner_category_screen.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryController _controller = CategoryController();
  CategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryModel>>(
      future: _controller.loadCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Tiêu đề hiển thị 1 lần duy nhất
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Grid hiển thị các item
              Wrap(
                spacing: 15,
                runSpacing: 25,
                children: snapshot.data!
                    .map((cat) => _CategoryItem(cat))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryModel cat;
  const _CategoryItem(this.cat);

  @override
  Widget build(BuildContext context) {
    // Chia 4 để icon hiển thị to, đẹp mắt
    final itemWidth = (MediaQuery.of(context).size.width - 80) / 8;

    return SizedBox(
      width: itemWidth,
      child: Column(
        children: [
          SizedBox(
            width: itemWidth,
            height: itemWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Hình trang trí
                Positioned(top: -5, right: -5, child: _buildShape()),

                // Card chứa icon
                Positioned.fill(
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    elevation: 4,
                    shadowColor: Colors.black26,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      splashColor: Colors.blue.withOpacity(0.2),
                      onTap: () {
                        print("Đã chọn: ${cat.name}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return InnerCategoryScreen(category: cat);
                            },
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: CachedNetworkImage(
                          imageUrl: cat.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            cat.name,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildShape() {
    final rand = cat.id.hashCode % 3;
    if (rand == 0) {
      return Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.amber,
          shape: BoxShape.circle,
        ),
      );
    }
    if (rand == 1) {
      return Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.rectangle,
        ),
      );
    }
    return CustomPaint(size: const Size(12, 12), painter: _TrianglePainter());
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;
    var path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

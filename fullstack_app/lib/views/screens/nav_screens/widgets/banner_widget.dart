import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Đảm bảo bạn đã thêm gói này vào pubspec.yaml
import 'package:fullstack_app/controllers/banner_controller.dart';
import 'package:fullstack_app/models/banner_model.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final BannerController _bannerController = BannerController();
  late Future<List<BannerModel>> _bannersFuture;

  @override
  void initState() {
    super.initState();
    _bannersFuture = _bannerController.loadBanners();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BannerModel>>(
      future: _bannersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 170,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final banners = snapshot.data!;

        return CarouselSlider.builder(
          itemCount: banners.length,
          options: CarouselOptions(
            height: 170,
            autoPlay: true, // Tự động chuyển banner
            enlargeCenterPage: true, // Phóng to ảnh ở giữa
            viewportFraction: 0.9, // Chiếm 90% chiều rộng màn hình
            aspectRatio: 2.0,
            autoPlayInterval: const Duration(seconds: 3),
          ),
          itemBuilder: (context, index, realIndex) {
            final banner = banners[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: banner.image, // Dùng thuộc tính image từ model cũ
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

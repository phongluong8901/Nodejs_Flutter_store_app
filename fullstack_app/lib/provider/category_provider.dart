import 'package:flutter_riverpod/legacy.dart';
import 'package:fullstack_app/models/category.dart';

// 1. Định nghĩa Notifier
class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  CategoryNotifier() : super([]);

  // 2. PHẢI THÊM HÀM NÀY VÀO ĐÂY
  void setCategories(List<CategoryModel> categories) {
    state = categories;
  }
}

// 3. Khai báo Provider
final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<CategoryModel>>((ref) {
      return CategoryNotifier();
    });

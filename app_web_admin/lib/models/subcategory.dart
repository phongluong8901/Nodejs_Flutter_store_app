class SubCategoryModel {
  final String id;
  final String categoryId;
  final String categoryName;
  final String subCategoryName;
  final String image;

  SubCategoryModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.subCategoryName,
    required this.image,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['_id']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      subCategoryName: json['subCategoryName']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'subCategoryName': subCategoryName,
      'image': image,
    };
  }
}

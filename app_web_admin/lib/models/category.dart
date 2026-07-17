class CategoryModel {
  final String id;
  final String name;
  final String image;
  final String banner;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.banner,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      banner: json['banner']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'image': image, 'banner': banner};
  }
}

class BannerModel {
  // Đổi tên từ Banner thành BannerModel
  final String id;
  final String image;

  BannerModel({required this.id, required this.image});

  // Factory để tạo từ JSON
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      // Chú ý: MongoDB thường dùng '_id', code này đã xử lý đúng
      id: json['_id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }

  // Chuyển sang JSON để gửi lên Server
  Map<String, dynamic> toJson() {
    return {
      'id':
          id, // Một số server cần key 'id' hoặc '_id', hãy check lại API của bạn
      'image': image,
    };
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReusableTextWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const ReusableTextWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bọc Title trong Expanded để nó chiếm không gian còn lại một cách linh hoạt
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis, // Thêm dấu ... nếu chữ quá dài
            ),
          ),
          const SizedBox(width: 10), // Khoảng cách nhỏ giữa 2 text
          // Bọc Subtitle hoặc để nó cố định kích thước
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

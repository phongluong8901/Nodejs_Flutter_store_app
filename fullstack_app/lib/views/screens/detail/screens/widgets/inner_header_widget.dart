import 'package:flutter/material.dart';

class InnerHeaderWidget extends StatelessWidget {
  const InnerHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      // height: MediaQuery.of(context).size.height * 0.20,
      child: Stack(
        children: [
          Image.asset(
            'assets/icons/searchBanner.jpeg',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 16,
            top: 68,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Positioned(
            left: 64,
            top: 68,
            child: SizedBox(
              width: 250,
              height: 50,
              // Bọc TextField trong Material để sửa lỗi "No Material widget found"
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter text',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F7F7F),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    prefixIcon: Image.asset('assets/icons/searc1.png'),
                    suffixIcon: Image.asset('assets/icons/cam.png'),
                    fillColor: Colors.grey.shade200,
                    filled: true,
                    // focusColor không phải là màu nền khi focus,
                    // nếu muốn đổi màu khi nhấn vào, bạn cần dùng fillColor và focusNode
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 311,
            top: 78,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {},
                child: Ink(
                  width: 31,
                  height: 31,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/icons/bell.png'),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 354,
            top: 78,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {},
                child: Ink(
                  width: 31,
                  height: 31,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/icons/message.png'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

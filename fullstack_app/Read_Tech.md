# 1. Align

Trong Flutter, Align là một widget dùng để định vị (căn chỉnh) widget con (child) của nó nằm ở một vị trí cụ thể bên trong không gian mà nó được cung cấp.

Hãy tưởng tượng Align giống như một cái khung hình có tọa độ. Bạn có thể đặt vật thể vào giữa, vào góc, hoặc bất kỳ đâu trong khung hình đó.

Cách Align hoạt động trong đoạn code của bạn
Dart

Align(
alignment: Alignment.topLeft, // Đây là "công tắc" điều khiển vị trí
child: Text('Email'), // Đây là nội dung cần căn chỉnh
)
alignment: Đây là thuộc tính quan trọng nhất. Nó quy định vị trí của widget con. Trong ví dụ của bạn, nó được đặt là Alignment.topLeft (góc trên bên trái).

child: Là widget bạn muốn di chuyển (trong trường hợp này là chữ "Email").

# 2. TextFormField

extFormField trong Flutter là một widget chuyên dụng để người dùng nhập liệu văn bản. Nó là sự kết hợp giữa một TextField thông thường và một FormField, cho phép bạn thực hiện các thao tác xác thực (validate) dữ liệu một cách dễ dàng.

Trong đoạn code của bạn, bạn đang sử dụng InputDecoration để tạo giao diện cho ô nhập liệu. Dưới đây là ý nghĩa của các thuộc tính bạn đã dùng:
Các thành phần chính trong đoạn code của bạn:
fillColor & filled: Thiết lập màu nền cho ô nhập liệu. filled: true là bắt buộc để màu nền (fillColor) hiển thị.

border, focusedBorder, enabledBorder:

Bạn đang đặt focusedBorder và enabledBorder là InputBorder.none. Điều này có nghĩa là khi người dùng nhấn vào hoặc khi ô nhập liệu đang ở trạng thái bình thường, sẽ không có viền bao quanh.

Tuy nhiên, thuộc tính border (của OutlineInputBorder) bạn đã định nghĩa ở trên sẽ bị "ghi đè" hoặc không hiển thị khi bạn đã set focusedBorder và enabledBorder là none.

labelText & labelStyle: Hiển thị nhãn hướng dẫn. Khi người dùng nhấn vào, nhãn này thường sẽ thu nhỏ lại hoặc bay lên phía trên.

prefixIcon & suffixIcon:

prefixIcon: Đặt icon ở đầu ô nhập (bên trái). Bạn dùng Padding để căn chỉnh khoảng cách cho hình ảnh password.png.

suffixIcon: Đặt icon ở cuối ô nhập (bên phải). Icons.visibility thường dùng để bật/tắt chế độ ẩn/hiện mật khẩu.

# 3. Container

Container là "công cụ đa năng" nhất trong Flutter. Nó giống như một chiếc hộp rỗng mà bạn có thể tùy ý thay đổi kích thước, màu sắc, viền, đổ bóng và cách căn chỉnh nội dung bên trong.

Trong đoạn code của bạn, Container đang được dùng để tạo một nút bấm (button) có hiệu ứng Gradient (chuyển màu).

Giải mã các thành phần trong Container:
width & height: Cố định kích thước của chiếc hộp là 319x50.

decoration: Đây là nơi chứa các thuộc tính "trang trí". Lưu ý: Khi đã dùng decoration, bạn không được đặt thuộc tính color trực tiếp ở bên ngoài decoration nữa (Flutter sẽ báo lỗi).

borderRadius: Bo tròn các góc của hộp.

gradient: Tạo hiệu ứng màu chuyển từ 0xFF102DE1 (xanh đậm) sang 0xCC0D6EFF (xanh nhạt hơn).

child: Center: Đảm bảo chữ "Sign in" luôn nằm chính giữa chiếc hộp bất kể kích thước hộp thay đổi ra sao.

# 4. Opacity

Widget Opacity trong Flutter được dùng để kiểm soát độ trong suốt của một widget con. Nó rất hữu ích khi bạn muốn làm mờ hình ảnh, văn bản hoặc các thành phần giao diện khác để tạo hiệu ứng thị giác (ví dụ: làm mờ nút bấm khi ở trạng thái bị vô hiệu hóa).

Phân tích đoạn code của bạn:
opacity: 0.5: Đây là thông số quan trọng nhất.

Giá trị dao động từ 0.0 (trong suốt hoàn toàn - biến mất) đến 1.0 (hiển thị rõ nét hoàn toàn).

Với 0.5, widget Container bên trong sẽ hiển thị mờ đi 50% so với màu gốc.

child: Container: Widget con bị tác động bởi độ mờ này. Trong trường hợp của bạn, toàn bộ chiếc khung (đường viền dày 12px) sẽ bị làm mờ.

Những lưu ý quan trọng khi dùng Opacity:
Hiệu suất (Performance): Opacity là một widget khá "tốn kém" về mặt hiệu năng vì nó buộc Flutter phải vẽ widget con lên một lớp đệm (buffer) trước khi thực hiện hiệu ứng làm mờ.

Lời khuyên: Nếu bạn chỉ cần làm mờ một màu nền (như Color(0xFF103DE5)), thay vì dùng Opacity cho cả cái Container, bạn hãy dùng withOpacity ngay trên màu đó. Cách này hiệu quả hơn nhiều:

Dart

// Thay vì dùng Opacity widget, hãy dùng:
color: Color(0xFF103DE5).withOpacity(0.5),
clipBehavior: Clip.antiAlias:

Bạn đang sử dụng thuộc tính này để đảm bảo các góc (đặc biệt nếu bạn bo tròn) được vẽ mượt mà, không bị răng cưa.

Lưu ý: Clip.antiAlias cũng tiêu tốn tài nguyên hơn một chút so với Clip.none hoặc Clip.hardEdge, nên chỉ dùng khi cần thiết.

Thay thế khi cần:

Nếu bạn muốn làm mờ một hình ảnh (Image), hãy cân nhắc sử dụng ColorFiltered hoặc các thư viện hỗ trợ chuyên biệt để có hiệu suất tốt hơn.

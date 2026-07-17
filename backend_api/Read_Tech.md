# 1. trim, validate, và validator

Trong đoạn mã Mongoose bạn cung cấp, trim, validate, và validator là các tính năng (options) giúp bạn kiểm soát và làm sạch dữ liệu trước khi lưu vào cơ sở dữ liệu MongoDB.

Dưới đây là giải thích chi tiết cho từng thành phần:

1. trim: true
   Chức năng: Loại bỏ các khoảng trắng dư thừa ở đầu và cuối chuỗi (string) trước khi lưu vào cơ sở dữ liệu.

Ví dụ: Nếu người dùng nhập " nguyen van a ", khi có trim: true, Mongoose sẽ tự động cắt thành "nguyen van a".

Lợi ích: Tránh việc dữ liệu bị lỗi do khoảng trắng thừa, giúp việc tìm kiếm (query) dữ liệu chính xác hơn.

2. validate
   Chức năng: Đây là một đối tượng (object) cho phép bạn định nghĩa các quy tắc kiểm tra dữ liệu tùy chỉnh. Nếu hàm kiểm tra trả về false, Mongoose sẽ chặn không cho lưu tài liệu đó và trả về lỗi.

3. validator
   Chức năng: Đây là một hàm (function) thực sự thực hiện việc kiểm tra logic.

Cách hoạt động:

Nó nhận vào giá trị của trường đó (value).

Bạn viết logic bên trong để kiểm tra (ví dụ: dùng biểu thức chính quy Regex hoặc kiểm tra độ dài chuỗi).

Hàm phải trả về true (hợp lệ) hoặc false (không hợp lệ).

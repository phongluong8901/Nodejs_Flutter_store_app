import 'dart:convert';

import 'package:app_web_admin/models/order.dart';
import 'package:http/http.dart' as http;

import '../global_variable.dart';

class OrderController {
  // load orders
  Future<List<OrderModel>> fetchOrders() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/orders'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // 1. Decode ra Map trước
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // 2. Truy cập vào key "orders" để lấy List
        final List<dynamic> ordersData = responseData['orders'];

        // 3. Map từng phần tử
        List<OrderModel> orders = ordersData
            .map((order) => OrderModel.fromJson(order))
            .toList();

        return orders;
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Error loading orders: $e');
    }
  }
}

import 'package:flutter_riverpod/legacy.dart';
import 'package:fullstack_app/models/order.dart';

class OrderProvider extends StateNotifier<List<Order>> {
  OrderProvider() : super([]);

  //set the list of Orders {}
  void setOrders(List<Order> orders) {
    state = orders;
  }
}

final orderProvider = StateNotifierProvider<OrderProvider, List<Order>>((ref) {
  return OrderProvider();
});

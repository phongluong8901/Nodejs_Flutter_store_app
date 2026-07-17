import 'package:flutter_riverpod/legacy.dart';
import 'package:vendor_store_app/models/order.dart';

class TotalEarningsProvider extends StateNotifier<Map<String, dynamic>> {
  //constructor that initializes the state with 0.0(statring total earnings)
  TotalEarningsProvider() : super({'totalEarnings': 0.0, 'totalOrders': 0});

  //method to calculate total earnings based on the delived status
  void calculateEarnings(List<Order> orders) {
    //initialize a local variable to cccumaulate eranings
    double earnings = 0.0;
    int orderCount = 0;
    //loop through earch order in the list of orders
    for (Order order in orders) {
      //check if the order has been delivered
      if (order.delivered) {
        orderCount++;
        earnings += order.productPrice * order.quantity;
      }
    }
    //upadte the state with the calculated earnings, which will notifier listerner of this state
    state = {'totalEarnings': earnings, 'totalOrders': orderCount};
  }
}

final totalEarningsProvider =
    StateNotifierProvider<TotalEarningsProvider, Map<String, dynamic>>((ref) {
      return TotalEarningsProvider();
    });

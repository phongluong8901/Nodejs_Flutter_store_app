import 'dart:convert';

import 'package:fullstack_app/models/order.dart';
import 'package:fullstack_app/services/manage_http_response.dart';
import 'package:fullstack_app/views/global_variables.dart';
import 'package:http/http.dart' as http;

class OrderController {
  //fucntion to upload orders
  uploadOrders({
    required String id,
    required String fullName,
    required String email,
    required String state,
    required String city,
    required String locality,
    required String productName,
    required int productPrice,
    required int quantity,
    required String category,
    required String image,
    required String buyerId,
    required String vendorId,
    required bool processing,
    required bool delivered,
    required context,
  }) async {
    try {
      final Order order = Order(
        id: id,
        fullName: fullName,
        email: email,
        state: state,
        city: city,
        locality: locality,
        productName: productName,
        productPrice: productPrice,
        quantity: quantity,
        category: category,
        image: image,
        buyerId: buyerId,
        vendorId: vendorId,
        processing: processing,
        delivered: delivered,
      );
      http.Response response = await http.post(
        Uri.parse("$uri/api/orders"),
        body: order.toJson(),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'You have placed an order');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  //method to get orsers by buyers id
  Future<List<Order>> loadOrders({required String buyerId}) async {
    try {
      //send an HTTP get request to get the orders by the buyerId
      http.Response response = await http.get(
        Uri.parse('$uri/api/orders/$buyerId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      //check if the response status code is 200(OK)
      if (response.statusCode == 200) {
        //Parse the Json response body into dynamic List
        //this convert the json data into a format that can be further process in Dart
        List<dynamic> data = jsonDecode(response.body);
        //map the dynamic lis tto list of orders object using the from json factor
        //this step converts the raw data into lkist of the orders instances, which are easier to work with
        List<Order> orders = data
            .map((order) => Order.fromJson(order))
            .toList();
        return orders;
      }
      {
        //throw an exception if the server responded with an error status code
        throw Exception("failed to laod Orders");
      }
    } catch (e) {
      throw Exception("Error Loading");
    }
  }
}

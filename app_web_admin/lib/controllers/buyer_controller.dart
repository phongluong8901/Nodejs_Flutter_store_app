import 'dart:convert';

import 'package:app_web_admin/models/buyer.dart';
import 'package:http/http.dart' as http;

import '../global_variable.dart';

class BuyerController {
  // load buyers
  Future<List<BuyerModel>> fetchBuyers() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/users'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<BuyerModel> buyers = data
            .map((buyer) => BuyerModel.fromMap(buyer))
            .toList();
        return buyers;
      } else {
        throw Exception('Failed to load buyers');
      }
    } catch (e) {
      throw Exception('Error loading buyers:$e');
    }
  }
}

import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:fullstack_app/models/favorite.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoriteProvider =
    StateNotifierProvider<FavoriteProvider, Map<String, Favorite>>((ref) {
      return FavoriteProvider();
    });

class FavoriteProvider extends StateNotifier<Map<String, Favorite>> {
  FavoriteProvider() : super({}) {
    _loadFavorites();
  }

  //a private method that loads items from sharedrpeference
  Future<void> _loadFavorites() async {
    //retriveing the sahredpreference instance to store data
    final prefs = await SharedPreferences.getInstance();
    //fetch the json string of the favorite items form sharedpreference
    final favoriteString = prefs.getString('favorites');
    //checking if the string is not null, meaning there is saved  data load
    if (favoriteString != null) {
      //decode the json String into map of dynamic data
      final Map<String, dynamic> favoriteMap = jsonDecode(favoriteString);
      //convert the dynamic map into map of Favorite object using the 'fromjson' factory method
      final favorites = favoriteMap.map(
        (key, value) => MapEntry(key, Favorite.fromJson(value)),
      );
      //updading the state with the loaded favorites
      state = favorites;
    }
  }

  //a private method saves the current list of favorite items to sharedpreferences
  Future<void> _saveFavorites() async {
    //retrieving the sharepreference instance to store data
    final prefs = await SharedPreferences.getInstance();
    //encoding the current state(Map of favorite object) into json String
    final favoriteString = jsonEncode(state);
    //saving the jsoon string to sharedpreferences with the key "favorites"
    await prefs.setString('favorites', favoriteString);
  }

  void addProductToFavorite({
    required String productName,
    required int productPrice,
    required String category,
    required List<String> image,
    required String vendorId,
    required int productQuantity,
    required int quantity,
    required String productId,
    required String description,
    required String fullName,
  }) {
    state[productId] = Favorite(
      productName: productName,
      productPrice: productPrice,
      category: category,
      image: image,
      vendorId: vendorId,
      productQuantity: productQuantity,
      quantity: quantity,
      productId: productId,
      description: description,
      fullName: fullName,
    );
    //notify listener that the state has changed
    state = {...state};
    _saveFavorites();
  }

  //method to remove the item from the cart
  void removeFavoriteItem(String productId) {
    state.remove(productId);
    //notify listener that the state has changed
    state = {...state};
    _saveFavorites();
  }

  Map<String, Favorite> get getFavoriteItems => state;
}

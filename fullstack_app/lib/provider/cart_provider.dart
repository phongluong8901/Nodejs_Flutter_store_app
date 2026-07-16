// a notifier class to manage the cart state, extedning stateNOtfifier
//with an final state of an emty map

import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:fullstack_app/models/cart.dart';
import 'package:shared_preferences/shared_preferences.dart';

//define a statenotifierProvider to expose an instance of the CartNotifier
//Making i cassesible within our app
final cartProvider = StateNotifierProvider<CartNotifier, Map<String, Cart>>((
  ref,
) {
  return CartNotifier();
});

//entity state of an empty map
class CartNotifier extends StateNotifier<Map<String, Cart>> {
  CartNotifier() : super({}) {
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    //retriveing the sahredpreference instance to store data
    final prefs = await SharedPreferences.getInstance();
    //fetch the json string of the favorite items form sharedpreference
    final cartString = prefs.getString('cart_items');
    //checking if the string is not null, meaning there is saved  data load
    if (cartString != null) {
      //decode the json String into map of dynamic data
      final Map<String, dynamic> favoriteMap = jsonDecode(cartString);
      //convert the dynamic map into map of Favorite object using the 'fromjson' factory method
      final favorites = favoriteMap.map(
        (key, value) => MapEntry(key, Cart.fromJson(value)),
      );
      //updading the state with the loaded favorites
      state = favorites;
    }
  }

  Future<void> _saveCartItems() async {
    //retrieving the sharepreference instance to store data
    final prefs = await SharedPreferences.getInstance();
    //encoding the current state(Map of favorite object) into json String
    final cartString = jsonEncode(state);
    //saving the jsoon string to sharedpreferences with the key "cart_items"
    await prefs.setString('cart_items', cartString);
  }

  //method to add product to the cart
  void addProductToCart({
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
    //check if the product is already in the cart
    if (state.containsKey(productId)) {
      //if the product is already in the cart, update its quantity and maybe other detail
      state = {
        ...state,
        productId: Cart(
          productName: state[productId]!.fullName,
          productPrice: state[productId]!.productPrice,
          category: state[productId]!.category,
          image: state[productId]!.image,
          vendorId: state[productId]!.vendorId,
          productQuantity: state[productId]!.productQuantity,
          quantity: state[productId]!.quantity + 1,
          productId: state[productId]!.productId,
          description: state[productId]!.description,
          fullName: state[productId]!.fullName,
        ),
      };
      _saveCartItems();
    } else {
      //if the product is not in the cart, add it with the provided details
      state = {
        productId: Cart(
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
        ),
      };
    }
  }

  //method to increment the quantity of a product in the cart
  void incrementCartItem(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity++;
    }
    //notify listeners that the state has changed
    state = {...state};
    _saveCartItems();
  }

  //method to decrement the quantity of a product in the cart
  void decrementCartItem(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity--;
    }
    //notify listeners that the state has changed
    state = {...state};
    _saveCartItems();
  }

  //method to remove the item from the cart
  void removeCartItem(String productId) {
    state.remove(productId);
    //notify listener that the state has changed
    state = {...state};
    _saveCartItems();
  }

  //method to calculate total amount of we have in the cart
  double calculateTotalAmount() {
    double totalAmount = 0.0;
    state.forEach((productId, cartItem) {
      totalAmount += cartItem.quantity * cartItem.productPrice;
    });
    return totalAmount;
  }

  Map<String, Cart> get getCartItems => state;
}

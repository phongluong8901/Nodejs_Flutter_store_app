// a notifier class to manage the cart state, extedning stateNOtfifier
//with an final state of an emty map

import 'package:flutter_riverpod/legacy.dart';
import 'package:fullstack_app/models/cart.dart';

//define a statenotifierProvider to expose an instance of the CartNotifier
//Making i cassesible within our app
final cartProvider = StateNotifierProvider<CartNotifier, Map<String, Cart>>((
  ref,
) {
  return CartNotifier();
});

//entity state of an empty map
class CartNotifier extends StateNotifier<Map<String, Cart>> {
  CartNotifier() : super({});

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
  }

  //method to decrement the quantity of a product in the cart
  void decrementCartItem(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity--;
    }
    //notify listeners that the state has changed
    state = {...state};
  }

  //method to remove the item from the cart
  void removeCartItem(String productId) {
    state.remove(productId);
    //notify listener that the state has changed
    state = {...state};
  }

  //method to calculate total amount of we have in the cart
  double calculateTotalAmount() {
    double totalAmount = 0.0;
    state.forEach((productId, cartItem) {
      totalAmount += cartItem.quantity * cartItem.productPrice;
    });
    return totalAmount;
  }
}

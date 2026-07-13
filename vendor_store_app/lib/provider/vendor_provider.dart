import 'package:flutter_riverpod/legacy.dart';
import 'package:vendor_store_app/models/vendor.dart';

//StateNotifier: StateNotifier is a class provided by RivePod package that help in
//Managing the state, it is designed to notify listener about  the state changes
class VendorProvider extends StateNotifier<Vendor?> {
  VendorProvider()
    : super(
        Vendor(
          id: '',
          fullName: '',
          email: '',
          state: '',
          city: '',
          locality: '',
          role: '',
          password: '',
          token: '',
        ),
      );
  //better method to extract value from an object
  Vendor? get vendor => state;
  //method to set user state user state from json
  //purpose: updates the user state base on json String representation  of user vendor object

  void setVendor(String vendorJson) {
    state = Vendor.fromJson(vendorJson);
  }

  //method to clear the vendor user state
  void signOut() {
    state = null;
  }
}

//make the data accessble
final vendorProvider = StateNotifierProvider<VendorProvider, Vendor?>((ref) {
  return VendorProvider();
});

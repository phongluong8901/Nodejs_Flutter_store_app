import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fullstack_app/controllers/auth_controller.dart';
import 'package:fullstack_app/provider/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ShippingAddressScreen extends ConsumerStatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  _ShippingAddressScreenState createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends ConsumerState<ShippingAddressScreen> {
  final GlobalKey<FormState> _fomKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _localityController;

  @override
  void initState() {
    super.initState();
    //Read the current user data from the provider
    final user = ref.read(userProvider);
    //Initailize the controllers with the current data if available
    //if user data is not available, initialize with an empty
    _stateController = TextEditingController(text: user?.state ?? "");
    _cityController = TextEditingController(text: user?.city ?? "");
    _localityController = TextEditingController(text: user?.locality ?? "");
  }

  late String state;
  late String city;
  late String locality;
  bool _isLoading = false;

  //show loading dialog
  _showLoadingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(
                  'Updating...',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    final updateUser = ref.read(userProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 0,
        title: Text(
          'Delivery',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            letterSpacing: 1.7,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: Form(
            key: _fomKey,
            child: Column(
              children: [
                Text(
                  'Where will your order \n be shipped',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.7,
                  ),
                ),

                TextFormField(
                  controller: _stateController,
                  onChanged: (value) {
                    state = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "please enter state";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(labelText: 'State'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _cityController,
                  onChanged: (value) {
                    city = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "please enter city";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(labelText: 'City'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _localityController,
                  onChanged: (value) {
                    locality = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "please enter Locality";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(labelText: 'Locality'),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () async {
            if (_fomKey.currentState!.validate()) {
              _showLoadingDialog();
              setState(() {
                _isLoading = true;
              });

              await _authController
                  .updateUserLocation(
                    context: context,
                    id: user!.id,
                    state: _stateController.text,
                    city: _cityController.text,
                    locality: _localityController.text,
                    ref: ref,
                  )
                  .whenComplete(() {
                    updateUser.recreateUserState(
                      state: _stateController.text,
                      city: _cityController.text,
                      locality: _localityController.text,
                    );
                    Navigator.pop(context); //this will cose the dialog
                  });

              // Kiểm tra mounted trước khi gọi setState
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });

                // Có thể thêm lệnh đóng màn hình sau khi lưu thành công
                Navigator.pop(context); // this will cose shippng screen
              }
            } else {
              print("Not Valid");
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFF3854EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 24, // Kích thước vòng tròn nhỏ cho vừa nút
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2, // Độ dày của đường tròn
                      ),
                    )
                  : Text(
                      'Save',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

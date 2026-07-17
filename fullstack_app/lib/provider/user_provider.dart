import 'package:flutter_riverpod/legacy.dart';
import 'package:fullstack_app/models/user.dart';

class UserProvider extends StateNotifier<User?> {
  //constructor intitializing with default user object
  //purpose: mange the state of the user object allowing updates
  UserProvider()
    : super(
        User(
          id: '',
          fullName: '',
          email: '',
          state: '',
          city: '',
          locality: '',
          password: '',
          token: '',
        ),
      );

  //getter method to extract value from an object
  User? get user => state;

  //method to set user state from JSOn
  //purpose: update the suer sate bnse on json String represent of user object
  void setUser(String userJson) {
    state = User.fromJson(userJson);
  }

  //method to clear user state
  void signOut() {
    state = null;
  }

  //method to recreate the user state
  void recreateUserState({
    required String state,
    required String city,
    required String locality,
  }) async {
    if (this.state != null) {
      this.state = User(
        id: this.state!.id,
        fullName: this.state!.fullName,
        email: this.state!.email,
        state: state,
        city: city,
        locality: locality,
        password: this.state!.password,
        token: this.state!.token,
      );
    }
  }
}

//make the data accessible within the application
final userProvider = StateNotifierProvider<UserProvider, User?>(
  (ref) => UserProvider(),
);

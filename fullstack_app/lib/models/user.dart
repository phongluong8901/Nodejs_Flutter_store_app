import 'dart:convert';

class User {
  //Define field
  final String id;
  final String fullName;
  final String email;
  final String state;
  final String city;
  final String locality;
  final String password;
  final String token;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.state,
    required this.city,
    required this.locality,
    required this.password,
    required this.token,
  });

  //Serialization: Convert User object to a map
  //Map: a map is a collection of key-value pairs
  //why: covering to a map is an intermedate step that is easier to serializer
  //the object to formates like json for storage or transimission

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "fullName": fullName,
      "email": email,
      "state": state,
      "city": city,
      "locality": locality,
      "password": password,
      "token": token,
    };
  }

  //Serialization: conver map to a Json string
  // this method directly encodes the data form the map into a json string

  // the json.encode() fnction convers a Dart object (such a map or list)
  //into a json string representation, making it suitable or comunication
  //betwwen different systems
  String toJson() => json.encode(toMap());

  //Deserialization: Convert a Map to a user Object
  //purpose - Manipulation and user: once the data is converted to a User object
  //it can be easilly manipuated and use within the application. For example
  //we mihge want to display the user's fullname, email,..
  //want to save the data locally

  //the factoey contructor take a map(usually obtanied from a json object)
  //and convert it into a user object. if a field is  not presend in the
  // it defaults to an empty String

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] as String? ?? "",
      fullName: map['fullName'] as String? ?? "",
      email: map['email'] as String? ?? "",
      state: map['state'] as String? ?? "",
      city: map['city'] as String? ?? "",
      locality: map['locality'] as String? ?? "",
      password: map['password'] as String? ?? "",
      token: map['token'] as String? ?? "",
    );
  }

  //fromJson: this factory contructor take json String , and decodes into a Map<String, dynamic>
  //and then uses fromMap to convert that Map into a user object

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}

class RegisterRequest {
  String username;
  String firstname;
  String lastname;
  String email;
  String phone;
  String dateOfBirth;
  int gender;
  bool isForeigner;
  String distrcict;
  String subDistrict;
  String province;
  String zipcode;
  String password;

  RegisterRequest({
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.isForeigner,
    required this.distrcict,
    required this.subDistrict,
    required this.province,
    required this.zipcode,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'phone': phone,
    'birthDate': dateOfBirth,
    'gender': gender,
    'isForeigner': isForeigner,
    'district': distrcict,
    'subDistrict': subDistrict,
    'province': province,
    'zipcode': zipcode,
    'password': password,
  };
}

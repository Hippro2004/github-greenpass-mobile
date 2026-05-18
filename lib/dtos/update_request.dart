class UpdateRequest {
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final String birthDate;
  final int gender;
  final bool isForeigner;
  final String district;
  final String subDistrict;
  final String province;
  final String zipcode;
  final String? password;

  UpdateRequest({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.isForeigner,
    required this.district,
    required this.subDistrict,
    required this.province,
    required this.zipcode,
    this.password,
  });

  Map<String, dynamic> toJson() => {
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'phone': phone,
    'birthDate': birthDate,
    'gender': gender,
    'isForeigner': isForeigner,
    'district': district,
    'subDistrict': subDistrict,
    'province': province,
    'zipcode': zipcode,
    if (password != null && password!.isNotEmpty) 'password': password,
  };
}

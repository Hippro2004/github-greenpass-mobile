class User {
  String? username;
  String? password;
  String? firstname;
  String? lastname;
  String? email;
  String? phone;
  String? birthDay;
  int? gender;
  bool? isForeigner;
  String? district;
  String? subDistrict;
  String? province;
  String? zipcode;

  User({
    this.username,
    this.password,
    this.firstname,
    this.lastname,
    this.email,
    this.phone,
    this.birthDay,
    this.gender,
    this.isForeigner,
    this.district,
    this.subDistrict,
    this.province,
    this.zipcode,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    username: json['username'] != null ? json['username'] as String : null,
    password: json['password'] != null ? json['password'] as String : null,
    firstname: json['firstname'] != null ? json['firstname'] as String : null,
    lastname: json['lastname'] != null ? json['lastname'] as String : null,
    email: json['email'] != null ? json['email'] as String : null,
    phone: json['phone'] != null ? json['phone'] as String : null,
    birthDay: json['birthDate'] != null ? json['birthDate'] as String : null,
    district: json['district'] != null ? json['district'] as String : null,
    subDistrict: json['subDistrict'] != null
        ? json['subDistrict'] as String
        : null,
    province: json['province'] != null ? json['province'] as String : null,
    zipcode: json['zipcode'] != null ? json['zipcode'] as String : null,
    gender: json['gender'] != null ? json['gender'] as int : null,
    isForeigner: json['isForeigner'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'phone': phone,
    'birthDay': birthDay,
    'gender': gender,
    'isForeigner': isForeigner,
    'district': district,
    'subDistrict': subDistrict,
    'province': province,
    'zipcode': zipcode,
  };
}

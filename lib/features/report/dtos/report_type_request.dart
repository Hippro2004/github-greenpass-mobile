import 'dart:convert';

class ReporyTypeRequest {
  final String typename;
  ReporyTypeRequest({required this.typename});

  ReporyTypeRequest copyWith({String? typename}) {
    return ReporyTypeRequest(typename: typename ?? this.typename);
  }

  Map<String, dynamic> toMap() {
    return {'typename': typename};
  }

  factory ReporyTypeRequest.fromMap(Map<String, dynamic> map) {
    return ReporyTypeRequest(typename: map['typeName'] ?? '');
  }

  String toJson() => json.encode(toMap());

  factory ReporyTypeRequest.fromJson(String source) =>
      ReporyTypeRequest.fromMap(json.decode(source));

  @override
  String toString() => 'ReporyTypeRequest(typename: $typename)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReporyTypeRequest && other.typename == typename;
  }

  @override
  int get hashCode => typename.hashCode;
}

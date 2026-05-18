class ApiResponse<T> {
  final bool success;
  final String message;
  final T? result;

  const ApiResponse({
    required this.success,
    required this.message,
    this.result,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      result: json['result'] != null && fromJsonT != null
          ? fromJsonT(json['result'])
          : null,
    );
  }
}

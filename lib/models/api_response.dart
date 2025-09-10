import 'api_error.dart';

class ApiResponse<T> {
  final T? data;
  final ApiError? error;
  final int? statusCode;
  final String? message;
  final bool isSuccess;
  final bool isRetry;

  ApiResponse._({
    this.data,
    this.error,
    this.statusCode,
    this.message,
    required this.isSuccess,
    this.isRetry = false,
  });

  factory ApiResponse.success({
    required T? data,
    int? statusCode,
    String? message,
  }) {
    return ApiResponse._(
      data: data,
      statusCode: statusCode,
      message: message,
      isSuccess: true,
    );
  }

  factory ApiResponse.error({
    required ApiError error,
  }) {
    return ApiResponse._(
      error: error,
      isSuccess: false,
    );
  }

  factory ApiResponse.retry() {
    return ApiResponse._(
      isSuccess: false,
      isRetry: true,
    );
  }

  // Convenience getters
  bool get isError => !isSuccess && !isRetry;
  bool get hasData => data != null;
  bool get isEmpty => data == null;
  
  // Get error message
  String get errorMessage => error?.message ?? 'Unknown error occurred';
  
  // Get status code
  int get responseStatusCode => statusCode ?? error?.statusCode ?? 0;
}

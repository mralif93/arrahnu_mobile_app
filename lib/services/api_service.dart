import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../constant/variables.dart';
import '../storage/secure_storage.dart';
import '../models/api_response.dart';
import '../models/api_error.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Configuration
  static const int _timeoutSeconds = 30;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  // Headers
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Base URL
  String get _baseUrl => Variables.baseUrl;

  // Get authorization header
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await SecureStorage().readSecureData('token');
    final headers = Map<String, String>.from(_defaultHeaders);
    
    if (token != 'No data found!!') {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Handle API response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final statusCode = response.statusCode;
      final body = response.body;

      // Success responses
      if (statusCode >= 200 && statusCode < 300) {
        if (fromJson != null) {
          final data = jsonDecode(body);
          return ApiResponse<T>.success(
            data: fromJson(data),
            statusCode: statusCode,
            message: 'Success',
          );
        } else {
          // For Map<String, dynamic> responses, parse the JSON directly
          final data = jsonDecode(body);
          return ApiResponse<T>.success(
            data: data as T,
            statusCode: statusCode,
            message: 'Success',
          );
        }
      }

      // Error responses
      String errorMessage = 'Request failed';
      try {
        final errorData = jsonDecode(body);
        errorMessage = errorData['message'] ?? 
                      errorData['error'] ?? 
                      errorData['detail'] ?? 
                      'Request failed';
      } catch (e) {
        errorMessage = _getErrorMessageByStatusCode(statusCode);
      }

      return ApiResponse<T>.error(
        error: ApiError(
          statusCode: statusCode,
          message: errorMessage,
          type: _getErrorTypeByStatusCode(statusCode),
        ),
      );
    } catch (e) {
      return ApiResponse<T>.error(
        error: ApiError(
          statusCode: response.statusCode,
          message: 'Failed to parse response: ${e.toString()}',
          type: ApiErrorType.parseError,
        ),
      );
    }
  }

  // Get error message by status code
  String _getErrorMessageByStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad Request - Invalid data provided';
      case 401:
        return 'Unauthorized - Please login again';
      case 403:
        return 'Forbidden - Access denied';
      case 404:
        return 'Not Found - Resource not available';
      case 408:
        return 'Request Timeout - Please try again';
      case 422:
        return 'Validation Error - Please check your input';
      case 429:
        return 'Too Many Requests - Please wait before trying again';
      case 500:
        return 'Internal Server Error - Please try again later';
      case 502:
        return 'Bad Gateway - Service temporarily unavailable';
      case 503:
        return 'Service Unavailable - Please try again later';
      default:
        return 'Request failed with status $statusCode';
    }
  }

  // Get error type by status code
  ApiErrorType _getErrorTypeByStatusCode(int statusCode) {
    if (statusCode >= 400 && statusCode < 500) {
      return ApiErrorType.clientError;
    } else if (statusCode >= 500) {
      return ApiErrorType.serverError;
    } else {
      return ApiErrorType.unknown;
    }
  }

  // Handle network errors
  ApiResponse<T> _handleNetworkError<T>(dynamic error) {
    if (error is SocketException) {
      return ApiResponse<T>.error(
        error: ApiError(
          statusCode: 0,
          message: 'No internet connection. Please check your network.',
          type: ApiErrorType.networkError,
        ),
      );
    } else if (error is HttpException) {
      return ApiResponse<T>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Network error: ${error.message}',
          type: ApiErrorType.networkError,
        ),
      );
    } else {
      return ApiResponse<T>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Unexpected error: ${error.toString()}',
          type: ApiErrorType.unknown,
        ),
      );
    }
  }

  // Retry mechanism
  Future<ApiResponse<T>> _retryRequest<T>(
    Future<http.Response> Function() request,
    T Function(dynamic)? fromJson,
    int retryCount,
  ) async {
    try {
      final response = await request();
      return _handleResponse(response, fromJson);
    } catch (error) {
      if (retryCount > 0) {
        await Future.delayed(_retryDelay);
        return _retryRequest(request, fromJson, retryCount - 1);
      }
      return _handleNetworkError<T>(error);
    }
  }

  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      EasyLoading.show(status: Variables.pleaseWaitText);
    }

    try {
      final uri = Uri.parse('$_baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );

      final headers = requiresAuth 
          ? await _getAuthHeaders() 
          : Map<String, String>.from(_defaultHeaders);

      final response = await _retryRequest(
        () => http.get(uri, headers: headers).timeout(
          const Duration(seconds: _timeoutSeconds),
        ),
        fromJson,
        _maxRetries,
      );

      if (showLoading) {
        EasyLoading.dismiss();
      }

      return response;
    } catch (error) {
      if (showLoading) {
        EasyLoading.dismiss();
      }
      return _handleNetworkError<T>(error);
    }
  }

  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      EasyLoading.show(status: Variables.pleaseWaitText);
    }

    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = requiresAuth 
          ? await _getAuthHeaders() 
          : Map<String, String>.from(_defaultHeaders);

      final response = await _retryRequest(
        () => http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(const Duration(seconds: _timeoutSeconds)),
        fromJson,
        _maxRetries,
      );

      if (showLoading) {
        EasyLoading.dismiss();
      }

      return response;
    } catch (error) {
      if (showLoading) {
        EasyLoading.dismiss();
      }
      return _handleNetworkError<T>(error);
    }
  }

  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      EasyLoading.show(status: Variables.pleaseWaitText);
    }

    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = requiresAuth 
          ? await _getAuthHeaders() 
          : Map<String, String>.from(_defaultHeaders);

      final response = await _retryRequest(
        () => http.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(const Duration(seconds: _timeoutSeconds)),
        fromJson,
        _maxRetries,
      );

      if (showLoading) {
        EasyLoading.dismiss();
      }

      return response;
    } catch (error) {
      if (showLoading) {
        EasyLoading.dismiss();
      }
      return _handleNetworkError<T>(error);
    }
  }

  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      EasyLoading.show(status: Variables.pleaseWaitText);
    }

    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = requiresAuth 
          ? await _getAuthHeaders() 
          : Map<String, String>.from(_defaultHeaders);

      final response = await _retryRequest(
        () => http.delete(uri, headers: headers).timeout(
          const Duration(seconds: _timeoutSeconds),
        ),
        fromJson,
        _maxRetries,
      );

      if (showLoading) {
        EasyLoading.dismiss();
      }

      return response;
    } catch (error) {
      if (showLoading) {
        EasyLoading.dismiss();
      }
      return _handleNetworkError<T>(error);
    }
  }

  // Check if token needs refresh
  Future<bool> _shouldRefreshToken() async {
    final token = await SecureStorage().readSecureData('token');
    if (token == 'No data found!!') return false;
    
    try {
      // Check if token expires in next 5 minutes
      final expirationTime = DateTime.now().add(const Duration(minutes: 5));
      // You can implement JWT token expiration check here
      return false; // For now, return false
    } catch (e) {
      return true;
    }
  }

  // Refresh token
  Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    final refreshToken = await SecureStorage().readSecureData('refresh');
    if (refreshToken == 'No data found!!') {
      return ApiResponse<Map<String, dynamic>>.error(
        error: ApiError(
          statusCode: 401,
          message: 'No refresh token available',
          type: ApiErrorType.clientError,
        ),
      );
    }

    return post<Map<String, dynamic>>(
      Variables.apiTokenRefreshEndpoint,
      body: {'refresh': refreshToken},
      requiresAuth: false,
      showLoading: false,
    );
  }

  // Handle authentication errors
  Future<ApiResponse<T>> _handleAuthError<T>() async {
    // Try to refresh token
    final refreshResponse = await refreshToken();
    
    if (refreshResponse.isSuccess) {
      // Save new token
      final newToken = refreshResponse.data?['access'];
      if (newToken != null) {
        await SecureStorage().writeSecureData('token', newToken);
        // Retry the original request
        return ApiResponse<T>.retry();
      }
    }
    
    // If refresh fails, logout user
    await SecureStorage().deleteSecureData('token');
    await SecureStorage().deleteSecureData('refresh');
    
    return ApiResponse<T>.error(
      error: ApiError(
        statusCode: 401,
        message: 'Session expired. Please login again.',
        type: ApiErrorType.clientError,
      ),
    );
  }
}

import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/api_response.dart';
import '../models/api_error.dart';
import '../model/user.dart';
import '../storage/secure_storage.dart';
import '../constant/variables.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  
  // Getter for accessing apiService from outside
  ApiService get apiService => _apiService;

  // Login
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      Variables.apiTokenEndpoint,
      body: {
        'username': username,
        'password': password,
      },
      requiresAuth: false,
      showLoading: true,
    );

    if (response.isSuccess && response.data != null) {
      // Save tokens
      final token = response.data!['access'];
      final refreshToken = response.data!['refresh'];
      
      if (token != null && refreshToken != null) {
        await SecureStorage().writeSecureData('token', token);
        await SecureStorage().writeSecureData('refresh', refreshToken);
      }
    }

    return response;
  }

  // Logout
  Future<ApiResponse<bool>> logout() async {
    try {
      // First, try to call the logout API endpoint if it exists
      try {
        await _apiService.post(
          '${Variables.baseUrl}/api/auth/logout/',
          requiresAuth: true,
          showLoading: false,
        );
      } catch (e) {
        // If API logout fails, continue with local logout
        print('API logout failed, proceeding with local logout: $e');
      }

      // Clear all stored authentication data
      await SecureStorage().deleteSecureData('token');
      await SecureStorage().deleteSecureData('refresh');
      
      // Clear any other user-related data if needed
      // await SecureStorage().deleteSecureData('user_profile');
      
      return ApiResponse<bool>.success(data: true);
    } catch (e) {
      return ApiResponse<bool>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Failed to logout: ${e.toString()}',
          type: ApiErrorType.unknown,
        ),
      );
    }
  }

  // Check session validity
  Future<ApiResponse<bool>> checkSession() async {
    try {
      final token = await SecureStorage().readSecureData('token');
      
      if (token == 'No data found!!' || token.isEmpty) {
        return ApiResponse<bool>.success(data: false);
      }

      // Check if token is valid and not expired
      try {
        final isExpired = JwtDecoder.isExpired(token);
        
        if (isExpired) {
          // Try to refresh token
          final refreshResponse = await _apiService.refreshToken();
          
          if (refreshResponse.isSuccess && refreshResponse.data != null) {
            final newToken = refreshResponse.data!['access'];
            if (newToken != null && newToken.isNotEmpty) {
              await SecureStorage().writeSecureData('token', newToken);
              return ApiResponse<bool>.success(data: true);
            }
          }
          
          // If refresh fails, clear tokens
          await SecureStorage().deleteSecureData('token');
          await SecureStorage().deleteSecureData('refresh');
          return ApiResponse<bool>.success(data: false);
        }

        return ApiResponse<bool>.success(data: true);
      } catch (e) {
        // If JWT decoding fails, clear tokens
        await SecureStorage().deleteSecureData('token');
        await SecureStorage().deleteSecureData('refresh');
        return ApiResponse<bool>.success(data: false);
      }
    } catch (e) {
      return ApiResponse<bool>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Failed to check session: ${e.toString()}',
          type: ApiErrorType.unknown,
        ),
      );
    }
  }

  // Get user profile
  Future<ApiResponse<User>> getUserProfile() async {
    try {
      final token = await SecureStorage().readSecureData('token');
      if (token == 'No data found!!') {
        return ApiResponse<User>.error(
          error: ApiError(
            statusCode: 401,
            message: 'No authentication token found',
            type: ApiErrorType.clientError,
          ),
        );
      }

      final decodedToken = JwtDecoder.decode(token);
      final userId = decodedToken['user_id'];

      if (userId == null) {
        return ApiResponse<User>.error(
          error: ApiError(
            statusCode: 401,
            message: 'Invalid token format',
            type: ApiErrorType.clientError,
          ),
        );
      }

      final response = await _apiService.get<User>(
        '${Variables.apiProfileEndpoint}$userId',
        fromJson: (data) => User.fromJson(data),
        requiresAuth: true,
        showLoading: true,
      );

      return response;
    } catch (e) {
      return ApiResponse<User>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Failed to get user profile: ${e.toString()}',
          type: ApiErrorType.unknown,
        ),
      );
    }
  }

  // Update user profile
  Future<ApiResponse<User>> updateUserProfile({
    required int id,
    required String fullName,
    required String idNum,
    required String address,
    required int postalCode,
    required String city,
    required String state,
    required String country,
    required int hpNumber,
    required int user,
  }) async {
    try {
      final token = await SecureStorage().readSecureData('token');
      if (token == 'No data found!!') {
        return ApiResponse<User>.error(
          error: ApiError(
            statusCode: 401,
            message: 'No authentication token found',
            type: ApiErrorType.clientError,
          ),
        );
      }

      final decodedToken = JwtDecoder.decode(token);
      final userId = decodedToken['user_id'];

      if (userId == null) {
        return ApiResponse<User>.error(
          error: ApiError(
            statusCode: 401,
            message: 'Invalid token format',
            type: ApiErrorType.clientError,
          ),
        );
      }

      // Try using PATCH method first, fallback to POST if it fails
      print('Making profile update request to: ${Variables.apiProfileEndpoint}$userId');
      print('Request body: ${{
        'full_name': fullName,
        'id_num': idNum,
        'address': address,
        'postal_code': postalCode,
        'city': city,
        'state': state,
        'country': country,
        'hp_number': hpNumber,
      }}');

      ApiResponse<User> response;
      
      try {
        // Try PATCH first
        response = await _apiService.patch<User>(
          '${Variables.apiProfileEndpoint}$userId',
          body: {
            'full_name': fullName,
            'id_num': idNum,
            'address': address,
            'postal_code': postalCode,
            'city': city,
            'state': state,
            'country': country,
            'hp_number': hpNumber,
          },
          fromJson: (data) => User.fromJson(data),
          requiresAuth: true,
          showLoading: true,
        );
        
        // If PATCH fails with method not allowed, try POST
        if (!response.isSuccess && response.error?.message?.contains('Method') == true) {
          print('PATCH failed, trying POST method...');
          response = await _apiService.post<User>(
            '${Variables.apiProfileEndpoint}$userId',
            body: {
              'full_name': fullName,
              'id_num': idNum,
              'address': address,
              'postal_code': postalCode,
              'city': city,
              'state': state,
              'country': country,
              'hp_number': hpNumber,
            },
            fromJson: (data) => User.fromJson(data),
            requiresAuth: true,
            showLoading: true,
          );
        }
      } catch (e) {
        print('PATCH failed with exception, trying POST method...');
        response = await _apiService.post<User>(
          '${Variables.apiProfileEndpoint}$userId',
          body: {
            'full_name': fullName,
            'id_num': idNum,
            'address': address,
            'postal_code': postalCode,
            'city': city,
            'state': state,
            'country': country,
            'hp_number': hpNumber,
          },
          fromJson: (data) => User.fromJson(data),
          requiresAuth: true,
          showLoading: true,
        );
      }

      print('Profile update response:');
      print('Success: ${response.isSuccess}');
      print('Message: ${response.message}');
      if (response.error != null) {
        print('Error: ${response.error!.message}');
        print('Error Type: ${response.error!.type}');
        print('Status Code: ${response.error!.statusCode}');
      }

      return response;
    } catch (e) {
      return ApiResponse<User>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Failed to update user profile: ${e.toString()}',
          type: ApiErrorType.unknown,
        ),
      );
    }
  }
}

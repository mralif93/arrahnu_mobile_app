import 'dart:math';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/api_response.dart';
import '../models/api_error.dart';
import '../storage/secure_storage.dart';
import '../constant/variables.dart';
import 'api_service.dart';

class BiddingService {
  static final BiddingService _instance = BiddingService._internal();
  factory BiddingService() => _instance;
  BiddingService._internal();

  final ApiService _apiService = ApiService();

  // Get user biddings
  Future<ApiResponse<List<dynamic>>> getUserBiddings() async {
    try {
      final token = await SecureStorage().readSecureData('token');
      if (token == 'No data found!!') {
        return ApiResponse<List<dynamic>>.error(
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
        return ApiResponse<List<dynamic>>.error(
          error: ApiError(
            statusCode: 401,
            message: 'Invalid token format',
            type: ApiErrorType.clientError,
          ),
        );
      }

      final response = await _apiService.get<List<dynamic>>(
        '${Variables.apiBidListEndpoint}$userId',
        fromJson: (data) {
          return data is List ? data : [];
        },
        requiresAuth: true,
        showLoading: true,
      );

      return response;
    } catch (e) {
      return ApiResponse<List<dynamic>>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Failed to get user biddings: ${e.toString()}',
          type: ApiErrorType.unknown,
        ),
      );
    }
  }

  // Check bid count for a specific user-account combination using bidding history
  Future<ApiResponse<int>> getBidCountForUserAccount({
    required int userId,
    required String accountNumber,
  }) async {
    try {
      // Get all user biddings
      final userBiddingsResponse = await getUserBiddings();
      
      if (!userBiddingsResponse.isSuccess || userBiddingsResponse.data == null) {
        return ApiResponse<int>.error(
          error: ApiError(
            statusCode: 0,
            message: 'Failed to get user biddings for count check',
            type: ApiErrorType.unknown,
          ),
        );
      }

      // Get all products to match account numbers
      final productsResponse = await getBiddingAccounts();
      
      if (!productsResponse.isSuccess || productsResponse.data == null) {
        // Alternative: Count all bids for the user (since we can't match by account)
        // This is a fallback when the products API fails
        int totalBidCount = userBiddingsResponse.data!.length;
        return ApiResponse<int>.success(data: totalBidCount);
      }

      // Create a map of product ID to account number
      final Map<int, String> productToAccount = {};
      for (var product in productsResponse.data!) {
        if (product['page']?['acc_num'] != null) {
          productToAccount[product['id']] = product['page']['acc_num'];
        }
      }

      // Count bids for the specific account
      int bidCount = 0;
      for (var bid in userBiddingsResponse.data!) {
        final productId = bid['product'] as int?;
        final mappedAccount = productToAccount[productId];
        
        if (productId != null && mappedAccount == accountNumber) {
          bidCount++;
        }
      }

      return ApiResponse<int>.success(data: bidCount);
    } catch (e) {
      return ApiResponse<int>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Failed to check bid count: ${e.toString()}',
          type: ApiErrorType.unknown,
        ),
      );
    }
  }

  // Get total bid count from bidding history (simpler approach)
  Future<ApiResponse<int>> getTotalBidCount() async {
    try {
      print('=== TOTAL BID COUNT FROM HISTORY ===');
      
      final userBiddingsResponse = await getUserBiddings();
      
      if (!userBiddingsResponse.isSuccess || userBiddingsResponse.data == null) {
        return ApiResponse<int>.error(
          error: ApiError(
            statusCode: 0,
            message: 'Failed to get user biddings for count',
            type: ApiErrorType.unknown,
          ),
        );
      }

      int totalBidCount = userBiddingsResponse.data!.length;
      print('Total bid count from history: $totalBidCount');
      print('Bid data: ${userBiddingsResponse.data}');
      
      return ApiResponse<int>.success(data: totalBidCount);
    } catch (e) {
      return ApiResponse<int>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Failed to get total bid count: ${e.toString()}',
          type: ApiErrorType.unknown,
        ),
      );
    }
  }

  // Get bidding accounts/products
  Future<ApiResponse<List<dynamic>>> getBiddingAccounts() async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '${Variables.baseUrl}/api/collateral/',
        fromJson: (data) => data is List ? data : [],
        requiresAuth: true,
        showLoading: true,
      );

      return response;
    } catch (e) {
      return ApiResponse<List<dynamic>>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Failed to get bidding accounts: ${e.toString()}',
          type: ApiErrorType.unknown,
        ),
      );
    }
  }

  // Submit user bid
  Future<ApiResponse<Map<String, dynamic>>> submitUserBid({
    required int productId,
    required double originalPrice,
    required double bidPrice,
  }) async {
    try {
      final token = await SecureStorage().readSecureData('token');
      if (token == 'No data found!!') {
        return ApiResponse<Map<String, dynamic>>.error(
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
        return ApiResponse<Map<String, dynamic>>.error(
          error: ApiError(
            statusCode: 401,
            message: 'Invalid token format',
            type: ApiErrorType.clientError,
          ),
        );
      }

      final response = await _apiService.post<Map<String, dynamic>>(
        Variables.apiBidCreateEndpoint,
        body: {
          'reserved_price': _convertToDecimals(originalPrice, 2),
          'bid_offer': _convertToDecimals(bidPrice, 2),
          'created_at': _getCurrentDateTimeUtc(),
          'user': userId,
          'product': productId,
        },
        fromJson: (data) => data,
        requiresAuth: true,
        showLoading: true,
      );

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Failed to submit bid: ${e.toString()}',
          type: ApiErrorType.unknown,
        ),
      );
    }
  }

  // Get bidding info (branch index page)
  Future<ApiResponse<List<dynamic>>> getBiddingInfo() async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        Variables.apiPagesEndpoint,
        queryParams: {
          'type': 'product.BranchIndexPage',
          'fields': '*',
        },
        fromJson: (data) => data['items'] is List ? data['items'] : [],
        requiresAuth: false,
        showLoading: true,
      );

      return response;
    } catch (e) {
      return ApiResponse<List<dynamic>>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Failed to get bidding info: ${e.toString()}',
          type: ApiErrorType.unknown,
        ),
      );
    }
  }

  // Get gold prices
  Future<ApiResponse<List<dynamic>>> getGoldPrices() async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        Variables.apiGoldPriceEndpoint,
        fromJson: (data) => data is List ? data : [],
        requiresAuth: false,
        showLoading: true,
      );

      return response;
    } catch (e) {
      return ApiResponse<List<dynamic>>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Failed to get gold prices: ${e.toString()}',
          type: ApiErrorType.unknown,
        ),
      );
    }
  }

  // Get branch pages
  Future<ApiResponse<List<dynamic>>> getBranchPages() async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        Variables.apiPagesEndpoint,
        queryParams: {
          'type': 'product.BranchPage',
          'fields': '*',
        },
        fromJson: (data) => data['items'] is List ? data['items'] : [],
        requiresAuth: false,
        showLoading: true,
      );

      return response;
    } catch (e) {
      return ApiResponse<List<dynamic>>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Failed to get branch pages: ${e.toString()}',
          type: ApiErrorType.unknown,
        ),
      );
    }
  }

  // Get collateral data
  Future<ApiResponse<List<dynamic>>> getCollateralData() async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/api/collateral/',
        fromJson: (data) => data is List ? data : [],
        requiresAuth: false,
        showLoading: true,
      );

      return response;
    } catch (e) {
      return ApiResponse<List<dynamic>>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Failed to get collateral data: ${e.toString()}',
          type: ApiErrorType.unknown,
        ),
      );
    }
  }

  // Get announcement data
  Future<ApiResponse<List<dynamic>>> getAnnouncements() async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/api/announcement/',
        fromJson: (data) => data is List ? data : [],
        requiresAuth: false,
        showLoading: true,
      );

      return response;
    } catch (e) {
      return ApiResponse<List<dynamic>>.error(
        error: ApiError(
          statusCode: 0,
          message: 'Failed to get announcements: ${e.toString()}',
          type: ApiErrorType.unknown,
        ),
      );
    }
  }

  // Helper methods
  double _convertToDecimals(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  String _getCurrentDateTimeUtc() {
    var dateTime = DateTime.now();
    var val = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(dateTime);
    var offset = dateTime.timeZoneOffset;
    var hours = offset.inHours > 0 ? offset.inHours : 1; // For fixing divide by 0

    if (!offset.isNegative) {
      val = "$val+${offset.inHours.toString().padLeft(2, '0')}:${(offset.inMinutes % (hours * 60)).toString().padLeft(2, '0')}";
    } else {
      val = "$val-${(-offset.inHours).toString().padLeft(2, '0')}:${(offset.inMinutes % (hours * 60)).toString().padLeft(2, '0')}";
    }

    return val;
  }
}

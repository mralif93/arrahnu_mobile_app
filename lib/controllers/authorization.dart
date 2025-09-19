import 'dart:math';
import '../model/user.dart';
import '../storage/secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/auth_service.dart';
import '../services/bidding_service.dart';
import '../models/api_response.dart';
import '../models/api_error.dart';

class AuthController {
  //  Variables
  late String token, refresh;
  late bool isExpired = false;
  
  // Services
  final AuthService _authService = AuthService();
  final BiddingService _biddingService = BiddingService();

  // Login
  Future<ApiResponse<Map<String, dynamic>>> login(String username, String password) async {
    return await _authService.login(
      username: username,
      password: password,
    );
  }

  // Logout
  Future<ApiResponse<bool>> logout() async {
    return await _authService.logout();
  }

  // Session
  Future<bool> session() async {
    final response = await _authService.checkSession();
    return response.isSuccess && response.data == true;
  }

  // Refresh Token
  Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    return await _authService.apiService.refreshToken();
  }

  // Profile
  Future<ApiResponse<User>> getUserProfile() async {
    return await _authService.getUserProfile();
  }

  // Get User Biddings
  Future<ApiResponse<List<dynamic>>> getUserBidding() async {
    return await _biddingService.getUserBiddings();
  }

  // Get Bidding Accounts
  Future<ApiResponse<List<dynamic>>> getBiddingAccounts() async {
    return await _biddingService.getBiddingAccounts();
  }

  // get current datetime format in utc
  getCurrentDateTimeUtc() {
    var dateTime = DateTime.now();
    var val = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(dateTime);
    var offset = dateTime.timeZoneOffset;
    var hours =
        offset.inHours > 0 ? offset.inHours : 1; // For fixing divide by 0

    if (!offset.isNegative) {
      val =
          "$val+${offset.inHours.toString().padLeft(2, '0')}:${(offset.inMinutes % (hours * 60)).toString().padLeft(2, '0')}";
    } else {
      val =
          "$val-${(-offset.inHours).toString().padLeft(2, '0')}:${(offset.inMinutes % (hours * 60)).toString().padLeft(2, '0')}";
    }

    return val;
  }

  // convert to decimals
  double convertToDecimals(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  // Submit User Bid
  Future<ApiResponse<Map<String, dynamic>>> submitUserBid(productId, originalPrice, bidPrice) async {
    return await _biddingService.submitUserBid(
      productId: productId,
      originalPrice: originalPrice,
      bidPrice: bidPrice,
    );
  }

  // Update User Profile
  Future<ApiResponse<User>> updateUserProfile(
    int id,
    String fullName,
    String idNum,
    String address,
    int postalCode,
    String city,
    String state,
    String country,
    int hpNumber,
    int user,
  ) async {
    return await _authService.updateUserProfile(
      id: id,
      fullName: fullName,
      idNum: idNum,
      address: address,
      postalCode: postalCode,
      city: city,
      state: state,
      country: country,
      hpNumber: hpNumber,
      user: user,
    );
  }

  // Get Bidding Info
  Future<ApiResponse<List<dynamic>>> getBiddingInfo() async {
    return await _biddingService.getBiddingInfo();
  }

  // Check bid count for user-account combination
  Future<ApiResponse<int>> getBidCountForUserAccount(String accountNumber) async {
    try {
      final token = await SecureStorage().readSecureData('token');
      if (token == 'No data found!!') {
        return ApiResponse<int>.error(
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
        return ApiResponse<int>.error(
          error: ApiError(
            statusCode: 401,
            message: 'Invalid token format',
            type: ApiErrorType.clientError,
          ),
        );
      }

      return await _biddingService.getBidCountForUserAccount(
        userId: userId,
        accountNumber: accountNumber,
      );
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

  // Get Gold Prices
  Future<ApiResponse<List<dynamic>>> getGoldPrices() async {
    return await _biddingService.getGoldPrices();
  }

  // Get Branch Pages
  Future<ApiResponse<List<dynamic>>> getBranchPages() async {
    return await _biddingService.getBranchPages();
  }

  // Get Collateral Data
  Future<ApiResponse<List<dynamic>>> getCollateralData() async {
    return await _biddingService.getCollateralData();
  }

  // Get Announcements
  Future<ApiResponse<List<dynamic>>> getAnnouncements() async {
    return await _biddingService.getAnnouncements();
  }
}
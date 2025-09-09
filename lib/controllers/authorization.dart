import 'dart:convert';
import 'dart:math';
import '../model/user.dart';
import '../storage/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../constant/variables.dart';

class AuthController {
  //  Variables
  late String token, refresh;
  late bool isExpired = false;

  // Login
  Future login(String username, String password) async {
    try {
      final url = Uri.parse('${Variables.baseUrl}${Variables.apiTokenEndpoint}');
      final reqHeaders = {'Content-Type': 'application/json'};
      final reqBody = {
        "username": username,
        "password": password,
      };

      final res =
          await http.post(url, headers: reqHeaders, body: jsonEncode(reqBody));

      // print(res.statusCode);
      // print(res.body);

      if (res.statusCode == 200) {
        var jsonResponse = jsonDecode(res.body);
        token = jsonResponse['access'];
        refresh = jsonResponse['refresh'];

        // Stored Data
        await SecureStorage().writeSecureData("token", token);
        await SecureStorage().writeSecureData("refresh", refresh);

        return res;
      }

      return res;
    } catch (e) {
      print(e.toString());
    }
  }

  // Logout
  Future logout() async {
    try {
      await SecureStorage().deleteSecureData("token");
      await SecureStorage().deleteSecureData("refresh");
      return true;
    } catch (e) {
      print(e.toString());
    }
  }

  // Session
  Future session() async {
    token = await SecureStorage().readSecureData('token');
    if (token != 'No data found!!') {
      isExpired = JwtDecoder.isExpired(token);
      if (isExpired) {
        //  try refresh token
        // if (await refreshToken()) {
        //   return true;
        // }
        return false;
      }
      return true;
    }
    return false;
  }

  // Refresh Token
  Future refreshToken() async {
    refresh = await SecureStorage().readSecureData('refresh');

    try {
      final url = Uri.parse('${Variables.baseUrl}${Variables.apiTokenRefreshEndpoint}');
      final reqHeaders = {'Content-Type': 'application/json'};
      final reqBody = {
        "refresh": refresh,
      };

      final res =
          await http.post(url, headers: reqHeaders, body: jsonEncode(reqBody));

      if (res.statusCode == 200) {
        var jsonResponse = jsonDecode(res.body);
        token = jsonResponse['access'];

        // Stored Data
        await SecureStorage().writeSecureData("token", token);
        return true;
      }

      return false;
    } catch (e) {
      print(e.toString());
    }
  }

  // Profile
  Future getUserProfile() async {
    String token = await SecureStorage().readSecureData('token');
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int userId = decodedToken["user_id"];

    final url = Uri.parse('${Variables.baseUrl}${Variables.apiProfileEndpoint}$userId');
    Map<String, String> header = {"Authorization": "Bearer $token"};

    var response = await http.get(url, headers: header);
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }

    if (response.statusCode == 401) {
      return false;
    }

    return null;
  }

  // Get User Biddings
  Future getUserBidding() async {
    String token = await SecureStorage().readSecureData('token');
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int userId = decodedToken["user_id"];

    final url = Uri.parse('${Variables.baseUrl}${Variables.apiBidListEndpoint}${userId}');
    Map<String, String> header = {"Authorization": "Bearer $token"};

    var response = await http.get(url, headers: header);
    if (response.statusCode == 200) {
      return response.body;
    }

    if (response.statusCode == 401) {
      return false;
    }
  }

  // Get User Biddings
  Future getBiddingAccounts() async {
    String token = await SecureStorage().readSecureData('token');
    // Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    // int userId = decodedToken["user_id"];

    final url = Uri.parse(
        '${Variables.baseUrl}${Variables.apiPagesEndpoint}?type=product.ProductPage&fields=*&limit=8000');
    Map<String, String> header = {"Authorization": "Bearer $token"};

    var response = await http.get(url, headers: header);
    if (response.statusCode == 200) {
      return response.body;
    }

    if (response.statusCode == 401) {
      return false;
    }
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
  Future submitUserBid(productId, originalPrice, bidPrice) async {
    String token = await SecureStorage().readSecureData('token');
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int userId = decodedToken["user_id"];

    final url = Uri.parse('${Variables.baseUrl}${Variables.apiBidCreateEndpoint}');
    Map<String, String> reqHeaders = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
    final reqBody = {
      'reserved_price': convertToDecimals(originalPrice, 2),
      'bid_offer': convertToDecimals(bidPrice, 2),
      'created_at': getCurrentDateTimeUtc(),
      'user': userId,
      'product': productId,
    };

    final res =
        await http.post(url, headers: reqHeaders, body: jsonEncode(reqBody));

    // success
    if (res.statusCode == 200) {
      return true;
    }

    // failure
    else {
      return false;
    }
  }

  Future updateUserProfile(
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
    String token = await SecureStorage().readSecureData('token');
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int userId = decodedToken["user_id"];

    final url = Uri.parse('${Variables.baseUrl}${Variables.apiProfileEndpoint}$userId');
    Map<String, String> reqHeaders = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    final reqBody = {
      'id': id,
      'full_name': fullName,
      'id_num': idNum,
      'address': address,
      'postal_code': postalCode,
      'city': city,
      'state': state,
      'country': country,
      'hp_number': hpNumber,
      "user": user,
    };

    final res =
        await http.post(url, headers: reqHeaders, body: jsonEncode(reqBody));

    // success
    if (res.statusCode == 200) {
      return true;
    }
    // failure
    else {
      return false;
    }
  }
}

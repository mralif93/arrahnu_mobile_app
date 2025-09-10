import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../components/QAvatar.dart';
import '../components/QButton.dart';
import '../components/QListTiles.dart';
import '../constant/variables.dart';
import '../controllers/authorization.dart';
import '../model/user.dart';
import 'biddings.dart';
import 'branch.dart';
import 'navigation.dart';
import 'profile.dart';
import 'login.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // variables
  bool statusView = false;
  bool _isLoggedIn = false;
  var profile = User(
    id: 0,
    idNum: '',
    fullName: '',
    address: '',
    postalCode: 0,
    city: '',
    state: '',
    country: '',
    hpNumber: 0,
    user: 0,
  );

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    final res = await AuthController().session();
    setState(() {
      _isLoggedIn = res;
    });
    
    if (_isLoggedIn) {
      fetchProfile();
      checkBidingTime();
    }
  }

  void fetchProfile() async {
    final response = await AuthController().getUserProfile();
    if (response.isSuccess && response.data != null) {
      setState(() {
        profile = response.data!;
      });
    }
  }

  void signOutUser() {
    Get.defaultDialog(
      title: Variables.confirmSignOutTitle,
      middleText: Variables.signOutConfirmText,
      textConfirm: 'Yes',
      textCancel: 'No',
      onConfirm: () async {
        try {
          final response = await AuthController().logout();
          if (response.isSuccess && response.data == true) {
            setState(() {
              _isLoggedIn = false;
              profile = User(
                id: 0,
                idNum: '',
                fullName: '',
                address: '',
                postalCode: 0,
                city: '',
                state: '',
                country: '',
                hpNumber: 0,
                user: 0,
              );
            });
            Get.offAll(const NavigationPage());
          }
        } on Exception catch (e) {
          print(e);
        }
      },
      onCancel: () {},
    );
  }

  Future checkBidingTime() async {
    try {
      // Get data from API
      var response = await http.get(Uri.parse(
          '${Variables.baseUrl}${Variables.apiPagesEndpoint}?type=product.BranchIndexPage&fields=*'));
      if (response.statusCode == 200) {
        // Parse JSON to Dart object
        Map<String, dynamic> jsonData = jsonDecode(response.body);

        var currentDate = DateTime.now();
        var startDate =
            DateTime.parse(jsonData['items'][0]["start_bidding_session"]);
        var endDate = DateTime.parse(jsonData['items'][0]["end_bidding_session"]);

        if (currentDate.compareTo(startDate) == 1 &&
            currentDate.compareTo(endDate) == 1) {
          setState(() {
            statusView = false;
          });
        } else if (currentDate.compareTo(startDate) == 1 &&
            currentDate.compareTo(endDate) == -1) {
          setState(() {
            statusView = true;
          });
        } else if (currentDate.compareTo(startDate) == -1 &&
            currentDate.compareTo(endDate) == -1) {
          setState(() {
            statusView = false;
          });
        }
      }
    } catch (e) {
      print('Error checking bidding time: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Account icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.account_circle_outlined,
                      size: 60,
                      color: Colors.orange[600],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Welcome text
                Text(
                  'Welcome to Your Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[800],
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Please sign in to access your account features',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(const LoginPage());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Uri registerUrl = Uri.parse("${Variables.baseUrl}${Variables.signupUrl}");
                        if (await canLaunchUrl(registerUrl)) {
                          await launchUrl(registerUrl);
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              // Welcome message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_circle,
                      size: 48,
                      color: Colors.orange[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Colors.orange[800],
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your account and bidding activities',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // my avatar
              QAvatar(
                name: profile.fullName,
                mobile: '+60${profile.hpNumber}',
                image: Variables.defaultAvatarUrl,
              ),

              const SizedBox(height: 32),

              // my profile
              QListTiles(
                text: 'My Profile',
                onTap: () {
                  Get.to(const ProfilePage());
                },
              ),

              const SizedBox(height: 16),

              // my bidding
              QListTiles(
                text: 'My Bidding',
                onTap: () {
                  Get.to(const BiddingPage());
                },
              ),

              const SizedBox(height: 16),

              if (statusView)
                QListTiles(
                  text: 'Bidding Now !!',
                  onTap: () {
                    Get.to(const BranchPage());
                  },
                ),

              const SizedBox(height: 48),

              // button sign out
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: signOutUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red[600],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red[200]!),
                    ),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

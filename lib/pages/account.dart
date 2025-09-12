import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../components/QAvatar.dart';
import '../components/QButton.dart';
import '../components/QListTiles.dart';
import '../constant/variables.dart';
import '../theme/app_theme.dart';
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
    final scaleFactor = AppTheme.getScaleFactor(context);
    
    if (!_isLoggedIn) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Account icon
                Container(
                  width: AppTheme.responsiveSize(120, scaleFactor),
                  height: AppTheme.responsiveSize(120, scaleFactor),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusCircular, scaleFactor)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.account_circle_outlined,
                      size: AppTheme.responsiveSize(AppTheme.iconXXXLarge, scaleFactor),
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                ),

                SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXXXLarge, scaleFactor)),

                // Welcome text
                Text(
                  'Welcome to Your Account',
                  style: AppTheme.getWelcomeStyle(scaleFactor),
                ),

                SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),

                Text(
                  'Please sign in to access your account features',
                  style: AppTheme.getCaptionStyle(scaleFactor),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  height: AppTheme.responsiveSize(56, scaleFactor),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(const LoginPage());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: AppTheme.textWhite,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusLarge, scaleFactor)),
                      ),
                    ),
                    child: Text(
                      'Sign In',
                      style: AppTheme.getButtonTextStyle(scaleFactor),
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
                      style: AppTheme.getCaptionStyle(scaleFactor),
                    ),
                    TextButton(
                      onPressed: () async {
                        Uri registerUrl = Uri.parse("${Variables.baseUrl}${Variables.signupUrl}");
                        if (await canLaunchUrl(registerUrl)) {
                          await launchUrl(registerUrl);
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 0, 
                          vertical: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor),
                        ),
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppTheme.primaryOrange,
                          fontWeight: AppTheme.fontWeightSemiBold,
                          fontSize: AppTheme.responsiveSize(AppTheme.fontSizeMedium, scaleFactor),
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
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingXXXLarge, scaleFactor)),
          child: Column(
            children: [
              // Welcome message
              Container(
                width: double.infinity,
                padding: AppTheme.getCardPadding(scaleFactor),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusXLarge, scaleFactor)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_circle,
                      size: AppTheme.responsiveSize(AppTheme.iconXXXLarge, scaleFactor),
                      color: AppTheme.primaryOrange,
                    ),
                    SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),
                    Text(
                      'Welcome back!',
                      style: AppTheme.getTitleStyle(scaleFactor),
                    ),
                    SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                    Text(
                      'Manage your account and bidding activities',
                      style: AppTheme.getCaptionStyle(scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXXXLarge, scaleFactor)),

              // my avatar
              QAvatar(
                name: profile.fullName,
                mobile: '+60${profile.hpNumber}',
                image: Variables.defaultAvatarUrl,
              ),

              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXXXLarge, scaleFactor)),

              // my profile
              QListTiles(
                text: 'My Profile',
                onTap: () {
                  Get.to(const ProfilePage());
                },
              ),

              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),

              // my bidding
              QListTiles(
                text: 'My Bidding',
                onTap: () {
                  Get.to(const BiddingPage());
                },
              ),

              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),

              if (statusView)
                QListTiles(
                  text: 'Bidding Now !!',
                  onTap: () {
                    Get.to(const BranchPage());
                  },
                ),

              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXXXLarge, scaleFactor)),

              // button sign out
              SizedBox(
                width: double.infinity,
                height: AppTheme.responsiveSize(56, scaleFactor),
                child: ElevatedButton(
                  onPressed: signOutUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryRed.withOpacity(0.1),
                    foregroundColor: AppTheme.secondaryRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusLarge, scaleFactor)),
                      side: BorderSide(color: AppTheme.secondaryRed.withOpacity(0.3)),
                    ),
                  ),
                  child: Text(
                    'Sign Out',
                    style: AppTheme.getButtonTextStyle(scaleFactor),
                  ),
                ),
              ),

              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXXXLarge, scaleFactor)),
            ],
          ),
        ),
      ),
    );
  }
}

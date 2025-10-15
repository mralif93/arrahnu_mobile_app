import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../components/QAvatar.dart';
import '../components/QButton.dart';
import '../components/QListTiles.dart';
import '../components/sweet_alert.dart';
import '../constant/variables.dart';
import '../theme/app_theme.dart';
import '../controllers/authorization.dart';
import '../model/user.dart';
import 'biddings.dart';
import 'branch.dart';
import 'navigation.dart';
import 'profile.dart';
import 'home.dart';
import 'prices.dart';
import 'calculator.dart';
import 'login.dart';
import 'campaign.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // variables
  bool statusView = false;
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

    // extra
    checkSession();
    fetchProfile();
    checkBidingTime();
  }

  void checkSession() async {
    final res = await AuthController().session();
    if (!res) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false);
      }
      return;
    }
  }

  Future<void> fetchProfile() async {
    final response = await AuthController().getUserProfile();
    if (response.isSuccess && response.data != null) {
      if (mounted) {
        setState(() {
          profile = response.data!;
        });
      }
    }
  }

  void _showLogoutDialog() {
    SweetAlert.confirm(
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
      onConfirm: () async {
        await _performLogout();
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final response = await AuthController().logout();

      // Close loading dialog
      Get.back();

      if (response.isSuccess && response.data == true) {
        // Show success message
        Get.snackbar(
          'Success',
          'You have been signed out successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Navigate to campaign page
        Get.offAll(const CampaignPage());
      } else {
        // Show error message
        Get.snackbar(
          'Error',
          'Failed to sign out. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      // Show error message
      Get.snackbar(
        'Error',
        'An error occurred during sign out: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> checkBidingTime() async {
    try {
      var response = await http.get(Uri.parse(
          '${Variables.baseUrl}/api/v2/pages/?type=product.BranchIndexPage&fields=*'));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        var items = jsonData['items'];
        if (items.isNotEmpty) {
          var startDate = DateTime.parse(items[0]['start_bidding_session']);
          var endDate = DateTime.parse(items[0]['end_bidding_session']);
          var currentDate = DateTime.now();

          if (currentDate.compareTo(startDate) == 1 &&
              currentDate.compareTo(endDate) == -1) {
            print('Bidding is active!');
            if (mounted) {
              setState(() {
                statusView = true;
              });
            }
          } else if (currentDate.compareTo(startDate) == -1) {
            print('Bidding has not started yet!');
            if (mounted) {
              setState(() {
                statusView = false;
              });
            }
          } else if (currentDate.compareTo(endDate) == 1 ||
              currentDate.compareTo(endDate) == 0) {
            print('Already Done Bidding!');
            if (mounted) {
              setState(() {
                statusView = false;
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error checking bidding time: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: AppTheme.textWhite,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: AppTheme.getAppBarTitleStyle(scaleFactor),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: Icon(
              Icons.logout,
              color: AppTheme.textWhite,
              size: AppTheme.responsiveSize(AppTheme.iconXXLarge, scaleFactor),
            ),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchProfile();
          await checkBidingTime();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Welcome Header
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryOrange,
                      AppTheme.primaryOrangeDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusXLarge, scaleFactor)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withOpacity(0.15),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
                      decoration: BoxDecoration(
                        color: AppTheme.textWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusSmall, scaleFactor)),
                      ),
                      child: Icon(
                        Icons.person,
                        size: AppTheme.responsiveSize(AppTheme.iconXLarge, scaleFactor),
                        color: AppTheme.textWhite,
                      ),
                    ),
                    SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                              color: AppTheme.textWhite.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
                          Text(
                            profile.fullName.isNotEmpty ? profile.fullName : 'Bidding User',
                            style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                              color: AppTheme.textWhite,
                              fontWeight: AppTheme.fontWeightBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Add spacing between welcome card and quick actions
              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXLarge, scaleFactor)),
              
              // Quick Actions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: AppTheme.getIconCirclePadding(scaleFactor),
                          decoration: AppTheme.getIconCircleDecoration(AppTheme.primaryOrange, scaleFactor),
                          child: Icon(
                            Icons.flash_on,
                            color: AppTheme.primaryOrange,
                            size: AppTheme.responsiveSize(AppTheme.iconMedium, scaleFactor),
                          ),
                        ),
                        SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                        Text(
                          'Quick Actions',
                          style: AppTheme.getHeaderStyle(scaleFactor).copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                    Wrap(
                      spacing: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor),
                      runSpacing: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor),
                      children: [
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 
                                 AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor) * 2 - 
                                 AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)) / 2,
                          child: _buildActionCard(
                            'Join Live Bidding',
                            'Participate in active auctions',
                            Icons.gavel,
                            const Color(0xFFFE8000),
                            () => Get.to(const HomePage()),
                            scaleFactor,
                          ),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 
                                 AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor) * 2 - 
                                 AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)) / 2,
                          child: _buildActionCard(
                            'My Bidding History',
                            'View all your bids',
                            Icons.list_alt,
                            const Color(0xFF3B82F6),
                            () => Get.to(const BiddingPage()),
                            scaleFactor,
                          ),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 
                                 AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor) * 2 - 
                                 AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)) / 2,
                          child: _buildActionCard(
                            'Gold Price',
                            'Check current rates',
                            Icons.trending_up,
                            const Color(0xFF10B981),
                            () => Get.to(const PricesPage()),
                            scaleFactor,
                          ),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 
                                 AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor) * 2 - 
                                 AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)) / 2,
                          child: _buildActionCard(
                            'Calculator',
                            'Estimate values',
                            Icons.calculate,
                            const Color(0xFF06B6D4),
                            () => Get.to(const CalculatorPage()),
                            scaleFactor,
                          ),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 
                                 AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor) * 2 - 
                                 AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)) / 2,
                          child: _buildActionCard(
                            'My Profile',
                            'Update your details',
                            Icons.person,
                            const Color(0xFF8B5CF6),
                            () => Get.to(const ProfilePage()),
                            scaleFactor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Add bottom padding
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }


  // Helper method to build action cards
  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap, double scaleFactor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
        decoration: AppTheme.getCardDecoration(scaleFactor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: AppTheme.getIconCirclePadding(scaleFactor),
              decoration: AppTheme.getIconCircleDecoration(color, scaleFactor),
              child: Icon(
                icon,
                color: color,
                size: AppTheme.responsiveSize(AppTheme.iconLarge, scaleFactor),
              ),
            ),
            SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
            Flexible(
              child: Text(
                title,
                style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                  fontWeight: AppTheme.fontWeightBold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
            Flexible(
              child: Text(
                subtitle,
                style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
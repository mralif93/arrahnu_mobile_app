import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
import 'home.dart';
import 'prices.dart';
import 'calculator.dart';

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
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => NavigationPage()),
          (route) => false);
      return;
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

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _performLogout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
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
        
        // Navigate to login page
        Get.offAll(const NavigationPage());
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

  void checkBidingTime() async {
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
            setState(() {
              statusView = true;
            });
          } else if (currentDate.compareTo(startDate) == -1) {
            print('Bidding has not started yet!');
            setState(() {
              statusView = false;
            });
          } else if (currentDate.compareTo(endDate) == 1 ||
              currentDate.compareTo(endDate) == 0) {
            print('Already Done Bidding!');
            setState(() {
              statusView = false;
            });
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
          'Bidding Dashboard',
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
          setState(() {
            fetchProfile();
            checkBidingTime();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
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
                      color: AppTheme.primaryOrange.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
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
                  ],
                ),
              ),
              
              // Bidding Statistics
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Active Bids',
                        '12',
                        Icons.gavel,
                        AppTheme.secondaryBlue,
                        scaleFactor,
                      ),
                    ),
                    SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                    Expanded(
                      child: _buildStatCard(
                        'Won Auctions',
                        '8',
                        Icons.emoji_events,
                        AppTheme.secondaryGreen,
                        scaleFactor,
                      ),
                    ),
                    SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                    Expanded(
                      child: _buildStatCard(
                        'Total Spent',
                        'RM 45K',
                        Icons.attach_money,
                        AppTheme.secondaryPurple,
                        scaleFactor,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
              
              // Quick Actions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            'Join Live Bidding',
                            'Participate in active auctions',
                            Icons.gavel,
                            const Color(0xFFFE8000),
                            () => Get.to(const HomePage()),
                            scaleFactor,
                          ),
                        ),
                        SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                        Expanded(
                          child: _buildActionCard(
                            'My Bidding History',
                            'View all your bids',
                            Icons.history,
                            const Color(0xFF3B82F6),
                            () => Get.to(const BiddingPage()),
                            scaleFactor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            'Gold Price',
                            'Check current rates',
                            Icons.trending_up,
                            const Color(0xFF10B981),
                            () => Get.to(const PricesPage()),
                            scaleFactor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            'Calculator',
                            'Estimate values',
                            Icons.calculate,
                            const Color(0xFF06B6D4),
                            () => Get.to(const CalculatorPage()),
                            scaleFactor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Recent Activity
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: AppTheme.getIconCirclePadding(scaleFactor),
                          decoration: AppTheme.getIconCircleDecoration(AppTheme.secondaryBlue, scaleFactor),
                          child: Icon(
                            Icons.history,
                            color: AppTheme.secondaryBlue,
                            size: AppTheme.responsiveSize(AppTheme.iconMedium, scaleFactor),
                          ),
                        ),
                        SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                        Text(
                          'Recent Activity',
                          style: AppTheme.getHeaderStyle(scaleFactor).copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildActivityItem(
                      'Won Gold Ring Auction',
                      '2 hours ago',
                      Icons.emoji_events,
                      Colors.green,
                      scaleFactor,
                    ),
                    _buildActivityItem(
                      'Placed bid on Silver Chain',
                      '1 day ago',
                      Icons.gavel,
                      Colors.orange,
                      scaleFactor,
                    ),
                    _buildActivityItem(
                      'Updated profile information',
                      '3 days ago',
                      Icons.person,
                      Colors.blue,
                      scaleFactor,
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

  // Helper method to build stat cards
  Widget _buildStatCard(String title, String value, IconData icon, Color color, double scaleFactor) {
    return Container(
      padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
      decoration: AppTheme.getCardDecoration(scaleFactor),
      child: Column(
        children: [
          Container(
            padding: AppTheme.getIconCirclePadding(scaleFactor),
            decoration: AppTheme.getIconCircleDecoration(color, scaleFactor),
            child: Icon(
              icon,
              color: color,
              size: AppTheme.responsiveSize(AppTheme.iconSmall, scaleFactor),
            ),
          ),
          SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
          Text(
            value,
            style: AppTheme.getBodyStyle(scaleFactor).copyWith(
              color: AppTheme.textPrimary,
              fontWeight: AppTheme.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
          Text(
            title,
            style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
              color: AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

  // Helper method to build activity items
  Widget _buildActivityItem(String title, String time, IconData icon, Color color, double scaleFactor) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
      padding: AppTheme.getCardPadding(scaleFactor),
      decoration: AppTheme.getCardDecoration(scaleFactor),
      child: Row(
        children: [
          Container(
            padding: AppTheme.getIconCirclePadding(scaleFactor),
            decoration: AppTheme.getIconCircleDecoration(color, scaleFactor),
            child: Icon(
              icon,
              color: color,
              size: AppTheme.responsiveSize(AppTheme.iconXLarge, scaleFactor),
            ),
          ),
          SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                    fontWeight: AppTheme.fontWeightSemiBold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
                Text(
                  time,
                  style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
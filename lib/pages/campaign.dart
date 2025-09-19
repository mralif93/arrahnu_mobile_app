import "package:flutter/material.dart";
import "package:carousel_slider/carousel_slider.dart";
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';

import '../constant/variables.dart';
import '../theme/app_theme.dart';
import 'home.dart';
import 'dashboard.dart';
import 'login.dart';
import 'features.dart';
import 'prices.dart';
import 'calculator.dart';
import '../controllers/authorization.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({super.key});

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  // Variables
  final _controller = CarouselSliderController();
  int _activeIndex = 0;
  bool statusView = false;
  List items = [
    {
      "id": 8,
      "title": Variables.campaignTitle1,
      "description": Variables.campaignDescription1,
      "image": Variables.promotionImage1,
      "datetime_created": Variables.campaignDatetimeCreated1,
      "datetime_modified": Variables.campaignDatetimeModified1,
      "is_active": true,
      "is_default": true,
      "staff": Variables.campaignStaffId,
      "created_by": Variables.campaignCreatedBy,
      "updated_by": Variables.campaignUpdatedBy
    },
    {
      "id": 9,
      "title": Variables.campaignTitle1,
      "description": Variables.campaignDescription1,
      "image": Variables.promotionImage1,
      "datetime_created": Variables.campaignDatetimeCreated1,
      "datetime_modified": Variables.campaignDatetimeModified1,
      "is_active": true,
      "is_default": true,
      "staff": Variables.campaignStaffId,
      "created_by": Variables.campaignCreatedBy,
      "updated_by": Variables.campaignUpdatedBy
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchPoster();
    checkBidingTime();
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            fetchPoster();
            checkBidingTime();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Add top padding for status bar
              SizedBox(height: MediaQuery.of(context).padding.top),
              
              // Header section with logo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/muamalat_logo_01.png",
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick Actions Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
                child: Row(
                  children: [
                    Container(
                      padding: AppTheme.getIconCirclePadding(scaleFactor),
                      decoration: AppTheme.getIconCircleDecoration(AppTheme.primaryOrange, scaleFactor),
                      child: Icon(
                        Icons.flash_on,
                        color: AppTheme.primaryOrange,
                        size: AppTheme.responsiveSize(AppTheme.iconXLarge, scaleFactor),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingMedium),
                    Text(
                      'Quick Actions',
                      style: AppTheme.getSubtitleStyle(scaleFactor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick Actions Cards - Horizontal Scrollable
              Container(
                margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
                padding: EdgeInsets.all(AppTheme.spacingXLarge),
                decoration: AppTheme.getCardDecoration(scaleFactor),
                child: SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildActionCard(
                        icon: Icons.gavel_outlined,
                        title: 'Bidding',
                        color: const Color(0xFF3B82F6),
                            onTap: () => Get.to(const HomePage()),
                      ),
                      const SizedBox(width: 12),
                      _buildActionCard(
                        icon: Icons.account_circle_outlined,
                        title: 'Account',
                        color: const Color(0xFF8B5CF6),
                        onTap: () => _handleAccountTap(),
                      ),
                      const SizedBox(width: 12),
                      _buildActionCard(
                        icon: Icons.info_outlined,
                        title: 'Features',
                        color: const Color(0xFFF59E0B),
                        onTap: () => Get.to(const FeaturesPage()),
                      ),
                      const SizedBox(width: 12),
                      _buildActionCard(
                        icon: Icons.trending_up,
                        title: 'Gold Price',
                        color: const Color(0xFF10B981),
                        onTap: () => Get.to(const PricesPage()),
                      ),
                      const SizedBox(width: 12),
                      _buildActionCard(
                        icon: Icons.calculate_outlined,
                        title: 'Calculator',
                        color: const Color(0xFF06B6D4),
                        onTap: () => Get.to(const CalculatorPage()),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Our Campaigns Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
                child: Row(
                  children: [
                    Container(
                      padding: AppTheme.getIconCirclePadding(scaleFactor),
                      decoration: AppTheme.getIconCircleDecoration(AppTheme.primaryOrange, scaleFactor),
                      child: Icon(
                        Icons.campaign,
                        color: AppTheme.primaryOrange,
                        size: AppTheme.responsiveSize(AppTheme.iconXLarge, scaleFactor),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingMedium),
                    Text(
                      'Our Campaigns',
                      style: AppTheme.getSubtitleStyle(scaleFactor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Our Campaigns Content
              Container(
                margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
                padding: EdgeInsets.all(AppTheme.spacingXLarge),
                decoration: AppTheme.getCardDecoration(scaleFactor),
                child: Column(
                  children: [
                    if (items.isEmpty)
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.campaign_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No campaigns available',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Check back later for new promotions',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      CarouselSlider.builder(
                        carouselController: _controller,
                        itemCount: items.length,
                        itemBuilder: (context, index, realIndex) {
                          return _buildCampaignCard(items[index], index);
                        },
                        options: CarouselOptions(
                          height: 280,
                          aspectRatio: 1.2,
                          viewportFraction: 0.85,
                          initialPage: 0,
                          enableInfiniteScroll: true,
                          reverse: false,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 4),
                          autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                          autoPlayCurve: Curves.easeInOut,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _activeIndex = index;
                            });
                          },
                        ),
                      ),
                    if (items.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Center(child: buildIndicator()),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),
              // Add bottom padding to extend to device bottom
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  // Action card widget
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppTheme.responsiveSize(90, scaleFactor),
        height: AppTheme.responsiveSize(90, scaleFactor),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusLarge, scaleFactor)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.responsiveSize(8, scaleFactor)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.responsiveSize(12, scaleFactor)),
              child: Icon(
                icon,
                color: color,
                size: AppTheme.responsiveSize(AppTheme.iconXXXLarge, scaleFactor),
              ),
              ),
              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTheme.responsiveSize(AppTheme.fontSizeSmall, scaleFactor),
                    fontWeight: AppTheme.fontWeightSemiBold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Campaign card widget
  Widget _buildCampaignCard(Map<String, dynamic> campaign, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.network(
                campaign['image'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFE8000).withOpacity(0.8),
                          const Color(0xFFFF9500).withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            
          ],
        ),
      ),
    );
  }

  // Page indicator
  Widget buildIndicator() {
    return AnimatedSmoothIndicator(
      activeIndex: _activeIndex,
      count: items.length,
      effect: const ExpandingDotsEffect(
        dotWidth: 10,
        dotHeight: 10,
        activeDotColor: Color(0xFFFE8000),
        dotColor: Colors.grey,
        spacing: 8,
        expansionFactor: 3,
      ),
    );
  }

  // Handle account tap
  void _handleAccountTap() async {
    final isLoggedIn = await AuthController().session();
    if (isLoggedIn) {
      Get.to(const DashboardPage());
    } else {
      Get.to(const LoginPage());
    }
  }

  Future<void> fetchPoster() async {
    try {
      final response =
          await http.get(Uri.parse('${Variables.baseUrl}/api/announcement/'));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          items = jsonData['results'];
        });
      }
    } catch (e) {
      print('Error fetching poster: $e');
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
}
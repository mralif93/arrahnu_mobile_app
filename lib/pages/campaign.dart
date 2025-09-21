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
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            fetchPoster();
            checkBidingTime();
          });
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Add top padding for status bar
              SizedBox(height: MediaQuery.of(context).padding.top),
              
              // Header section with logo - Responsive for iPad/iPhone
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 768 
                    ? AppTheme.spacingXLarge 
                    : AppTheme.spacingLarge,
                  vertical: MediaQuery.of(context).size.width > 768 
                    ? AppTheme.spacingXLarge 
                    : AppTheme.spacingMedium,
                ),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/muamalat_logo_01.png",
                      width: MediaQuery.of(context).size.width > 768 
                        ? AppTheme.responsiveSize(320, scaleFactor)
                        : AppTheme.responsiveSize(280, scaleFactor),
                      height: MediaQuery.of(context).size.width > 768 
                        ? AppTheme.responsiveSize(140, scaleFactor)
                        : AppTheme.responsiveSize(120, scaleFactor),
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.width > 768 ? 24 : 16),

              // Enhanced Quick Actions Section - Responsive for iPad/iPhone
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 768 
                    ? AppTheme.spacingXLarge 
                    : AppTheme.spacingLarge,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width > 768 
                          ? AppTheme.responsiveSize(14, scaleFactor)
                          : AppTheme.responsiveSize(12, scaleFactor),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFE8000),
                            const Color(0xFFFF9500),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width > 768 
                            ? AppTheme.responsiveSize(18, scaleFactor)
                            : AppTheme.responsiveSize(15, scaleFactor),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFE8000).withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.flash_on_rounded,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width > 768 
                          ? AppTheme.responsiveSize(AppTheme.iconXXLarge, scaleFactor)
                          : AppTheme.responsiveSize(AppTheme.iconXLarge, scaleFactor),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingMedium),
                    Text(
                      'Quick Actions',
                      style: AppTheme.getSubtitleStyle(scaleFactor).copyWith(
                        fontWeight: AppTheme.fontWeightBold,
                        color: const Color(0xFF1E293B),
                        fontSize: MediaQuery.of(context).size.width > 768 
                          ? AppTheme.responsiveSize(AppTheme.fontSizeLarge, scaleFactor)
                          : AppTheme.responsiveSize(AppTheme.fontSizeMedium, scaleFactor),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.width > 768 ? 24 : 20),

              // Enhanced Quick Actions Cards - Responsive Grid
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 768 
                    ? AppTheme.spacingXLarge 
                    : AppTheme.spacingLarge,
                ),
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width > 768 
                    ? AppTheme.spacingXXLarge 
                    : AppTheme.spacingXLarge,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width > 768 
                      ? AppTheme.responsiveSize(24, scaleFactor)
                      : AppTheme.responsiveSize(20, scaleFactor),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _buildHorizontalActionList(scaleFactor),
              ),

              SizedBox(height: MediaQuery.of(context).size.width > 768 ? 40 : 32),

              // Enhanced Our Campaigns Section - Responsive
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 768 
                    ? AppTheme.spacingXLarge 
                    : AppTheme.spacingLarge,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width > 768 
                          ? AppTheme.responsiveSize(14, scaleFactor)
                          : AppTheme.responsiveSize(12, scaleFactor),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFE8000),
                            const Color(0xFFFF9500),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width > 768 
                            ? AppTheme.responsiveSize(18, scaleFactor)
                            : AppTheme.responsiveSize(15, scaleFactor),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFE8000).withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.campaign_rounded,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width > 768 
                          ? AppTheme.responsiveSize(AppTheme.iconXXLarge, scaleFactor)
                          : AppTheme.responsiveSize(AppTheme.iconXLarge, scaleFactor),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingMedium),
                    Text(
                      'Our Campaigns',
                      style: AppTheme.getSubtitleStyle(scaleFactor).copyWith(
                        fontWeight: AppTheme.fontWeightBold,
                        color: const Color(0xFF1E293B),
                        fontSize: MediaQuery.of(context).size.width > 768 
                          ? AppTheme.responsiveSize(AppTheme.fontSizeLarge, scaleFactor)
                          : AppTheme.responsiveSize(AppTheme.fontSizeMedium, scaleFactor),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.width > 768 ? 24 : 20),

              // Enhanced Our Campaigns Content - Responsive
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 768 
                    ? AppTheme.spacingXLarge 
                    : AppTheme.spacingLarge,
                ),
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width > 768 
                    ? AppTheme.spacingXXLarge 
                    : AppTheme.spacingXLarge,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width > 768 
                      ? AppTheme.responsiveSize(24, scaleFactor)
                      : AppTheme.responsiveSize(20, scaleFactor),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (items.isEmpty)
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.grey[50]!,
                              Colors.grey[100]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.responsiveSize(16, scaleFactor)),
                          border: Border.all(color: Colors.grey[200]!, width: 1),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppTheme.responsiveSize(20, scaleFactor)),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(AppTheme.responsiveSize(50, scaleFactor)),
                                ),
                                child: Icon(
                                  Icons.campaign_outlined,
                                  size: AppTheme.responsiveSize(48, scaleFactor),
                                  color: Colors.grey[500],
                                ),
                              ),
                              SizedBox(height: AppTheme.responsiveSize(16, scaleFactor)),
                              Text(
                                'No campaigns available',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: AppTheme.responsiveSize(18, scaleFactor),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: AppTheme.responsiveSize(8, scaleFactor)),
                              Text(
                                'Check back later for new promotions',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: AppTheme.responsiveSize(14, scaleFactor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      _buildDynamicCampaignCarousel(),
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


  // Responsive Horizontal Action List for All Devices
  Widget _buildHorizontalActionList(double scaleFactor) {
    final isTablet = MediaQuery.of(context).size.width > 768;
    
    return SizedBox(
      height: isTablet 
        ? AppTheme.responsiveSize(140, scaleFactor)
        : AppTheme.responsiveSize(120, scaleFactor),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildEnhancedActionCard(
            icon: Icons.gavel_rounded,
            title: 'Bidding',
            subtitle: 'Live Auctions',
            color: const Color(0xFF3B82F6),
            onTap: () => Get.to(const HomePage()),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          _buildEnhancedActionCard(
            icon: Icons.account_circle_rounded,
            title: 'Account',
            subtitle: 'Profile & Login',
            color: const Color(0xFF8B5CF6),
            onTap: () => _handleAccountTap(),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          _buildEnhancedActionCard(
            icon: Icons.info_rounded,
            title: 'Features',
            subtitle: 'App Info',
            color: const Color(0xFFF59E0B),
            onTap: () => Get.to(const FeaturesPage()),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          _buildEnhancedActionCard(
            icon: Icons.trending_up_rounded,
            title: 'Gold Price',
            subtitle: 'Current Rates',
            color: const Color(0xFF10B981),
            onTap: () => Get.to(const PricesPage()),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          _buildEnhancedActionCard(
            icon: Icons.calculate_rounded,
            title: 'Calculator',
            subtitle: 'Estimate Value',
            color: const Color(0xFF06B6D4),
            onTap: () => Get.to(const CalculatorPage()),
          ),
        ],
      ),
    );
  }

  // Enhanced Action card widget - Responsive
  Widget _buildEnhancedActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    final isTablet = MediaQuery.of(context).size.width > 768;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isTablet 
          ? AppTheme.responsiveSize(120, scaleFactor)
          : AppTheme.responsiveSize(100, scaleFactor),
        height: isTablet 
          ? AppTheme.responsiveSize(120, scaleFactor)
          : AppTheme.responsiveSize(100, scaleFactor),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(
            isTablet 
              ? AppTheme.responsiveSize(24, scaleFactor)
              : AppTheme.responsiveSize(20, scaleFactor),
          ),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(
            isTablet 
              ? AppTheme.responsiveSize(16, scaleFactor)
              : AppTheme.responsiveSize(12, scaleFactor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(
                  isTablet 
                    ? AppTheme.responsiveSize(14, scaleFactor)
                    : AppTheme.responsiveSize(10, scaleFactor),
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(
                    isTablet 
                      ? AppTheme.responsiveSize(16, scaleFactor)
                      : AppTheme.responsiveSize(12, scaleFactor),
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isTablet 
                    ? AppTheme.responsiveSize(AppTheme.iconXXLarge, scaleFactor)
                    : AppTheme.responsiveSize(AppTheme.iconLarge, scaleFactor),
                ),
              ),
              SizedBox(height: AppTheme.responsiveSize(8, scaleFactor)),
              Text(
                title,
                style: TextStyle(
                  fontSize: isTablet 
                    ? AppTheme.responsiveSize(AppTheme.fontSizeMedium, scaleFactor)
                    : AppTheme.responsiveSize(AppTheme.fontSizeSmall, scaleFactor),
                  fontWeight: AppTheme.fontWeightBold,
                  color: const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppTheme.responsiveSize(2, scaleFactor)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: isTablet 
                    ? AppTheme.responsiveSize(AppTheme.fontSizeSmall, scaleFactor)
                    : AppTheme.responsiveSize(AppTheme.fontSizeTiny, scaleFactor),
                  fontWeight: AppTheme.fontWeightMedium,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Legacy Action card widget (keeping for compatibility)
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _buildEnhancedActionCard(
      icon: icon,
      title: title,
      subtitle: '',
      color: color,
      onTap: onTap,
    );
  }

  // Enhanced Campaign card widget - Responsive
  Widget _buildEnhancedCampaignCard(Map<String, dynamic> campaign, int index) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    final isTablet = MediaQuery.of(context).size.width > 768;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          isTablet 
            ? AppTheme.responsiveSize(24, scaleFactor)
            : AppTheme.responsiveSize(20, scaleFactor),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: isTablet ? 20 : 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          isTablet 
            ? AppTheme.responsiveSize(24, scaleFactor)
            : AppTheme.responsiveSize(20, scaleFactor),
        ),
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
                          const Color(0xFFFE8000),
                          const Color(0xFFFF9500),
                          const Color(0xFFFFB84D),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.campaign_rounded,
                            color: Colors.white,
                            size: isTablet 
                              ? AppTheme.responsiveSize(50, scaleFactor)
                              : AppTheme.responsiveSize(40, scaleFactor),
                          ),
                          SizedBox(height: AppTheme.responsiveSize(8, scaleFactor)),
                          Text(
                            'Campaign Image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet 
                                ? AppTheme.responsiveSize(16, scaleFactor)
                                : AppTheme.responsiveSize(14, scaleFactor),
                              fontWeight: AppTheme.fontWeightMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey[200]!,
                          Colors.grey[300]!,
                        ],
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFFFE8000),
                        strokeWidth: 3,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(
                  isTablet 
                    ? AppTheme.responsiveSize(24, scaleFactor)
                    : AppTheme.responsiveSize(20, scaleFactor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      campaign['title'] ?? 'Campaign Title',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet 
                          ? AppTheme.responsiveSize(24, scaleFactor)
                          : AppTheme.responsiveSize(20, scaleFactor),
                        fontWeight: AppTheme.fontWeightBold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppTheme.responsiveSize(8, scaleFactor)),
                    Text(
                      campaign['description'] ?? 'Campaign description goes here...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isTablet 
                          ? AppTheme.responsiveSize(16, scaleFactor)
                          : AppTheme.responsiveSize(14, scaleFactor),
                        fontWeight: AppTheme.fontWeightMedium,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      maxLines: isTablet ? 4 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dynamic Campaign Carousel that adapts to image height
  Widget _buildDynamicCampaignCarousel() {
    final isTablet = MediaQuery.of(context).size.width > 768;
    
    return CarouselSlider.builder(
      carouselController: _controller,
      itemCount: items.length,
      itemBuilder: (context, index, realIndex) {
        return _buildDynamicCampaignCard(items[index], index);
      },
      options: CarouselOptions(
        height: null, // Let the content determine height
        aspectRatio: isTablet ? 1.4 : 1.2, // Slightly wider for better poster display
        viewportFraction: isTablet ? 0.75 : 0.9,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 1200),
        autoPlayCurve: Curves.easeInOutCubic,
        enlargeCenterPage: true,
        onPageChanged: (index, reason) {
          setState(() {
            _activeIndex = index;
          });
        },
      ),
    );
  }

  // Dynamic Campaign card that adapts to image dimensions
  Widget _buildDynamicCampaignCard(Map<String, dynamic> campaign, int index) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    final isTablet = MediaQuery.of(context).size.width > 768;
    
    return GestureDetector(
      onTap: () => _showCampaignModal(campaign),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isTablet ? 8 : 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            isTablet 
              ? AppTheme.responsiveSize(24, scaleFactor)
              : AppTheme.responsiveSize(20, scaleFactor),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: isTablet ? 20 : 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            isTablet 
              ? AppTheme.responsiveSize(24, scaleFactor)
              : AppTheme.responsiveSize(20, scaleFactor),
          ),
          child: Stack(
            children: [
              // Background Image with dynamic sizing
              Positioned.fill(
                child: Image.network(
                  campaign['image'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: isTablet ? 300 : 250, // Fallback height
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFE8000),
                            const Color(0xFFFF9500),
                            const Color(0xFFFFB84D),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.campaign_rounded,
                              color: Colors.white,
                              size: isTablet 
                                ? AppTheme.responsiveSize(50, scaleFactor)
                                : AppTheme.responsiveSize(40, scaleFactor),
                            ),
                            SizedBox(height: AppTheme.responsiveSize(8, scaleFactor)),
                            Text(
                              'Campaign Image',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet 
                                  ? AppTheme.responsiveSize(16, scaleFactor)
                                  : AppTheme.responsiveSize(14, scaleFactor),
                                fontWeight: AppTheme.fontWeightMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: isTablet ? 300 : 250, // Loading height
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[200]!,
                            Colors.grey[300]!,
                          ],
                        ),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xFFFE8000),
                          strokeWidth: 3,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Click indicator overlay
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.all(
                    isTablet 
                      ? AppTheme.responsiveSize(12, scaleFactor)
                      : AppTheme.responsiveSize(10, scaleFactor),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(
                      isTablet 
                        ? AppTheme.responsiveSize(20, scaleFactor)
                        : AppTheme.responsiveSize(16, scaleFactor),
                    ),
                  ),
                  child: Icon(
                    Icons.zoom_in_rounded,
                    color: Colors.white,
                    size: isTablet 
                      ? AppTheme.responsiveSize(24, scaleFactor)
                      : AppTheme.responsiveSize(20, scaleFactor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show campaign modal with full poster and details
  void _showCampaignModal(Map<String, dynamic> campaign) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    final isTablet = MediaQuery.of(context).size.width > 768;
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 600 : MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              isTablet 
                ? AppTheme.responsiveSize(24, scaleFactor)
                : AppTheme.responsiveSize(20, scaleFactor),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Container(
                padding: EdgeInsets.all(
                  isTablet 
                    ? AppTheme.responsiveSize(20, scaleFactor)
                    : AppTheme.responsiveSize(16, scaleFactor),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFE8000),
                      const Color(0xFFFF9500),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      isTablet 
                        ? AppTheme.responsiveSize(24, scaleFactor)
                        : AppTheme.responsiveSize(20, scaleFactor),
                    ),
                    topRight: Radius.circular(
                      isTablet 
                        ? AppTheme.responsiveSize(24, scaleFactor)
                        : AppTheme.responsiveSize(20, scaleFactor),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.campaign_rounded,
                      color: Colors.white,
                      size: isTablet 
                        ? AppTheme.responsiveSize(28, scaleFactor)
                        : AppTheme.responsiveSize(24, scaleFactor),
                    ),
                    SizedBox(width: AppTheme.responsiveSize(12, scaleFactor)),
                    Expanded(
                      child: Text(
                        'Campaign Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet 
                            ? AppTheme.responsiveSize(20, scaleFactor)
                            : AppTheme.responsiveSize(18, scaleFactor),
                          fontWeight: AppTheme.fontWeightBold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(
                          isTablet 
                            ? AppTheme.responsiveSize(8, scaleFactor)
                            : AppTheme.responsiveSize(6, scaleFactor),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            isTablet 
                              ? AppTheme.responsiveSize(12, scaleFactor)
                              : AppTheme.responsiveSize(10, scaleFactor),
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: isTablet 
                            ? AppTheme.responsiveSize(20, scaleFactor)
                            : AppTheme.responsiveSize(18, scaleFactor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Campaign Image
              Flexible(
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(
                        isTablet 
                          ? AppTheme.responsiveSize(24, scaleFactor)
                          : AppTheme.responsiveSize(20, scaleFactor),
                      ),
                      bottomRight: Radius.circular(
                        isTablet 
                          ? AppTheme.responsiveSize(24, scaleFactor)
                          : AppTheme.responsiveSize(20, scaleFactor),
                      ),
                    ),
                    child: Image.network(
                      campaign['image'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFFE8000),
                                const Color(0xFFFF9500),
                                const Color(0xFFFFB84D),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.campaign_rounded,
                                  color: Colors.white,
                                  size: AppTheme.responsiveSize(50, scaleFactor),
                                ),
                                SizedBox(height: AppTheme.responsiveSize(8, scaleFactor)),
                                Text(
                                  'Campaign Image',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppTheme.responsiveSize(16, scaleFactor),
                                    fontWeight: AppTheme.fontWeightMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.grey[200]!,
                                Colors.grey[300]!,
                              ],
                            ),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: const Color(0xFFFE8000),
                              strokeWidth: 3,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // Campaign Details
              Container(
                padding: EdgeInsets.all(
                  isTablet 
                    ? AppTheme.responsiveSize(24, scaleFactor)
                    : AppTheme.responsiveSize(20, scaleFactor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign['title'] ?? 'Campaign Title',
                      style: TextStyle(
                        color: const Color(0xFF1E293B),
                        fontSize: isTablet 
                          ? AppTheme.responsiveSize(24, scaleFactor)
                          : AppTheme.responsiveSize(20, scaleFactor),
                        fontWeight: AppTheme.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTheme.responsiveSize(12, scaleFactor)),
                    Text(
                      campaign['description'] ?? 'Campaign description goes here...',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: isTablet 
                          ? AppTheme.responsiveSize(16, scaleFactor)
                          : AppTheme.responsiveSize(14, scaleFactor),
                        fontWeight: AppTheme.fontWeightMedium,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: AppTheme.responsiveSize(20, scaleFactor)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFE8000),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet 
                              ? AppTheme.responsiveSize(16, scaleFactor)
                              : AppTheme.responsiveSize(14, scaleFactor),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              isTablet 
                                ? AppTheme.responsiveSize(12, scaleFactor)
                                : AppTheme.responsiveSize(10, scaleFactor),
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            fontSize: isTablet 
                              ? AppTheme.responsiveSize(16, scaleFactor)
                              : AppTheme.responsiveSize(14, scaleFactor),
                            fontWeight: AppTheme.fontWeightBold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // Legacy Campaign card widget (keeping for compatibility)
  Widget _buildCampaignCard(Map<String, dynamic> campaign, int index) {
    return _buildEnhancedCampaignCard(campaign, index);
  }

  // Enhanced Page indicator
  Widget buildIndicator() {
    return AnimatedSmoothIndicator(
      activeIndex: _activeIndex,
      count: items.length,
      effect: ExpandingDotsEffect(
        dotWidth: 12,
        dotHeight: 12,
        activeDotColor: const Color(0xFFFE8000),
        dotColor: Colors.grey[300]!,
        spacing: 10,
        expansionFactor: 3.5,
        radius: 6,
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
        if (mounted) {
          setState(() {
            items = jsonData['results'];
          });
        }
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
}
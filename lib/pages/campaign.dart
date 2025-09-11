import "package:flutter/material.dart";
import "package:carousel_slider/carousel_slider.dart";
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';

import '../components/QCard.dart';
import '../constant/variables.dart';
import 'home.dart';
import 'account.dart';
import 'dashboard.dart';
import 'login.dart';
import 'features.dart';
import 'prices.dart';
import 'calculator.dart';
import 'branch.dart';
import '../controllers/authorization.dart';
import '../storage/secure_storage.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildActionTile(
                            icon: Icons.gavel_outlined,
                            title: 'Bidding',
                            color: const Color(0xFF3B82F6),
                            onTap: () => Get.to(const HomePage()),
                          ),
                          const SizedBox(width: 12),
                          _buildActionTile(
                            icon: Icons.account_circle_outlined,
                            title: 'Account',
                            color: const Color(0xFF8B5CF6),
                            onTap: () => _handleAccountTap(),
                          ),
                          const SizedBox(width: 12),
                          _buildActionTile(
                            icon: Icons.info_outlined,
                            title: 'Features',
                            color: const Color(0xFFF59E0B),
                            onTap: () => Get.to(const FeaturesPage()),
                          ),
                          const SizedBox(width: 12),
                          _buildActionTile(
                            icon: Icons.trending_up,
                            title: 'Gold Price',
                            color: const Color(0xFF10B981),
                            onTap: () => Get.to(const PricesPage()),
                          ),
                          const SizedBox(width: 12),
                          _buildActionTile(
                            icon: Icons.calculate_outlined,
                            title: 'Calculator',
                            color: const Color(0xFF06B6D4),
                            onTap: () => Get.to(const CalculatorPage()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Campaign carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Campaigns',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 16),
                    CarouselSlider.builder(
                      carouselController: _controller,
                      itemCount: items.length,
                      itemBuilder: (context, index, realIndex) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              items[index]['image'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.error_outline,
                                      color: Colors.grey,
                                      size: 50,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: 200,
                        aspectRatio: 1.3,
                        viewportFraction: 0.8,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _activeIndex = index;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(child: buildIndicator()),
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

  // Action tile widget
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
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
        dotWidth: 8,
        dotHeight: 8,
        activeDotColor: Color(0xFFFE8000),
        dotColor: Colors.grey,
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
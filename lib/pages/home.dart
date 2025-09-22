import 'branch_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../constant/variables.dart';
import '../theme/app_theme.dart';
import '../controllers/authorization.dart';
import '../services/session_service.dart';
import '../components/QButton.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var height = 0.0, width = 0.0;
  List items = [];
  List products = [];
  List branches = [];
  bool statusView = false;
  String _currentTime = '';
  Map<String, dynamic>? _biddingData;
  bool _isSessionActive = false;
  final SessionService _sessionService = SessionService();

  final _images = [
    Variables.assetProductFeatures,
    Variables.assetGoldPrice,
    Variables.assetCalculator,
    Variables.assetAuction,
  ];

  @override
  void initState() {
    super.initState();
    _currentTime = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());
    _initializeSession();
  }

  @override
  void dispose() {
    _sessionService.dispose();
    super.dispose();
  }

  Future<void> _initializeSession() async {
    await _sessionService.initializeSession();
    if (mounted) {
      setState(() {
        _isSessionActive = _sessionService.isSessionActive;
      });
    }
    
    // Listen to session status changes
    _sessionService.sessionStatusStream.listen((isActive) {
      if (mounted) {
        setState(() {
          _isSessionActive = isActive;
        });
      }
    });
  }

  void _handleBrowseItemsTap() async {
    // Double-check session status before navigation
    final isSessionActive = await _sessionService.refreshSessionStatus();
    
    if (isSessionActive) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BranchSelectionPage()),
      );
    } else {
      // Show error message if session is not active
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Browsing is not available. The bidding session has ended.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    final scaleFactor = AppTheme.getScaleFactor(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: AppTheme.textWhite,
        elevation: 0,
        title: Text(
          'Home',
          style: AppTheme.getAppBarTitleStyle(scaleFactor),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            checkBidingTime();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header section with logo
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor),
                  vertical: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/pajak-orange.png",
                      width: AppTheme.responsiveSize(280, scaleFactor),
                      height: AppTheme.responsiveSize(120, scaleFactor),
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),

              // Bidding session cards
              FutureBuilder(
                future: fetchBiddingInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      padding: EdgeInsets.all(AppTheme.responsiveSize(40, scaleFactor)),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: AppTheme.responsiveSize(60, scaleFactor),
                              height: AppTheme.responsiveSize(60, scaleFactor),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusCircular, scaleFactor)),
                              ),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                                strokeWidth: 3,
                              ),
                            ),
                            SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXLarge, scaleFactor)),
                            Text(
                              'Loading bidding information...',
                              style: AppTheme.getBodyStyle(scaleFactor),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Container(
                      padding: EdgeInsets.all(AppTheme.responsiveSize(40, scaleFactor)),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: AppTheme.responsiveSize(AppTheme.iconXXXLarge, scaleFactor),
                            color: AppTheme.secondaryRed,
                          ),
                          SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXLarge, scaleFactor)),
                          Text(
                            'Unable to Load Data',
                            style: AppTheme.getHeaderStyle(scaleFactor).copyWith(
                              color: AppTheme.secondaryRed,
                            ),
                          ),
                          SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                          Text(
                            'Please check your connection and try again',
                            style: AppTheme.getCaptionStyle(scaleFactor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final data = snapshot.data!;
                    final startBidding = DateTime.parse(data[0]["start_bidding_session"]).toLocal();
                    final endBidding = DateTime.parse(data[0]["end_bidding_session"]).toLocal();
                    final now = DateTime.now();
                    final timeUntilStart = startBidding.difference(now);
                    final timeUntilEnd = endBidding.difference(now);

                    return Column(
                      children: [
                        // Start time card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                          margin: EdgeInsets.symmetric(
                            horizontal: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor), 
                            vertical: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor),
                          ),
                          decoration: AppTheme.getCardDecoration(scaleFactor),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
                                decoration: AppTheme.getIconCircleDecoration(AppTheme.primaryOrange, scaleFactor),
                                child: Icon(
                                  Icons.play_arrow,
                                  size: AppTheme.responsiveSize(AppTheme.iconMedium, scaleFactor),
                                  color: AppTheme.primaryOrange,
                                ),
                              ),
                              SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Variables.biddingStartText,
                                      style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                                        color: AppTheme.primaryOrange,
                                        fontWeight: AppTheme.fontWeightSemiBold,
                                      ),
                                    ),
                                    SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
                                    Text(
                                      '${DateFormat('dd/MM/yyyy hh:mm a').format(startBidding)} (${DateFormat('EEEE').format(startBidding)})',
                                      style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                                        color: AppTheme.primaryOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // End time card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                          margin: EdgeInsets.symmetric(
                            horizontal: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor), 
                            vertical: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor),
                          ),
                          decoration: AppTheme.getCardDecoration(scaleFactor),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
                                decoration: AppTheme.getIconCircleDecoration(AppTheme.primaryOrange, scaleFactor),
                                child: Icon(
                                  Icons.stop,
                                  size: AppTheme.responsiveSize(AppTheme.iconMedium, scaleFactor),
                                  color: AppTheme.primaryOrange,
                                ),
                              ),
                              SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Variables.biddingEndText,
                                      style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                                        color: AppTheme.primaryOrange,
                                        fontWeight: AppTheme.fontWeightSemiBold,
                                      ),
                                    ),
                                    SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
                                    Text(
                                      '${DateFormat('dd/MM/yyyy hh:mm a').format(endBidding)} (${DateFormat('EEEE').format(endBidding)})',
                                      style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                                        color: AppTheme.primaryOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                        // Status section
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                          margin: EdgeInsets.symmetric(
                            horizontal: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor), 
                            vertical: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor),
                          ),
                          decoration: AppTheme.getCardDecoration(scaleFactor),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(),
                                  borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusSmall, scaleFactor)),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  size: AppTheme.responsiveSize(AppTheme.iconMedium, scaleFactor),
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bidding Session Status',
                                      style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
                                    Text(
                                      _getStaticStatusText(),
                                      style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                                        fontWeight: AppTheme.fontWeightBold,
                                        color: _getStatusColor(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bidding Button - Only show if session is active and data is loaded
                        if (_isSessionActive) ...[
                          QButton(
                            text: 'Browse Items',
                            onPressed: () {
                              _handleBrowseItemsTap();
                            },
                            backgroundColor: AppTheme.primaryOrange,
                            foregroundColor: AppTheme.textWhite,
                            elevation: 4,
                            shadowColor: AppTheme.primaryOrange.withOpacity(0.3),
                            height: AppTheme.responsiveSize(AppTheme.buttonHeightSmall, scaleFactor),
                            fontSize: AppTheme.responsiveSize(12, scaleFactor),
                            fontWeight: AppTheme.fontWeightMedium,
                            icon: Icon(
                              Icons.gavel,
                              size: AppTheme.responsiveSize(16, scaleFactor),
                              color: AppTheme.textWhite,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor),
                              vertical: AppTheme.responsiveSize(6, scaleFactor),
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor), 
                              vertical: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor),
                            ),
                          ),
                        ] else ...[
                          // Session ended message
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                              horizontal: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor), 
                              vertical: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor),
                            ),
                            padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusLarge, scaleFactor)),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.red,
                                  size: AppTheme.responsiveSize(AppTheme.iconMedium, scaleFactor),
                                ),
                                SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                                Expanded(
                                  child: Text(
                                    'Browsing is not available. The bidding session has ended.',
                                    style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                                      color: Colors.red[700],
                                      fontWeight: AppTheme.fontWeightMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: Colors.green[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            Variables.goodStatusText,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              
              // Add bottom padding to extend to device bottom
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCountdown(Duration duration) {
    if (duration.isNegative) {
      return 'Started';
    }
    
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    return '${days}d ${hours}h ${minutes}m ${seconds}s';
  }

  String _getStatusText(Duration timeUntilStart, Duration timeUntilEnd) {
    if (timeUntilStart.isNegative && timeUntilEnd.isNegative) {
      return 'Bidding Session Has Ended';
    } else if (timeUntilStart.isNegative && !timeUntilEnd.isNegative) {
      return 'Ends in: ${_formatCountdown(timeUntilEnd)}';
    } else {
      return _formatCountdown(timeUntilStart);
    }
  }

  Color _getStatusColor() {
    if (_biddingData != null) {
      try {
        final startBidding = DateTime.parse(_biddingData!["start_bidding_session"]).toLocal();
        final endBidding = DateTime.parse(_biddingData!["end_bidding_session"]).toLocal();
        final now = DateTime.now();
        final timeUntilStart = startBidding.difference(now);
        final timeUntilEnd = endBidding.difference(now);

        if (timeUntilStart.isNegative && timeUntilEnd.isNegative) {
          return Colors.red;
        } else if (timeUntilStart.isNegative && !timeUntilEnd.isNegative) {
          return Colors.green;
        } else {
          return Colors.orange;
        }
      } catch (e) {
        return Colors.grey;
      }
    }
    return Colors.grey;
  }

  String _getStaticStatusText() {
    if (_biddingData != null) {
      try {
        final startBidding = DateTime.parse(_biddingData!["start_bidding_session"]).toLocal();
        final endBidding = DateTime.parse(_biddingData!["end_bidding_session"]).toLocal();
        final now = DateTime.now();
        final timeUntilStart = startBidding.difference(now);
        final timeUntilEnd = endBidding.difference(now);

        if (timeUntilStart.isNegative && timeUntilEnd.isNegative) {
          return 'Session Ended';
        } else if (timeUntilStart.isNegative && !timeUntilEnd.isNegative) {
          return 'Live Now';
        } else {
          return 'Starting Soon';
        }
      } catch (e) {
        return 'Unknown';
      }
    }
    return 'Unknown';
  }

  Future<void> checkBidingTime() async {
    try {
      var response = await http.get(Uri.parse(
          '${Variables.baseUrl}/api/v2/pages/?type=product.BranchIndexPage&fields=*'));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        var items = jsonData['items'];
        if (items.isNotEmpty) {
          setState(() {
            _biddingData = items[0];
          });
        }
      }
    } catch (e) {
      print('Error checking bidding time: $e');
    }
  }

  Future<List<dynamic>> fetchBiddingInfo() async {
    try {
      final response = await http.get(Uri.parse(
          '${Variables.baseUrl}/api/v2/pages/?type=product.BranchIndexPage&fields=*'));
      
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        items = jsonData['items'];
        if (items.isNotEmpty) {
          _biddingData = items[0];
        }
        return jsonData['items'];
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load data: ${e.toString()}');
    }
  }
}
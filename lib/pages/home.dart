import 'package:bmmb_pajak_gadai_i/pages/branch.dart';
import 'package:bmmb_pajak_gadai_i/pages/calculator.dart';
import 'package:bmmb_pajak_gadai_i/pages/features.dart';
import 'package:bmmb_pajak_gadai_i/pages/prices.dart';
import 'package:bmmb_pajak_gadai_i/pages/branch_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../constant/variables.dart';
import '../controllers/authorization.dart';

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
    checkBidingTime();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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

              const SizedBox(height: 8),

              // Bidding session cards
              FutureBuilder(
                future: fetchBiddingInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFE8000).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFE8000)),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Loading bidding information...',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 40,
                            color: Colors.red[600],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Unable to Load Data',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please check your connection and try again',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
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
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFE8000),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Variables.biddingStartText,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFFE8000),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${DateFormat('dd/MM/yyyy hh:mm a').format(startBidding)} (${DateFormat('EEEE').format(startBidding)})',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFFE8000),
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
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFE8000),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.stop,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Variables.biddingEndText,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFFE8000),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${DateFormat('dd/MM/yyyy hh:mm a').format(endBidding)} (${DateFormat('EEEE').format(endBidding)})',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFFE8000),
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
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.info_outline,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Bidding Session Status',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _getStaticStatusText(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: _getStatusColor(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
              
              // Bidding Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BranchSelectionPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFE8000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFFFE8000).withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.gavel,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Browse Items',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
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
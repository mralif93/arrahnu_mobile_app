import 'dart:convert';
import 'package:bmmb_pajak_gadai_i/constant/style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/bidding.dart';
import '../pages/navigation.dart';
import '../controllers/authorization.dart';

class BiddingPage extends StatefulWidget {
  const BiddingPage({super.key});

  @override
  State<BiddingPage> createState() => _BiddingPageState();
}

class _BiddingPageState extends State<BiddingPage> {
  // variable
  late var biddingsData = [];

  // variable to call and store future list of biddings
  Future<List<Bidding>> biddingsFuture = getBiddings();
  // function to fetch data from api and return future list of biddings
  static Future<List<Bidding>> getBiddings() async {
    final response = await AuthController().getUserBidding();
    if (response.isSuccess && response.data != null) {
      return response.data!.map((e) => Bidding.fromJson(e)).toList();
    }
    return [];
  }

  // get matching ID for title page
  Future getAccountBiddings() async {
    final response1 = await AuthController().getUserBidding();
    final response2 = await AuthController().getBiddingAccounts();
    
    if (!response1.isSuccess || !response2.isSuccess) {
      return;
    }
    
    var jsonData1 = response1.data!;
    var jsonData2 = response2.data!;

    if (jsonData1.length > 0) {
      for (var k = 0; k < jsonData1.length; k++) {
        if (jsonData2.length > 0) {
          for (var i = 0; i < jsonData2.length; i++) {
            if (jsonData1[k]['product'] == jsonData2[i]['id']) {
              jsonData1[k]['title'] = jsonData2[i]['title'];
            }
          }
        }
      }

      setState(() {
        biddingsData = jsonData1;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkSession();
    getAccountBiddings();
  }

  // check session
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

  @override
  Widget build(BuildContext context) {
    // Calculate responsive font sizes
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = (screenWidth / 375).clamp(0.4, 0.7);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFE8000),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "My Biddings",
          style: TextStyle(
            fontSize: (20 * scaleFactor).toDouble(),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Bidding>>(
        future: biddingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState(scaleFactor);
          } else if (snapshot.hasData && biddingsData.isNotEmpty) {
            return _buildBiddingsList(scaleFactor);
          } else {
            return _buildEmptyState(scaleFactor);
          }
        },
      ),
    );
  }

  // Modern loading state
  Widget _buildLoadingState(double scaleFactor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFE8000),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your biddings...',
            style: TextStyle(
              fontSize: (16 * scaleFactor).toDouble(),
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Modern empty state
  Widget _buildEmptyState(double scaleFactor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.gavel_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Biddings Yet',
              style: TextStyle(
                fontSize: (20 * scaleFactor).toDouble(),
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t placed any bids yet.\nStart bidding to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: (14 * scaleFactor).toDouble(),
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE8000),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Start Bidding',
                style: TextStyle(
                  fontSize: (16 * scaleFactor).toDouble(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern biddings list
  Widget _buildBiddingsList(double scaleFactor) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          getAccountBiddings();
        });
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: biddingsData.length,
        itemBuilder: (context, index) {
          final bid = biddingsData[index];
          return _buildBiddingCard(bid, scaleFactor, index);
        },
      ),
    );
  }

  // Modern bidding card
  Widget _buildBiddingCard(Map<String, dynamic> bid, double scaleFactor, int index) {
    final reservedPrice = double.tryParse(bid['reserved_price']?.toString() ?? '0') ?? 0;
    final bidPrice = double.tryParse(bid['bid_offer']?.toString() ?? '0') ?? 0;
    final isWinning = bidPrice >= reservedPrice;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isWinning ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isWinning ? 'Winning' : 'Active',
                    style: TextStyle(
                      fontSize: (12 * scaleFactor).toDouble(),
                      fontWeight: FontWeight.w600,
                      color: isWinning ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.gavel,
                  size: (20 * scaleFactor).toDouble(),
                  color: const Color(0xFFFE8000),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              bid['title'] ?? 'Untitled Item',
              style: TextStyle(
                fontSize: (18 * scaleFactor).toDouble(),
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            
            // Price information
            Row(
              children: [
                Expanded(
                  child: _buildPriceInfo(
                    'Reserved Price',
                    'RM ${reservedPrice.toStringAsFixed(2)}',
                    Icons.price_check,
                    Colors.grey[600]!,
                    scaleFactor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPriceInfo(
                    'Your Bid',
                    'RM ${bidPrice.toStringAsFixed(2)}',
                    Icons.attach_money,
                    const Color(0xFFFE8000),
                    scaleFactor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Created date
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: (16 * scaleFactor).toDouble(),
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 8),
                Text(
                  'Bid placed on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(bid['created_at']).toLocal())}',
                  style: TextStyle(
                    fontSize: (12 * scaleFactor).toDouble(),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Price info widget
  Widget _buildPriceInfo(String label, String value, IconData icon, Color color, double scaleFactor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: (16 * scaleFactor).toDouble(),
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: (12 * scaleFactor).toDouble(),
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: (16 * scaleFactor).toDouble(),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

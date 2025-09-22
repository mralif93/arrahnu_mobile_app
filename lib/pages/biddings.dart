import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/bidding.dart';
import '../theme/app_theme.dart';
import '../pages/navigation.dart';
import '../pages/login.dart';
import '../controllers/authorization.dart';

class BiddingPage extends StatefulWidget {
  const BiddingPage({super.key});

  @override
  State<BiddingPage> createState() => _BiddingPageState();
}

class _BiddingPageState extends State<BiddingPage> {
  // variable
  late var biddingsData = [];
  bool isLoading = true;

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
    setState(() {
      isLoading = true;
    });

    final response1 = await AuthController().getUserBidding();
    
    if (!response1.isSuccess || response1.data == null) {
      setState(() {
        biddingsData = [];
        isLoading = false;
      });
      return;
    }
    
    var jsonData1 = response1.data!;

    // Try to get accounts data for title matching, but don't fail if it doesn't work
    final response2 = await AuthController().getCollateralData();
    
    var jsonData2 = response2.isSuccess && response2.data != null ? response2.data! : [];

    if (jsonData1.length > 0) {
      // Add default title and account info if no accounts data available
      for (var k = 0; k < jsonData1.length; k++) {
        jsonData1[k]['title'] = ''; // Default title
        jsonData1[k]['branch'] = 'Unknown Branch'; // Default branch
        jsonData1[k]['account_number'] = 'Unknown Account'; // Default account
        
        // Try to match with accounts data if available
        if (jsonData2.length > 0) {
          bool found = false;
          for (var i = 0; i < jsonData2.length; i++) {
            // Match using Page->ID instead of direct ID
            if (jsonData1[k]['product'] == jsonData2[i]['page']?['id']) {
              jsonData1[k]['title'] = jsonData2[i]['title'];
              // Extract branch and account info from the collateral data
              if (jsonData2[i]['page'] != null) {
                jsonData1[k]['branch'] = jsonData2[i]['page']['branch']?['title'] ?? 'Unknown Branch';
                
                // Try to get full account name format (FEB21/JMKA/14010016899759000)
                String fullAccountName = 'Unknown Account';
                
                // Check for full_account_name field first
                if (jsonData2[i]['page']['full_account_name'] != null) {
                  fullAccountName = jsonData2[i]['page']['full_account_name'];
                } else if (jsonData2[i]['page']['title'] != null) {
                  // Check if page.title contains the full account name format
                  fullAccountName = jsonData2[i]['page']['title'];
                } else {
                  // Try to construct the full account name from available fields
                  String accNum = jsonData2[i]['page']['acc_num'] ?? '';
                  String branchCode = jsonData2[i]['page']['branch']?['branch_code'] ?? '';
                  String branchTitle = jsonData2[i]['page']['branch']?['title'] ?? '';
                  
                  // Try different field combinations to construct full name
                  if (jsonData2[i]['page']['account_code'] != null) {
                    fullAccountName = '${jsonData2[i]['page']['account_code']}/$accNum';
                  } else if (branchCode.isNotEmpty) {
                    fullAccountName = '$branchCode/$accNum';
                  } else if (branchTitle.isNotEmpty) {
                    // Extract code from branch title (e.g., "JALAN MELAKA" -> "JMKA")
                    String extractedCode = _extractBranchCode(branchTitle);
                    fullAccountName = '$extractedCode/$accNum';
                  } else if (accNum.isNotEmpty) {
                    fullAccountName = accNum;
                  }
                }
                
                jsonData1[k]['account_number'] = fullAccountName;
              }
              found = true;
              break;
            }
          }
        }
      }
    }

    setState(() {
      biddingsData = jsonData1;
      isLoading = false;
    });
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
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false);
      return;
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
          'My Biddings',
          style: AppTheme.getAppBarTitleStyle(scaleFactor),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? _buildLoadingState(scaleFactor)
          : biddingsData.isNotEmpty
              ? _buildBiddingsList(scaleFactor)
              : _buildEmptyState(scaleFactor),
    );
  }

  // Modern loading state
  Widget _buildLoadingState(double scaleFactor) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: GridView.count(
          crossAxisCount: 1,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          childAspectRatio: 1.0,
          children: [
            // Centered content using Grid
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Bank Muamalat Logo
                  Container(
                    width: 200,
                    height: 80,
                    child: Image.asset(
                      "assets/images/muamalat_logo_01.png",
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                  
                  SizedBox(height: 60),
                  
                  // Circular Progress Indicator
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                      strokeWidth: 4,
                      backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.2),
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Loading text
                  Container(
                    width: 250,
                    child: Text(
                      'Loading bidding information...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern empty state
  Widget _buildEmptyState(double scaleFactor) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingXXXLarge, scaleFactor)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppTheme.responsiveSize(100, scaleFactor),
              height: AppTheme.responsiveSize(100, scaleFactor),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(AppTheme.responsiveSize(50, scaleFactor)),
              ),
              child: Icon(
                Icons.gavel_outlined,
                size: AppTheme.responsiveSize(AppTheme.iconXXXLarge, scaleFactor),
                color: AppTheme.textMuted,
              ),
            ),
            SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXLarge, scaleFactor)),
            Text(
              'No Biddings Yet',
              style: AppTheme.getTitleStyle(scaleFactor).copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
            Text(
              'You haven\'t placed any bids yet.\nStart bidding to see them here.',
              textAlign: TextAlign.center,
              style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXLarge, scaleFactor)),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: AppTheme.textWhite,
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.responsiveSize(AppTheme.spacingXXXLarge, scaleFactor),
                  vertical: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusLarge, scaleFactor)),
                ),
              ),
              child: Text(
                'Start Bidding',
                style: AppTheme.getButtonTextStyle(scaleFactor),
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
        padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),
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
      margin: EdgeInsets.only(bottom: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),
      decoration: AppTheme.getCardDecoration(scaleFactor),
      child: Padding(
        padding: AppTheme.getCardPadding(scaleFactor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gavel icon and account number
            Row(
              children: [
                Icon(
                  Icons.gavel,
                  size: AppTheme.responsiveSize(AppTheme.iconLarge, scaleFactor),
                  color: AppTheme.primaryOrange,
                ),
                SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                Text(
                  bid['account_number'] ?? 'Unknown Account',
                  style: AppTheme.getHeaderStyle(scaleFactor).copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.responsiveSize(AppTheme.fontSizeMedium, scaleFactor),
                    fontWeight: AppTheme.fontWeightMedium,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
            
            // Branch Information (full row)
            _buildInfoItem(
              'Branch',
              bid['branch'] ?? 'Unknown Branch',
              Icons.location_on,
              AppTheme.textMuted,
              scaleFactor,
            ),
            SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
            
            // Price information
            Row(
              children: [
                Expanded(
                  child: _buildPriceInfo(
                    'Reserved Price',
                    'RM ${reservedPrice.toStringAsFixed(2)}',
                    Icons.price_check,
                    AppTheme.textMuted,
                    scaleFactor,
                  ),
                ),
                SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),
                Expanded(
                  child: _buildPriceInfo(
                    'Your Bid',
                    'RM ${bidPrice.toStringAsFixed(2)}',
                    Icons.attach_money,
                    AppTheme.primaryOrange,
                    scaleFactor,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
            
            // Created date
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: AppTheme.responsiveSize(AppTheme.iconTiny, scaleFactor),
                  color: AppTheme.textMuted,
                ),
                SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
                Expanded(
                  child: Text(
                    'Bid placed on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(bid['created_at']).toLocal())}',
                    style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                      color: AppTheme.textMuted,
                      fontSize: AppTheme.responsiveSize(AppTheme.fontSizeTiny, scaleFactor),
                    ),
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
      padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusMedium, scaleFactor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: AppTheme.responsiveSize(AppTheme.iconTiny, scaleFactor),
                color: color,
              ),
              SizedBox(width: AppTheme.responsiveSize(2, scaleFactor)),
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                    color: color,
                    fontWeight: AppTheme.fontWeightSemiBold,
                    fontSize: AppTheme.responsiveSize(AppTheme.fontSizeTiny, scaleFactor),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
          Text(
            value,
            style: AppTheme.getBodyStyle(scaleFactor).copyWith(
              fontWeight: AppTheme.fontWeightBold,
              color: color,
              fontSize: AppTheme.responsiveSize(AppTheme.fontSizeMedium, scaleFactor),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build info items (branch, account, etc.)
  Widget _buildInfoItem(String label, String value, IconData icon, Color color, double scaleFactor) {
    return Container(
      padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusSmall, scaleFactor)),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: AppTheme.responsiveSize(AppTheme.iconTiny, scaleFactor),
                color: color,
              ),
              SizedBox(width: AppTheme.responsiveSize(2, scaleFactor)),
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                    color: color,
                    fontWeight: AppTheme.fontWeightSemiBold,
                    fontSize: AppTheme.responsiveSize(AppTheme.fontSizeTiny, scaleFactor),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.responsiveSize(2, scaleFactor)),
          Text(
            value,
            style: AppTheme.getBodyStyle(scaleFactor).copyWith(
              color: AppTheme.textPrimary,
              fontWeight: AppTheme.fontWeightMedium,
              fontSize: AppTheme.responsiveSize(AppTheme.fontSizeSmall, scaleFactor),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Helper method to extract branch code from branch title
  String _extractBranchCode(String branchTitle) {
    if (branchTitle.isEmpty) return '';
    
    // Common patterns for branch codes
    List<String> words = branchTitle.split(' ');
    if (words.length >= 2) {
      // Take first letter of each word (e.g., "JALAN MELAKA" -> "JM")
      return words.map((word) => word.isNotEmpty ? word[0] : '').join('');
    }
    
    // If single word, take first 4 characters
    if (branchTitle.length >= 4) {
      return branchTitle.substring(0, 4).toUpperCase();
    }
    
    return branchTitle.toUpperCase();
  }
}

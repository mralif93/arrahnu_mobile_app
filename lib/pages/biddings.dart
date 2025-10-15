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
  late var filteredBiddingsData = [];
  bool isLoading = true;
  
  // Filter variables
  String? selectedYear;
  String? selectedMonth;
  List<String> availableYears = [];
  List<String> availableMonths = [];
  Map<String, String> monthNames = {
    '01': 'January', '02': 'February', '03': 'March', '04': 'April',
    '05': 'May', '06': 'June', '07': 'July', '08': 'August',
    '09': 'September', '10': 'October', '11': 'November', '12': 'December'
  };

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
      filteredBiddingsData = List.from(jsonData1);
      _extractAvailableDates();
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
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: Icon(
              Icons.filter_list,
              color: AppTheme.textWhite,
              size: AppTheme.responsiveSize(AppTheme.iconXXLarge, scaleFactor),
            ),
            tooltip: 'Filter by Date',
          ),
        ],
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
    // Check if it's a filter result or truly no biddings
    bool isFilteredEmpty = biddingsData.isNotEmpty && filteredBiddingsData.isEmpty;
    
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
                isFilteredEmpty ? Icons.search_off : Icons.gavel_outlined,
                size: AppTheme.responsiveSize(AppTheme.iconXXXLarge, scaleFactor),
                color: AppTheme.textMuted,
              ),
            ),
            SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXLarge, scaleFactor)),
            Text(
              isFilteredEmpty ? 'No Results Found' : 'No Biddings Yet',
              style: AppTheme.getTitleStyle(scaleFactor).copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
            Text(
              isFilteredEmpty 
                ? 'No biddings found for the selected filter.\nTry adjusting your search criteria.'
                : 'You haven\'t placed any bids yet.\nStart bidding to see them here.',
              textAlign: TextAlign.center,
              style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXLarge, scaleFactor)),
            if (isFilteredEmpty)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedYear = null;
                    selectedMonth = null;
                    _applyFilters();
                  });
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
                  'Clear Filters',
                  style: AppTheme.getButtonTextStyle(scaleFactor),
                ),
              )
            else
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
      child: Column(
        children: [
          // Filter status bar
          if (selectedYear != null || selectedMonth != null)
            _buildFilterStatusBar(scaleFactor),
          
          // Biddings list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),
              itemCount: filteredBiddingsData.length,
              itemBuilder: (context, index) {
                final bid = filteredBiddingsData[index];
                return _buildBiddingCard(bid, scaleFactor, index);
              },
            ),
          ),
        ],
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
                Expanded(
                  child: Text(
                    bid['account_number'] ?? 'Unknown Account',
                    style: AppTheme.getHeaderStyle(scaleFactor).copyWith(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.responsiveSize(AppTheme.fontSizeMedium, scaleFactor),
                      fontWeight: AppTheme.fontWeightMedium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
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
        mainAxisSize: MainAxisSize.min,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              fontSize: AppTheme.responsiveSize(AppTheme.fontSizeSmall, scaleFactor),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

  // Extract available dates from biddings data
  void _extractAvailableDates() {
    Set<String> years = {};
    Set<String> months = {};
    
    for (var bid in biddingsData) {
      try {
        DateTime bidDate = DateTime.parse(bid['created_at']).toLocal();
        String year = bidDate.year.toString();
        String month = bidDate.month.toString().padLeft(2, '0');
        
        years.add(year);
        months.add(month);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
    
    availableYears = years.toList()..sort((a, b) => b.compareTo(a)); // Sort descending
    availableMonths = months.toList()..sort();
  }

  // Apply filters to biddings data
  void _applyFilters() {
    filteredBiddingsData = biddingsData.where((bid) {
      try {
        DateTime bidDate = DateTime.parse(bid['created_at']).toLocal();
        String bidYear = bidDate.year.toString();
        String bidMonth = bidDate.month.toString().padLeft(2, '0');
        
        bool yearMatch = selectedYear == null || bidYear == selectedYear;
        bool monthMatch = selectedMonth == null || bidMonth == selectedMonth;
        
        return yearMatch && monthMatch;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Show filter dialog
  void _showFilterDialog() {
    final scaleFactor = AppTheme.getScaleFactor(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: AppTheme.primaryOrange,
                    size: AppTheme.responsiveSize(AppTheme.iconLarge, scaleFactor),
                  ),
                  SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                  Text(
                    'Filter Biddings',
                    style: AppTheme.getHeaderStyle(scaleFactor),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Year filter
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor),
                      vertical: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusMedium, scaleFactor)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedYear,
                        hint: Text(
                          'Select Year',
                          style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        isExpanded: true,
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'All Years',
                              style: AppTheme.getBodyStyle(scaleFactor),
                            ),
                          ),
                          ...availableYears.map((year) => DropdownMenuItem<String>(
                            value: year,
                            child: Text(
                              year,
                              style: AppTheme.getBodyStyle(scaleFactor),
                            ),
                          )),
                        ],
                        onChanged: (String? newValue) {
                          setDialogState(() {
                            selectedYear = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                  
                  // Month filter
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor),
                      vertical: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusMedium, scaleFactor)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMonth,
                        hint: Text(
                          'Select Month',
                          style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        isExpanded: true,
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'All Months',
                              style: AppTheme.getBodyStyle(scaleFactor),
                            ),
                          ),
                          ...availableMonths.map((month) => DropdownMenuItem<String>(
                            value: month,
                            child: Text(
                              monthNames[month] ?? month,
                              style: AppTheme.getBodyStyle(scaleFactor),
                            ),
                          )),
                        ],
                        onChanged: (String? newValue) {
                          setDialogState(() {
                            selectedMonth = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      selectedYear = null;
                      selectedMonth = null;
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _applyFilters();
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: AppTheme.textWhite,
                  ),
                  child: Text('Apply Filter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Build filter status bar
  Widget _buildFilterStatusBar(double scaleFactor) {
    return Container(
      margin: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
      padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusMedium, scaleFactor)),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            color: AppTheme.primaryOrange,
            size: AppTheme.responsiveSize(AppTheme.iconMedium, scaleFactor),
          ),
          SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
          Expanded(
            child: Text(
              _getFilterStatusText(),
              style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                color: AppTheme.primaryOrange,
                fontWeight: AppTheme.fontWeightMedium,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedYear = null;
                selectedMonth = null;
                _applyFilters();
              });
            },
            child: Icon(
              Icons.close,
              color: AppTheme.primaryOrange,
              size: AppTheme.responsiveSize(AppTheme.iconMedium, scaleFactor),
            ),
          ),
        ],
      ),
    );
  }

  // Get filter status text
  String _getFilterStatusText() {
    if (selectedYear != null && selectedMonth != null) {
      return 'Showing biddings for ${monthNames[selectedMonth]} ${selectedYear} (${filteredBiddingsData.length} results)';
    } else if (selectedYear != null) {
      return 'Showing biddings for ${selectedYear} (${filteredBiddingsData.length} results)';
    } else if (selectedMonth != null) {
      return 'Showing biddings for ${monthNames[selectedMonth]} (${filteredBiddingsData.length} results)';
    }
    return 'Showing all biddings (${filteredBiddingsData.length} results)';
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/variables.dart';
import '../theme/app_theme.dart';
import '../controllers/authorization.dart';
import 'collateral_details_page.dart';
import 'biddings.dart';
import '../services/session_service.dart';

class CollateralSelectionPage extends StatefulWidget {
  final String selectedBranch;
  final String selectedAccount;

  const CollateralSelectionPage({
    Key? key,
    required this.selectedBranch,
    required this.selectedAccount,
  }) : super(key: key);

  @override
  State<CollateralSelectionPage> createState() => _CollateralSelectionPageState();
}

class _CollateralSelectionPageState extends State<CollateralSelectionPage> {
  List<dynamic> collections = [];
  String? accountImageUrl;
  bool isLoading = true;
  bool isLoggedIn = false;
  final SessionService _sessionService = SessionService();
  bool _isSessionActive = false;
  
  // Bidding form variables
  final _formKey = GlobalKey<FormState>();
  final _bidController = TextEditingController();
  bool _isSubmitting = false;
  int _currentBidCount = 0;
  int _maxBidsPerAccount = 3;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
    _checkSessionAndFetch();
  }

  Future<void> _checkSessionAndFetch() async {
    // Check if session is active
    final isSessionActive = await _sessionService.refreshSessionStatus();
    setState(() {
      _isSessionActive = isSessionActive;
    });

    if (isSessionActive) {
      await _fetchCollections();
      await _checkBidCount();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Check current bid count for this account
  Future<void> _checkBidCount() async {
    try {
      final authController = AuthController();
      final response = await authController.getBidCountForUserAccount(widget.selectedAccount);
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _currentBidCount = response.data!;
        });
      }
    } catch (e) {
      print('Error checking bid count: $e');
    }
  }

  // Check if user is logged in
  Future<void> _checkAuthenticationStatus() async {
    try {
      final authController = AuthController();
      final sessionResult = await authController.session();
      setState(() {
        isLoggedIn = sessionResult;
      });
    } catch (e) {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  // Submit bidding price for all items in the account
  Future<void> _submitBid() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if user has reached the bid limit for this account
    if (_currentBidCount >= _maxBidsPerAccount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have reached the maximum limit of $_maxBidsPerAccount bids for this account'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final bidAmount = double.parse(_bidController.text);
      final authController = AuthController();
      
      // Get all items for this account
      final accountItems = collections.where((item) {
        return item['page']?['branch']?['title'] == widget.selectedBranch &&
               item['page']?['acc_num'] == widget.selectedAccount;
      }).toList();

      bool allSuccess = true;
      for (var item in accountItems) {
        final productId = item['page']?['id'] as int?;
        final originalPrice = _parseToDouble(item['priceAfterDiscount']) ?? 0.0;
        
        if (productId != null) {
          final result = await authController.submitUserBid(
            productId,
            originalPrice,
            bidAmount,
          );
          
          if (!result.isSuccess) {
            allSuccess = false;
          }
        }
      }

      if (allSuccess) {
        // Update bid count after successful submission
        setState(() {
          _currentBidCount++;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bid submitted successfully! Remaining bids: ${_maxBidsPerAccount - _currentBidCount}'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        _bidController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Some bids failed to submit'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting bid: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<void> _fetchCollections() async {
    try {
      final response = await http.get(
        Uri.parse('${Variables.baseUrl}/api/collateral/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Extract account image from the first matching item
        String? imageUrl;
        for (var item in data) {
          final branch = item['page']?['branch']?['title'] as String?;
          final account = item['page']?['acc_num'] as String?;
          
          if (branch == widget.selectedBranch && account == widget.selectedAccount) {
            final accountImage = item['page']?['account_image'] as Map<String, dynamic>?;
            if (accountImage != null && accountImage['url'] != null) {
              imageUrl = '${Variables.baseUrl}${accountImage['url']}';
              break;
            }
          }
        }
        
        setState(() {
          collections = data;
          accountImageUrl = imageUrl;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    
    // Filter collections for selected branch and account
    final filteredCollaterals = collections.where((item) {
      return item['page']?['branch']?['title'] == widget.selectedBranch &&
             item['page']?['acc_num'] == widget.selectedAccount;
    }).toList();
    
    // Calculate summary statistics
    var totalItems = filteredCollaterals.length;
    var totalValue = 0.0;
    var categories = <String>{};
    
    for (var item in filteredCollaterals) {
      final price = _parseToDouble(item['priceAfterDiscount']) ?? 0.0;
      totalValue += price;
      
      final goldType = item['gold_type']?['title'] as String?;
      if (goldType != null) {
        categories.add(goldType);
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Collateral',
          style: AppTheme.getAppBarTitleStyle(scaleFactor),
        ),
        backgroundColor: AppTheme.primaryOrange,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.textWhite,
            size: AppTheme.responsiveSize(AppTheme.iconXLarge, scaleFactor),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BiddingPage(),
                ),
              );
            },
            icon: Icon(
              Icons.history,
              color: AppTheme.textWhite,
              size: AppTheme.responsiveSize(AppTheme.iconXLarge, scaleFactor),
            ),
            tooltip: 'View My Biddings',
          ),
        ],
      ),
      body: !_isSessionActive
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 80 * scaleFactor,
                    color: Colors.red[400],
                  ),
                  SizedBox(height: 24 * scaleFactor),
                  Text(
                    'Session Ended',
                    style: TextStyle(
                      fontSize: 24 * scaleFactor,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  SizedBox(height: 12 * scaleFactor),
                  Text(
                    'Browsing is not available.\nThe bidding session has ended.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16 * scaleFactor,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 32 * scaleFactor),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32 * scaleFactor,
                        vertical: 12 * scaleFactor,
                      ),
                    ),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            )
          : isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16 * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      margin: EdgeInsets.only(bottom: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),
                      padding: AppTheme.getCardPadding(scaleFactor),
                      decoration: AppTheme.getCardDecoration(scaleFactor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: AppTheme.getIconCirclePadding(scaleFactor),
                                decoration: AppTheme.getIconCircleDecoration(AppTheme.secondaryBlue, scaleFactor),
                                child: Icon(
                                  Icons.location_on,
                                  color: AppTheme.secondaryBlue,
                                  size: AppTheme.responsiveSize(AppTheme.iconMedium, scaleFactor),
                                ),
                              ),
                              SizedBox(width: AppTheme.spacingMedium),
                              Expanded(
                                child: Text(
                                  widget.selectedBranch,
                                  style: AppTheme.getBodyStyle(scaleFactor),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                          Row(
                            children: [
                              Container(
                                padding: AppTheme.getIconCirclePadding(scaleFactor),
                                decoration: AppTheme.getIconCircleDecoration(AppTheme.secondaryGreen, scaleFactor),
                                child: Icon(
                                  Icons.account_balance,
                                  color: AppTheme.secondaryGreen,
                                  size: AppTheme.responsiveSize(AppTheme.iconMedium, scaleFactor),
                                ),
                              ),
                              SizedBox(width: AppTheme.spacingMedium),
                              Expanded(
                                child: Text(
                                  widget.selectedAccount,
                                  style: AppTheme.getBodyStyle(scaleFactor),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16 * scaleFactor),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Items',
                                  totalItems.toString(),
                                  Icons.inventory_2,
                                  Colors.orange,
                                  scaleFactor,
                                ),
                              ),
                              SizedBox(width: 12 * scaleFactor),
                              Expanded(
                                child: _buildStatCard(
                                  'Value',
                                  'RM${totalValue.toStringAsFixed(0)}',
                                  Icons.attach_money,
                                  Colors.green,
                                  scaleFactor,
                                ),
                              ),
                              SizedBox(width: 12 * scaleFactor),
                              Expanded(
                                child: _buildStatCard(
                                  'Types',
                                  categories.length.toString(),
                                  Icons.category,
                                  Colors.purple,
                                  scaleFactor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bidding Card (only show if user is logged in)
                    if (isLoggedIn) Container(
                      margin: EdgeInsets.only(bottom: 16 * scaleFactor),
                      padding: EdgeInsets.all(16 * scaleFactor),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12 * scaleFactor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.gavel,
                                  color: Colors.orange,
                                  size: 20 * scaleFactor,
                                ),
                                SizedBox(width: 8 * scaleFactor),
                            Text(
                              'Place Bid for All Items in Account',
                              style: TextStyle(
                                fontSize: 12 * scaleFactor,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                              ],
                            ),
                            SizedBox(height: 8 * scaleFactor),
                            Text(
                              'This will place the same bid amount for all $totalItems items in this account. Bid must be greater than the item value.',
                              style: TextStyle(
                                fontSize: 10 * scaleFactor,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 12 * scaleFactor),
                            TextFormField(
                              controller: _bidController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: 12 * scaleFactor,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Bid Amount (RM)',
                                labelStyle: TextStyle(
                                  fontSize: 11 * scaleFactor,
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 11 * scaleFactor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6 * scaleFactor),
                                ),
                                prefixIcon: Icon(
                                  Icons.attach_money,
                                  size: 16 * scaleFactor,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12 * scaleFactor,
                                  vertical: 8 * scaleFactor,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter bid amount';
                                }
                                final amount = double.tryParse(value);
                                if (amount == null || amount <= 0) {
                                  return 'Please enter valid amount';
                                }
                                
                                // Check if bid amount is greater than the minimum value
                                double minValue = 0.0;
                                for (var item in filteredCollaterals) {
                                  final itemValue = _parseToDouble(item['priceAfterDiscount']) ?? 0.0;
                                  if (itemValue > minValue) {
                                    minValue = itemValue;
                                  }
                                }
                                
                                if (amount <= minValue) {
                                  return 'Bid must be greater than RM${minValue.toStringAsFixed(0)}';
                                }
                                
                                return null;
                              },
                            ),
                            SizedBox(height: 8 * scaleFactor),
                            // Show minimum bid amount
                            Builder(
                              builder: (context) {
                                double minValue = 0.0;
                                for (var item in filteredCollaterals) {
                                  final itemValue = _parseToDouble(item['priceAfterDiscount']) ?? 0.0;
                                  if (itemValue > minValue) {
                                    minValue = itemValue;
                                  }
                                }
                                return Text(
                                  'Minimum bid: RM${minValue.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 9 * scaleFactor,
                                    color: Colors.orange[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 8 * scaleFactor),
                            // Bid count display
                            Container(
                              padding: EdgeInsets.all(8 * scaleFactor),
                              decoration: BoxDecoration(
                                color: _currentBidCount >= _maxBidsPerAccount 
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6 * scaleFactor),
                                border: Border.all(
                                  color: _currentBidCount >= _maxBidsPerAccount 
                                      ? Colors.red.withOpacity(0.3)
                                      : Colors.blue.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _currentBidCount >= _maxBidsPerAccount 
                                        ? Icons.block
                                        : Icons.info_outline,
                                    size: 16 * scaleFactor,
                                    color: _currentBidCount >= _maxBidsPerAccount 
                                        ? Colors.red[600]
                                        : Colors.blue[600],
                                  ),
                                  SizedBox(width: 8 * scaleFactor),
                                  Expanded(
                                    child: Text(
                                      _currentBidCount >= _maxBidsPerAccount
                                          ? 'Bid limit reached ($_currentBidCount/$_maxBidsPerAccount)'
                                          : 'Bids used: $_currentBidCount/$_maxBidsPerAccount (${_maxBidsPerAccount - _currentBidCount} remaining)',
                                      style: TextStyle(
                                        fontSize: 10 * scaleFactor,
                                        color: _currentBidCount >= _maxBidsPerAccount 
                                            ? Colors.red[600]
                                            : Colors.blue[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12 * scaleFactor),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: (_isSubmitting || _currentBidCount >= _maxBidsPerAccount) ? null : _submitBid,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6 * scaleFactor),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? SizedBox(
                                            height: 16 * scaleFactor,
                                            width: 16 * scaleFactor,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Text(
                                            'Submit Bid',
                                            style: TextStyle(
                                              fontSize: 11 * scaleFactor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(width: 12 * scaleFactor),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      _bidController.clear();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6 * scaleFactor),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 11 * scaleFactor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Account Image Card
                    if (accountImageUrl != null)
                      Container(
                        margin: EdgeInsets.only(bottom: 16 * scaleFactor),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12 * scaleFactor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12 * scaleFactor),
                          child: Image.network(
                            accountImageUrl!,
                            width: double.infinity,
                            height: 200 * scaleFactor,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200 * scaleFactor,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200 * scaleFactor,
                                color: Colors.grey[200],
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 48 * scaleFactor,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 8 * scaleFactor),
                                      Text(
                                        'Image not available',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12 * scaleFactor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    // Items List
                    if (filteredCollaterals.isEmpty)
                      Container(
                        padding: EdgeInsets.all(32 * scaleFactor),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 48 * scaleFactor,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16 * scaleFactor),
                            Text(
                              'No items found',
                              style: TextStyle(
                                fontSize: 16 * scaleFactor,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8 * scaleFactor),
                            Text(
                              'Branch: ${widget.selectedBranch}',
                              style: TextStyle(
                                fontSize: 12 * scaleFactor,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              'Account: ${widget.selectedAccount}',
                              style: TextStyle(
                                fontSize: 12 * scaleFactor,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: filteredCollaterals.length,
                        itemBuilder: (context, index) {
                          final item = filteredCollaterals[index];
                          return _buildItemCard(item, scaleFactor);
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, double scaleFactor) {
    return Container(
      padding: EdgeInsets.all(12 * scaleFactor),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8 * scaleFactor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16 * scaleFactor),
          SizedBox(height: 4 * scaleFactor),
          Text(
            value,
            style: TextStyle(
              fontSize: 12 * scaleFactor,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10 * scaleFactor,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, double scaleFactor) {
    final goldType = item['gold_type']?['title'] as String? ?? 'Unknown';
    final goldStandard = item['gold_standard']?['title'] as String? ?? 'Unknown';
    final goldWeight = item['gold_weight'] as String? ?? '0';
    final priceAfterDiscount = _parseToDouble(item['priceAfterDiscount']) ?? 0.0;
    final discount = _parseToDouble(item['discount']) ?? 0.0;
    final fullPrice = _parseToDouble(item['fullPrice']) ?? priceAfterDiscount + discount;

    return Container(
      margin: EdgeInsets.only(bottom: 12 * scaleFactor),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scaleFactor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CollateralDetailsPage(
                collateralItem: item,
                selectedBranch: widget.selectedBranch,
                selectedAccount: widget.selectedAccount,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12 * scaleFactor),
        child: Padding(
          padding: EdgeInsets.all(16 * scaleFactor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8 * scaleFactor),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8 * scaleFactor),
                    ),
                    child: Icon(
                      Icons.diamond,
                      color: Colors.orange,
                      size: 20 * scaleFactor,
                    ),
                  ),
                  SizedBox(width: 12 * scaleFactor),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goldType,
                          style: TextStyle(
                            fontSize: 14 * scaleFactor,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 4 * scaleFactor),
                        Text(
                          '$goldStandard • ${goldWeight}g',
                          style: TextStyle(
                            fontSize: 12 * scaleFactor,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16 * scaleFactor),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Before',
                          style: TextStyle(
                            fontSize: 10 * scaleFactor,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 4 * scaleFactor),
                        Text(
                          'RM${fullPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12 * scaleFactor,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30 * scaleFactor,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Discount',
                          style: TextStyle(
                            fontSize: 10 * scaleFactor,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 4 * scaleFactor),
                        Text(
                          'RM${discount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12 * scaleFactor,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30 * scaleFactor,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'After',
                          style: TextStyle(
                            fontSize: 10 * scaleFactor,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 4 * scaleFactor),
                        Text(
                          'RM${priceAfterDiscount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12 * scaleFactor,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[600],
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
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'collateral_selection_page.dart';
import '../constant/variables.dart';
import '../controllers/authorization.dart';

class AccountSelectionPage extends StatefulWidget {
  final String selectedBranch;
  final Map<String, Set<String>> branchData;

  const AccountSelectionPage({
    Key? key,
    required this.selectedBranch,
    required this.branchData,
  }) : super(key: key);

  @override
  State<AccountSelectionPage> createState() => _AccountSelectionPageState();
}

class _AccountSelectionPageState extends State<AccountSelectionPage> {
  Map<String, int> accountCollateralCounts = {};
  Map<String, String> accountImages = {};
  List<dynamic> allCollateralData = [];
  bool isLoading = true;
  
  // Bidding form variables
  final _formKey = GlobalKey<FormState>();
  final _bidController = TextEditingController();
  bool _isSubmitting = false;
  String? _selectedAccount;

  @override
  void initState() {
    super.initState();
    _fetchCollateralData();
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  // Submit bidding price for all items in an account
  Future<void> _submitBid(String accountNumber) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final bidPrice = double.parse(_bidController.text);
      final authController = AuthController();
      
      // Get all collateral items for this account
      final accountItems = _getAccountItems(accountNumber);
      
      if (accountItems.isEmpty) {
        throw Exception('No items found for this account');
      }

      int successCount = 0;
      int totalItems = accountItems.length;

      // Submit bid for each item in the account
      for (var item in accountItems) {
        final productId = item['page']?['id'] as int?;
        if (productId == null) continue;

        final originalPrice = _parseToDouble(item['fullPrice']) ?? 0.0;
        
        final response = await authController.submitUserBid(
          productId, 
          originalPrice, 
          bidPrice
        );

        if (response.isSuccess) {
          successCount++;
        }
      }

      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bid submitted for $successCount out of $totalItems items!'),
            backgroundColor: Colors.green,
          ),
        );
        _bidController.clear();
        setState(() {
          _selectedAccount = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit bids for any items'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Get all collateral items for a specific account
  List<dynamic> _getAccountItems(String accountNumber) {
    return allCollateralData.where((item) {
      final branch = item['page']?['branch']?['title'] as String?;
      final account = item['page']?['acc_num'] as String?;
      return branch == widget.selectedBranch && account == accountNumber;
    }).toList();
  }

  // Helper method to safely parse values to double
  double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Future<void> _fetchCollateralData() async {
    try {
      final response = await http.get(
        Uri.parse('${Variables.baseUrl}/api/collateral/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Store all collateral data
        allCollateralData = data;
        
        // Count collateral items per account and collect account images
        Map<String, int> counts = {};
        Map<String, String> images = {};
        
        for (var item in data) {
          final branch = item['page']?['branch']?['title'] as String?;
          final account = item['page']?['acc_num'] as String?;
          final accountImage = item['page']?['account_image'];
          
          if (branch == widget.selectedBranch && account != null) {
            counts[account] = (counts[account] ?? 0) + 1;
            
            // Extract account image URL
            if (accountImage != null && accountImage['url'] != null) {
              final imageUrl = accountImage['url'] as String;
              images[account] = imageUrl;
            }
          }
        }
        
        setState(() {
          accountCollateralCounts = counts;
          accountImages = images;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching collateral data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = (screenWidth / 375).clamp(0.8, 1.2);

    final accounts = widget.branchData[widget.selectedBranch]?.toList() ?? [];
    accounts.sort((a, b) => a.compareTo(b));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Account',
          style: TextStyle(
            fontSize: 18 * scaleFactor,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFE8000),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24 * scaleFactor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: const Color(0xFFFE8000),
                  ),
                  SizedBox(height: 16 * scaleFactor),
                  Text(
                    'Loading accounts...',
                    style: TextStyle(
                      fontSize: 16 * scaleFactor,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : accounts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 64 * scaleFactor,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16 * scaleFactor),
                      Text(
                        'No accounts available',
                        style: TextStyle(
                          fontSize: 16 * scaleFactor,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8 * scaleFactor),
                      Text(
                        'This branch has no accounts',
                        style: TextStyle(
                          fontSize: 12 * scaleFactor,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
          : Padding(
              padding: EdgeInsets.all(16 * scaleFactor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clean Header
                  Container(
                    padding: EdgeInsets.all(16 * scaleFactor),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12 * scaleFactor),
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
                          padding: EdgeInsets.all(6 * scaleFactor),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFE8000).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: 14 * scaleFactor,
                            color: const Color(0xFFFE8000),
                          ),
                        ),
                        SizedBox(width: 12 * scaleFactor),
                        Expanded(
                          child: Text(
                            widget.selectedBranch,
                            style: TextStyle(
                              fontSize: 12 * scaleFactor,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor, vertical: 4 * scaleFactor),
                          decoration: BoxDecoration(
                            color: Colors.blue[600]!.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8 * scaleFactor),
                          ),
                          child: Text(
                            '${accounts.length} accounts',
                            style: TextStyle(
                              fontSize: 10 * scaleFactor,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20 * scaleFactor),
                  
                  // Accounts List
                  Expanded(
                    child: ListView.builder(
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        final accountNumber = accounts[index];
                        
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          margin: EdgeInsets.only(bottom: 12 * scaleFactor),
                          child: Column(
                            children: [
                              // Account Card
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(
                                      CollateralSelectionPage(
                                        selectedBranch: widget.selectedBranch,
                                        selectedAccount: accountNumber,
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16 * scaleFactor),
                                  child: Container(
                                    padding: EdgeInsets.all(12 * scaleFactor),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12 * scaleFactor),
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
                                        // Account Image or Icon
                                        Container(
                                          width: 40 * scaleFactor,
                                          height: 40 * scaleFactor,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8 * scaleFactor),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: accountImages[accountNumber] != null
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(8 * scaleFactor),
                                                  child: Image.network(
                                                    '${Variables.baseUrl}${accountImages[accountNumber]}',
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return Container(
                                                        color: Colors.grey[200],
                                                        child: Center(
                                                          child: SizedBox(
                                                            width: 16 * scaleFactor,
                                                            height: 16 * scaleFactor,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: const Color(0xFFFE8000),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        color: Colors.blue[600]!.withOpacity(0.1),
                                                        child: Icon(
                                                          Icons.account_balance_wallet,
                                                          color: Colors.blue[600],
                                                          size: 18 * scaleFactor,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Container(
                                                  color: Colors.blue[600]!.withOpacity(0.1),
                                                  child: Icon(
                                                    Icons.account_balance_wallet,
                                                    color: Colors.blue[600],
                                                    size: 18 * scaleFactor,
                                                  ),
                                                ),
                                        ),
                                        SizedBox(width: 12 * scaleFactor),
                                        Expanded(
                                          child: Text(
                                            accountNumber,
                                            style: TextStyle(
                                              fontSize: 12 * scaleFactor,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor, vertical: 4 * scaleFactor),
                                          decoration: BoxDecoration(
                                            color: Colors.green[600]!.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8 * scaleFactor),
                                          ),
                                          child: Text(
                                            '${accountCollateralCounts[accountNumber] ?? 0}',
                                            style: TextStyle(
                                              fontSize: 10 * scaleFactor,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green[600],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8 * scaleFactor),
                                        // Place Bid Button
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _selectedAccount = _selectedAccount == accountNumber ? null : accountNumber;
                                            });
                                            if (_selectedAccount == accountNumber) {
                                              _bidController.clear();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFFE8000),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12 * scaleFactor,
                                              vertical: 6 * scaleFactor,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6 * scaleFactor),
                                            ),
                                            elevation: 1,
                                          ),
                                          child: Text(
                                            'Place Bid',
                                            style: TextStyle(
                                              fontSize: 10 * scaleFactor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Bidding Form (shown when account is selected)
                              if (_selectedAccount == accountNumber) ...[
                                SizedBox(height: 8 * scaleFactor),
                                Container(
                                  padding: EdgeInsets.all(16 * scaleFactor),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12 * scaleFactor),
                                    border: Border.all(color: Colors.grey[200]!),
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
                                              color: const Color(0xFFFE8000),
                                              size: 16 * scaleFactor,
                                            ),
                                            SizedBox(width: 6 * scaleFactor),
                                            Text(
                                              'Place Bid for All Items in Account',
                                              style: TextStyle(
                                                fontSize: 14 * scaleFactor,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8 * scaleFactor),
                                        Text(
                                          'This will place the same bid amount for all ${accountCollateralCounts[accountNumber] ?? 0} items in this account.',
                                          style: TextStyle(
                                            fontSize: 10 * scaleFactor,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 12 * scaleFactor),
                                        
                                        TextFormField(
                                          controller: _bidController,
                                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                                          style: TextStyle(
                                            fontSize: 12 * scaleFactor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                          cursorColor: const Color(0xFFFE8000),
                                          decoration: InputDecoration(
                                            hintText: 'Enter your bid amount (RM)',
                                            hintStyle: TextStyle(
                                              fontSize: 10 * scaleFactor,
                                              color: Colors.grey[500],
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(6 * scaleFactor),
                                              borderSide: BorderSide(color: Colors.grey[300]!),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(6 * scaleFactor),
                                              borderSide: BorderSide(color: const Color(0xFFFE8000), width: 2),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12 * scaleFactor,
                                              vertical: 8 * scaleFactor,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter a bid amount';
                                            }
                                            
                                            final bidAmount = double.tryParse(value);
                                            if (bidAmount == null) {
                                              return 'Please enter a valid number';
                                            }
                                            
                                            if (bidAmount <= 0) {
                                              return 'Bid amount must be greater than 0';
                                            }
                                            
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 12 * scaleFactor),
                                        
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: _isSubmitting ? null : () => _submitBid(accountNumber),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFFFE8000),
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(6 * scaleFactor),
                                                  ),
                                                  elevation: 1,
                                                ),
                                                child: _isSubmitting
                                                    ? Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          SizedBox(
                                                            width: 12 * scaleFactor,
                                                            height: 12 * scaleFactor,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 1.5,
                                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                            ),
                                                          ),
                                                          SizedBox(width: 6 * scaleFactor),
                                                          Text(
                                                            'Submitting...',
                                                            style: TextStyle(
                                                              fontSize: 10 * scaleFactor,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Text(
                                                        'Submit Bid',
                                                        style: TextStyle(
                                                          fontSize: 10 * scaleFactor,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            SizedBox(width: 8 * scaleFactor),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _selectedAccount = null;
                                                });
                                                _bidController.clear();
                                              },
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  fontSize: 10 * scaleFactor,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
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
}

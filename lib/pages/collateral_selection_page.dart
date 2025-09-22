import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/variables.dart';
import '../theme/app_theme.dart';
import '../controllers/authorization.dart';
import 'collateral_details_page.dart';
import 'biddings.dart';
import '../services/session_service.dart';
import '../components/QButton.dart';
import '../components/QTextField.dart';
import '../components/QOutlinedButton.dart';

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

class _CollateralSelectionPageState extends State<CollateralSelectionPage> with WidgetsBindingObserver {
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
  
  // Bidding history tracking
  List<Map<String, dynamic>> _accountBiddingHistory = [];
  bool _hasBiddingHistory = false;
  List<int> _accountProductIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthenticationStatus();
    _checkSessionAndFetch();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh bid count when app becomes active
      _checkBidCount();
    }
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


  // Check current bid count from bidding history for specific account using account identification
  Future<void> _checkBidCount() async {
    try {
      final authController = AuthController();
      
      // Get all user bids
      final userBiddingsResponse = await authController.getUserBidding();
      
      if (!userBiddingsResponse.isSuccess || userBiddingsResponse.data == null) {
        setState(() {
          _currentBidCount = 0;
        });
        return;
      }
      
      // Get collateral data to match product IDs to account numbers
      final collateralResponse = await authController.getCollateralData();
      
      if (!collateralResponse.isSuccess || collateralResponse.data == null) {
        setState(() {
          _currentBidCount = 0;
        });
        return;
      }
      
      // Create mapping of product ID to account number
      final Map<int, String> productToAccount = {};
      for (var item in collateralResponse.data!) {
        final productId = item['page']?['id'];
        final accountNum = item['page']?['acc_num'];
        if (accountNum != null && productId != null) {
          productToAccount[productId] = accountNum;
        }
      }
      
      // Count bids for this specific account using account identification
      int accountBidCount = 0;
      List<Map<String, dynamic>> accountBids = [];
      
      for (var bid in userBiddingsResponse.data!) {
        final productId = bid['product'] as int?;
        if (productId != null && productToAccount.containsKey(productId)) {
          final mappedAccount = productToAccount[productId];
          if (mappedAccount == widget.selectedAccount) {
            accountBidCount++;
            accountBids.add(bid);
          }
        }
      }
      
      setState(() {
        _currentBidCount = accountBidCount;
      });
      
    } catch (e) {
      setState(() {
        _currentBidCount = 0;
      });
    }
  }

  // Check if bid history can identify which accounts exist from the fetched list
  Future<void> _checkBidHistoryAccountIdentification() async {
    try {
      print('=== CHECKING BID HISTORY ACCOUNT IDENTIFICATION ===');
      
      final authController = AuthController();
      
      // Get all user bids
      final userBiddingsResponse = await authController.getUserBidding();
      if (!userBiddingsResponse.isSuccess || userBiddingsResponse.data == null) {
        print('❌ Failed to get user biddings');
        return;
      }
      
      // Get collateral data (all available accounts)
      final collateralResponse = await authController.getCollateralData();
      if (!collateralResponse.isSuccess || collateralResponse.data == null) {
        print('❌ Failed to get collateral data');
        return;
      }
      
      // Extract all available accounts from collateral data
      Set<String> allAvailableAccounts = {};
      Map<int, String> productToAccountMap = {};
      
      for (var item in collateralResponse.data!) {
        if (item['page']?['acc_num'] != null && item['id'] != null) {
          final accountNum = item['page']['acc_num'] as String;
          final productId = item['id'] as int;
          allAvailableAccounts.add(accountNum);
          productToAccountMap[productId] = accountNum;
        }
      }
      
      print('📋 ALL AVAILABLE ACCOUNTS FROM COLLATERAL DATA:');
      print('   Total Accounts: ${allAvailableAccounts.length}');
      for (String account in allAvailableAccounts) {
        print('   - $account');
      }
      print('');
      
      // Extract accounts from bid history
      Set<String> accountsFromBidHistory = {};
      List<Map<String, dynamic>> validBids = [];
      List<Map<String, dynamic>> invalidBids = [];
      
      for (var bid in userBiddingsResponse.data!) {
        final productId = bid['product'] as int?;
        if (productId != null && productToAccountMap.containsKey(productId)) {
          final accountNum = productToAccountMap[productId]!;
          accountsFromBidHistory.add(accountNum);
          validBids.add(bid);
        } else {
          invalidBids.add(bid);
        }
      }
      
      print('🏷️ ACCOUNTS IDENTIFIED FROM BID HISTORY:');
      print('   Total Accounts with Bids: ${accountsFromBidHistory.length}');
      for (String account in accountsFromBidHistory) {
        print('   - $account');
      }
      print('');
      
      // Check identification success
      print('✅ VALID BIDS (Can identify account):');
      print('   Count: ${validBids.length}');
      for (var bid in validBids) {
        final productId = bid['product'];
        final accountNum = productToAccountMap[productId];
        print('   Bid ID: ${bid['id']} → Product: $productId → Account: $accountNum');
      }
      print('');
      
      if (invalidBids.isNotEmpty) {
        print('❌ INVALID BIDS (Cannot identify account):');
        print('   Count: ${invalidBids.length}');
        for (var bid in invalidBids) {
          print('   Bid ID: ${bid['id']} → Product: ${bid['product']} (Product not found in collateral data)');
        }
        print('');
      }
      
      // Find accounts that exist but have no bids
      Set<String> accountsWithNoBids = allAvailableAccounts.difference(accountsFromBidHistory);
      print('📊 ACCOUNTS WITH NO BIDS:');
      print('   Count: ${accountsWithNoBids.length}');
      for (String account in accountsWithNoBids) {
        print('   - $account');
      }
      print('');
      
      // Find accounts that have bids but don't exist in collateral data
      Set<String> accountsFromBidsNotInCollateral = accountsFromBidHistory.difference(allAvailableAccounts);
      if (accountsFromBidsNotInCollateral.isNotEmpty) {
        print('⚠️ ACCOUNTS FROM BIDS NOT IN COLLATERAL DATA:');
        print('   Count: ${accountsFromBidsNotInCollateral.length}');
        for (String account in accountsFromBidsNotInCollateral) {
          print('   - $account');
        }
        print('');
      }
      
      // Summary statistics
      double identificationRate = (validBids.length / userBiddingsResponse.data!.length) * 100;
      double accountCoverage = (accountsFromBidHistory.length / allAvailableAccounts.length) * 100;
      
      print('📈 IDENTIFICATION SUMMARY:');
      print('   Total Bids: ${userBiddingsResponse.data!.length}');
      print('   Successfully Identified: ${validBids.length}');
      print('   Failed to Identify: ${invalidBids.length}');
      print('   Identification Rate: ${identificationRate.toStringAsFixed(1)}%');
      print('   Total Available Accounts: ${allAvailableAccounts.length}');
      print('   Accounts with Bids: ${accountsFromBidHistory.length}');
      print('   Account Coverage: ${accountCoverage.toStringAsFixed(1)}%');
      print('   Accounts with No Bids: ${accountsWithNoBids.length}');
      
      // Final assessment
      print('\n🎯 FINAL ASSESSMENT:');
      if (identificationRate == 100.0) {
        print('   ✅ EXCELLENT: All bids can be identified to accounts');
      } else if (identificationRate >= 90.0) {
        print('   ✅ GOOD: Most bids can be identified to accounts');
      } else if (identificationRate >= 70.0) {
        print('   ⚠️ FAIR: Some bids cannot be identified to accounts');
      } else {
        print('   ❌ POOR: Many bids cannot be identified to accounts');
      }
      
      if (accountCoverage >= 50.0) {
        print('   ✅ GOOD: Bids cover ${accountCoverage.toStringAsFixed(1)}% of available accounts');
      } else {
        print('   ⚠️ LOW: Bids only cover ${accountCoverage.toStringAsFixed(1)}% of available accounts');
      }
      
      print('\n=== END ACCOUNT IDENTIFICATION CHECK ===');
      
    } catch (e) {
      print('❌ Error checking bid history account identification: $e');
    }
  }

  // Identify products in bid history with account listing
  Future<void> _identifyProductsInBidHistory() async {
    try {
      print('=== IDENTIFYING PRODUCTS IN BID HISTORY BY ACCOUNT ===');
      
      final authController = AuthController();
      
      // Get all user bids
      final userBiddingsResponse = await authController.getUserBidding();
      if (!userBiddingsResponse.isSuccess || userBiddingsResponse.data == null) {
        print('Failed to get user biddings');
        return;
      }
      
      // Get collateral data
      final collateralResponse = await authController.getCollateralData();
      if (!collateralResponse.isSuccess || collateralResponse.data == null) {
        print('Failed to get collateral data');
        return;
      }
      
      // Create product details lookup
      Map<int, Map<String, dynamic>> productDetails = {};
      for (var item in collateralResponse.data!) {
        if (item['id'] != null) {
          productDetails[item['id']] = item;
        }
      }
      
      // Group bids by account with product details
      Map<String, List<Map<String, dynamic>>> accountBidsWithProducts = {};
      
      for (var bid in userBiddingsResponse.data!) {
        final productId = bid['product'] as int?;
        if (productId != null && productDetails.containsKey(productId)) {
          final product = productDetails[productId]!;
          final accountNum = product['page']?['acc_num'] as String?;
          
          if (accountNum != null) {
            if (!accountBidsWithProducts.containsKey(accountNum)) {
              accountBidsWithProducts[accountNum] = [];
            }
            
            // Create enhanced bid with product details
            Map<String, dynamic> enhancedBid = Map.from(bid);
            enhancedBid['product_details'] = {
              'id': product['id'],
              'title': product['title'],
              'priceAfterDiscount': product['priceAfterDiscount'],
              'description': product['description'],
              'image': product['image'],
              'category': product['category'],
            };
            
            accountBidsWithProducts[accountNum]!.add(enhancedBid);
          }
        }
      }
      
      // Display results by account
      print('=== BIDDING HISTORY WITH PRODUCT DETAILS BY ACCOUNT ===');
      accountBidsWithProducts.forEach((account, bids) {
        print('\n📋 ACCOUNT: $account');
        print('   Total Bids: ${bids.length}');
        print('   ──────────────────────────────────────────────');
        
        for (int i = 0; i < bids.length; i++) {
          var bid = bids[i];
          var product = bid['product_details'];
          
          print('   🏷️  BID #${i + 1}');
          print('      Bid ID: ${bid['id']}');
          print('      Product ID: ${product['id']}');
          print('      Product Title: ${product['title']}');
          print('      Product Value: RM ${product['priceAfterDiscount']}');
          print('      Bid Amount: RM ${bid['bid_offer']}');
          print('      Bid Date: ${bid['created_at']}');
          print('      Product Description: ${product['description']}');
          print('      Product Category: ${product['category']}');
          print('      ──────────────────────────────────────────');
        }
      });
      
      // Summary by account
      print('\n=== SUMMARY BY ACCOUNT ===');
      accountBidsWithProducts.forEach((account, bids) {
        double totalBidAmount = 0;
        double totalProductValue = 0;
        
        for (var bid in bids) {
          totalBidAmount += (bid['bid_offer'] as num?)?.toDouble() ?? 0;
          totalProductValue += (bid['product_details']['priceAfterDiscount'] as num?)?.toDouble() ?? 0;
        }
        
        print('Account: $account');
        print('  Bids: ${bids.length}');
        print('  Total Bid Amount: RM ${totalBidAmount.toStringAsFixed(2)}');
        print('  Total Product Value: RM ${totalProductValue.toStringAsFixed(2)}');
        print('  Average Bid: RM ${(totalBidAmount / bids.length).toStringAsFixed(2)}');
        print('  Bid/Value Ratio: ${(totalBidAmount / totalProductValue * 100).toStringAsFixed(1)}%');
        print('');
      });
      
      print('=== END PRODUCT IDENTIFICATION ===');
      
    } catch (e) {
      print('Error identifying products in bid history: $e');
    }
  }

  // Comprehensive method to compare and bind accounts with bidding history
  Future<void> _compareAccountsWithBiddingHistory() async {
    try {
      print('=== COMPREHENSIVE ACCOUNT-BIDDING COMPARISON ===');
      
      final authController = AuthController();
      
      // Get all user bids
      final userBiddingsResponse = await authController.getUserBidding();
      if (!userBiddingsResponse.isSuccess || userBiddingsResponse.data == null) {
        print('Failed to get user biddings');
        return;
      }
      
      // Get collateral data
      final collateralResponse = await authController.getCollateralData();
      if (!collateralResponse.isSuccess || collateralResponse.data == null) {
        print('Failed to get collateral data');
        return;
      }
      
      // Method 1: Create complete account-to-bids mapping
      Map<String, List<Map<String, dynamic>>> accountBidsMap = {};
      Map<String, List<int>> accountProductsMap = {};
      Map<int, String> productToAccountMap = {};
      
      // Build mappings
      for (var item in collateralResponse.data!) {
        if (item['page']?['acc_num'] != null && item['id'] != null) {
          final productId = item['id'] as int;
          final accountNum = item['page']['acc_num'] as String;
          
          productToAccountMap[productId] = accountNum;
          
          if (!accountProductsMap.containsKey(accountNum)) {
            accountProductsMap[accountNum] = [];
            accountBidsMap[accountNum] = [];
          }
          accountProductsMap[accountNum]!.add(productId);
        }
      }
      
      // Map bids to accounts
      for (var bid in userBiddingsResponse.data!) {
        final productId = bid['product'] as int?;
        if (productId != null && productToAccountMap.containsKey(productId)) {
          final accountNum = productToAccountMap[productId]!;
          accountBidsMap[accountNum]!.add(bid);
        }
      }
      
      print('=== METHOD 1: ACCOUNT-TO-BIDS MAPPING ===');
      accountBidsMap.forEach((account, bids) {
        print('Account: $account');
        print('  Products: ${accountProductsMap[account]}');
        print('  Bids: ${bids.length}');
        for (var bid in bids) {
          print('    Bid ID: ${bid['id']}, Product: ${bid['product']}, Amount: ${bid['bid_offer']}, Date: ${bid['created_at']}');
        }
        print('');
      });
      
      // Method 2: Create bid-to-account mapping
      Map<int, String> bidToAccountMap = {};
      for (var bid in userBiddingsResponse.data!) {
        final productId = bid['product'] as int?;
        if (productId != null && productToAccountMap.containsKey(productId)) {
          bidToAccountMap[bid['id']] = productToAccountMap[productId]!;
        }
      }
      
      print('=== METHOD 2: BID-TO-ACCOUNT MAPPING ===');
      bidToAccountMap.forEach((bidId, account) {
        print('Bid ID: $bidId → Account: $account');
      });
      print('');
      
      // Method 3: Find accounts with no bids
      List<String> accountsWithNoBids = [];
      accountProductsMap.forEach((account, products) {
        if (!accountBidsMap.containsKey(account) || accountBidsMap[account]!.isEmpty) {
          accountsWithNoBids.add(account);
        }
      });
      
      print('=== METHOD 3: ACCOUNTS WITH NO BIDS ===');
      print('Accounts with no bids: $accountsWithNoBids');
      print('');
      
      // Method 4: Find bids with no matching account
      List<Map<String, dynamic>> bidsWithNoAccount = [];
      for (var bid in userBiddingsResponse.data!) {
        final productId = bid['product'] as int?;
        if (productId == null || !productToAccountMap.containsKey(productId)) {
          bidsWithNoAccount.add(bid);
        }
      }
      
      print('=== METHOD 4: BIDS WITH NO MATCHING ACCOUNT ===');
      print('Bids with no account: ${bidsWithNoAccount.length}');
      for (var bid in bidsWithNoAccount) {
        print('  Bid ID: ${bid['id']}, Product: ${bid['product']}, Amount: ${bid['bid_offer']}');
      }
      print('');
      
      // Method 5: Summary statistics
      int totalAccounts = accountProductsMap.length;
      int accountsWithBids = accountBidsMap.values.where((bids) => bids.isNotEmpty).length;
      int totalBids = userBiddingsResponse.data!.length;
      int totalProducts = productToAccountMap.length;
      
      print('=== METHOD 5: SUMMARY STATISTICS ===');
      print('Total Accounts: $totalAccounts');
      print('Accounts with Bids: $accountsWithBids');
      print('Accounts without Bids: ${totalAccounts - accountsWithBids}');
      print('Total Bids: $totalBids');
      print('Total Products: $totalProducts');
      print('Bid Success Rate: ${(accountsWithBids / totalAccounts * 100).toStringAsFixed(1)}%');
      print('');
      
      print('=== END COMPREHENSIVE COMPARISON ===');
      
    } catch (e) {
      print('Error in comprehensive comparison: $e');
    }
  }

  // Check bidding history for this specific account
  Future<void> _checkAccountBiddingHistory() async {
    try {
      print('=== CHECKING ACCOUNT BIDDING HISTORY ===');
      print('Account: ${widget.selectedAccount}');
      
      final authController = AuthController();
      
      // Get all user bids
      final userBiddingsResponse = await authController.getUserBidding();
      
      if (!userBiddingsResponse.isSuccess || userBiddingsResponse.data == null) {
        print('Failed to get user biddings for history check');
        return;
      }
      
      print('All user bids: ${userBiddingsResponse.data}');
      
      // Get collateral data to match product IDs to account numbers
      final collateralResponse = await authController.getCollateralData();
      
      if (!collateralResponse.isSuccess || collateralResponse.data == null) {
        print('Failed to get collateral data for history check');
        return;
      }
      
      // Create mapping of product ID to account number
      final Map<int, String> productToAccount = {};
      final Map<String, List<int>> accountToProducts = {}; // New: Account to Product IDs mapping
      
      for (var item in collateralResponse.data!) {
        if (item['page']?['acc_num'] != null && item['id'] != null) {
          final productId = item['id'] as int;
          final accountNum = item['page']['acc_num'] as String;
          
          productToAccount[productId] = accountNum;
          
          // Build reverse mapping: account to products
          if (!accountToProducts.containsKey(accountNum)) {
            accountToProducts[accountNum] = [];
          }
          accountToProducts[accountNum]!.add(productId);
        }
      }
      
      print('=== PRODUCT ID TO ACCOUNT MAPPING ===');
      print('Product to Account mapping: $productToAccount');
      print('Account to Products mapping: $accountToProducts');
      
      // Show all products for this specific account
      if (accountToProducts.containsKey(widget.selectedAccount)) {
        final productIds = accountToProducts[widget.selectedAccount]!;
        print('Products for account ${widget.selectedAccount}: $productIds');
        
        setState(() {
          _accountProductIds = productIds;
        });
        
        // Show details of each product
        for (var productId in productIds) {
          final product = collateralResponse.data!.firstWhere(
            (item) => item['id'] == productId,
            orElse: () => null,
          );
          if (product != null) {
            print('Product ID $productId: ${product['title']} - Value: ${product['priceAfterDiscount']}');
          }
        }
      } else {
        print('No products found for account ${widget.selectedAccount}');
        setState(() {
          _accountProductIds = [];
        });
      }
      
      // Find bids for this specific account
      List<Map<String, dynamic>> accountBids = [];
      for (var bid in userBiddingsResponse.data!) {
        final productId = bid['product'] as int?;
        if (productId != null) {
          final mappedAccount = productToAccount[productId];
          if (mappedAccount == widget.selectedAccount) {
            accountBids.add(bid);
            print('Found bid for this account: ${bid['id']} - Product ID: $productId - Amount: ${bid['bid_offer']} - Date: ${bid['created_at']}');
          }
        }
      }
      
      print('Bids for account ${widget.selectedAccount}: ${accountBids.length}');
      print('Account bid details: $accountBids');
      
      setState(() {
        _accountBiddingHistory = accountBids;
        _hasBiddingHistory = accountBids.isNotEmpty;
      });
      
      if (accountBids.isNotEmpty) {
        // Show information about existing bids
        final latestBid = accountBids.last; // Get the most recent bid
        final bidAmount = latestBid['bid_offer']?.toString() ?? '0';
        final bidDate = latestBid['created_at']?.toString() ?? '';
        final bidProductId = latestBid['product']?.toString() ?? '0';
        
        print('Latest bid amount: $bidAmount');
        print('Latest bid date: $bidDate');
        print('Latest bid product ID: $bidProductId');
        print('This account has bidding history: $_hasBiddingHistory');
      } else {
        print('No bids found for this account');
        print('This account has no bidding history: $_hasBiddingHistory');
      }
      
      print('=== END BIDDING HISTORY CHECK ===');
      
    } catch (e) {
      print('Error checking account bidding history: $e');
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
    WidgetsBinding.instance.removeObserver(this);
    _bidController.dispose();
    super.dispose();
  }

  // Submit bidding price for all items in the account
  Future<void> _submitBid() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if user has reached the bid limit for this account
    print('=== BID LIMIT CHECK ===');
    print('Current bid count: $_currentBidCount');
    print('Max bids per account: $_maxBidsPerAccount');
    print('Is limit reached: ${_currentBidCount >= _maxBidsPerAccount}');
    
    if (_currentBidCount >= _maxBidsPerAccount) {
      print('Bid limit reached - preventing submission');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have reached the maximum limit of $_maxBidsPerAccount bids for this account'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }
    
    print('Bid limit not reached - allowing submission');

    if (mounted) {
      setState(() {
        _isSubmitting = true;
      });
    }

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
        // Update bid count locally first (immediate feedback)
          setState(() {
            _currentBidCount++;
          });
        
        // Then refresh from server to ensure accuracy
        await _checkBidCount();
        
        print('=== AFTER BID SUBMISSION ===');
        print('Final bid count after refresh: $_currentBidCount');
        print('Remaining bids: ${_maxBidsPerAccount - _currentBidCount}');
        
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
                            QTextField(
                              hintText: 'Bid Amount (RM)',
                              controller: _bidController,
                              obscureText: false,
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                                fontSize: 12 * scaleFactor,
                              borderRadius: 6 * scaleFactor,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12 * scaleFactor,
                                  vertical: 8 * scaleFactor,
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
                                  GestureDetector(
                                    onTap: () async {
                                      await _checkBidCount();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Bid count refreshed'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.refresh,
                                      size: 14 * scaleFactor,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            
                            // Product IDs for this account
                            if (_accountProductIds.isNotEmpty) Container(
                              margin: EdgeInsets.only(top: 8 * scaleFactor),
                              padding: EdgeInsets.all(8 * scaleFactor),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8 * scaleFactor),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.inventory_2,
                                        size: 14 * scaleFactor,
                                        color: Colors.blue[600],
                                      ),
                                      SizedBox(width: 6 * scaleFactor),
                                      Text(
                                        'Product IDs for this account:',
                                        style: TextStyle(
                                          fontSize: 9 * scaleFactor,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4 * scaleFactor),
                                  Text(
                                    _accountProductIds.join(', '),
                                    style: TextStyle(
                                      fontSize: 8 * scaleFactor,
                                      color: Colors.blue[600],
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Bidding History Indicator
                            if (_hasBiddingHistory) Container(
                              margin: EdgeInsets.only(top: 8 * scaleFactor),
                              padding: EdgeInsets.all(8 * scaleFactor),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8 * scaleFactor),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 14 * scaleFactor,
                                    color: Colors.green[600],
                                  ),
                                  SizedBox(width: 6 * scaleFactor),
                                  Expanded(
                                    child: Text(
                                      'This account has ${_accountBiddingHistory.length} previous bid(s). Latest: RM ${_accountBiddingHistory.isNotEmpty ? _accountBiddingHistory.last['bid_offer']?.toString() ?? '0' : '0'}',
                                      style: TextStyle(
                                        fontSize: 9 * scaleFactor,
                                        color: Colors.green[700],
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
                                  child: QButton(
                                    text: 'Submit Bid',
                                    onPressed: (_isSubmitting || _currentBidCount >= _maxBidsPerAccount) ? null : _submitBid,
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                        fontSize: 11 * scaleFactor,
                                        fontWeight: FontWeight.w600,
                                    borderRadius: 6 * scaleFactor,
                                    padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor),
                                    isLoading: _isSubmitting,
                                    enabled: !_isSubmitting && _currentBidCount < _maxBidsPerAccount,
                                  ),
                                ),
                                SizedBox(width: 12 * scaleFactor),
                                Expanded(
                                  child: QOutlinedButton(
                                    text: 'Cancel',
                                    onPressed: () {
                                      _bidController.clear();
                                    },
                                    borderColor: Colors.orange,
                                    textColor: Colors.orange,
                                    fontSize: 11 * scaleFactor,
                                    fontWeight: FontWeight.w600,
                                    borderRadius: 6 * scaleFactor,
                                    padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor),
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
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/variables.dart';
import 'branch.dart';
import 'details.dart';
import 'collateral.dart';

class BiddingFlowPage extends StatefulWidget {
  const BiddingFlowPage({super.key});

  @override
  State<BiddingFlowPage> createState() => _BiddingFlowPageState();
}

class _BiddingFlowPageState extends State<BiddingFlowPage> {
  int currentStep = 0;
  String? selectedBranch;
  String? selectedAccount;
  List collections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCollections();
  }

  Future<void> fetchCollections() async {
    try {
      print('Fetching collections from: ${Variables.baseUrl}/api/collateral/');
      final response = await http.get(
        Uri.parse('${Variables.baseUrl}/api/collateral/'),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('JSON data: $jsonData');
        setState(() {
          collections = jsonData ?? [];
          isLoading = false;
        });
        print('Collections loaded: ${collections.length} items');
      } else {
        print('API call failed with status: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching collections: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate responsive font sizes based on device screen size
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double scaleFactor = (screenWidth / 375).clamp(0.8, 1.2); // Base on iPhone width
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFE8000),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Browse Available Items',
          style: TextStyle(
            fontSize: 20 * scaleFactor,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          
          // Content
          Expanded(
            child: _buildCurrentStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Branch', Icons.location_on),
          Expanded(child: _buildStepConnector()),
          _buildStepIndicator(1, 'Account', Icons.account_balance),
          Expanded(child: _buildStepConnector()),
          _buildStepIndicator(2, 'Items', Icons.inventory),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title, IconData icon) {
    final isActive = step == currentStep;
    final isCompleted = step < currentStep;
    
    // Calculate responsive sizes
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = (screenWidth / 375).clamp(0.8, 1.2);
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32 * scaleFactor,
            height: 32 * scaleFactor,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? const Color(0xFF10B981)
                  : isActive 
                      ? const Color(0xFFFE8000)
                      : Colors.grey[300],
              borderRadius: BorderRadius.circular(16 * scaleFactor),
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: Colors.white,
              size: 16 * scaleFactor,
            ),
          ),
          SizedBox(height: 4 * scaleFactor),
          Text(
            title,
            style: TextStyle(
              fontSize: 10 * scaleFactor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? const Color(0xFFFE8000) : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      height: 2,
      color: currentStep > 0 ? const Color(0xFF10B981) : Colors.grey[300],
    );
  }

  Widget _buildCurrentStep() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFE8000)),
        ),
      );
    }

    switch (currentStep) {
      case 0:
        return _buildBranchSelection();
      case 1:
        return _buildAccountSelection();
      case 2:
        return _buildCollateralSelection();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBranchSelection() {
    // Calculate responsive sizes
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = (screenWidth / 375).clamp(0.8, 1.2);
    
    // Get unique branches from collateral data
    final branches = <String>{};
    for (var item in collections) {
      if (item['page']?['branch']?['title'] != null) {
        branches.add(item['page']['branch']['title']);
      }
    }
    
    // Get account counts for each branch
    final branchAccounts = <String, Set<String>>{};
    for (var item in collections) {
      if (item['page']?['branch']?['title'] != null && item['page']?['acc_num'] != null) {
        final branchTitle = item['page']['branch']['title'];
        final accountNum = item['page']['acc_num'];
        
        if (branchAccounts.containsKey(branchTitle)) {
          if (branchAccounts[branchTitle] != null) {
            branchAccounts[branchTitle]!.add(accountNum);
          } else {
            branchAccounts[branchTitle] = {accountNum};
          }
        } else {
          branchAccounts[branchTitle] = {accountNum};
        }
      }
    }
    
    // Create branch list with account counts
    final branchList = branches.map((branchTitle) => {
      'title': branchTitle,
      'accountCount': branchAccounts[branchTitle]?.length ?? 0,
    }).toList()
      ..sort((a, b) => (a['title'] as String).toLowerCase().compareTo((b['title'] as String).toLowerCase()));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (branchList.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No branches found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your connection and try again',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: branchList.length,
                itemBuilder: (context, index) {
                final branch = branchList[index];
                final branchTitle = branch['title'] as String;
                final accountCount = branch['accountCount'] as int;
                final isSelected = selectedBranch == branchTitle;
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.only(bottom: 8 * scaleFactor),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFFFE8000).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12 * scaleFactor),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFE8000) : Colors.grey[200]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                            ? const Color(0xFFFE8000).withOpacity(0.15)
                            : Colors.grey.withOpacity(0.08),
                        spreadRadius: 0,
                        blurRadius: isSelected ? 6 : 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12 * scaleFactor),
                      onTap: () {
                        setState(() {
                          selectedBranch = branchTitle;
                        });
                        Future.delayed(const Duration(milliseconds: 150), () {
                          _nextStep();
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(12 * scaleFactor),
                        child: Row(
                          children: [
                            // Compact Icon Container
                            Container(
                              padding: EdgeInsets.all(8 * scaleFactor),
                              decoration: BoxDecoration(
                                gradient: isSelected 
                                    ? LinearGradient(
                                        colors: [
                                          const Color(0xFFFE8000),
                                          const Color(0xFFFF9500),
                                        ],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.grey[100],
                                borderRadius: BorderRadius.circular(10 * scaleFactor),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: isSelected ? Colors.white : Colors.grey[600],
                                size: 20 * scaleFactor,
                              ),
                            ),
                            SizedBox(width: 12 * scaleFactor),
                            
                            // Branch Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    branchTitle,
                                    style: TextStyle(
                                      fontSize: 14 * scaleFactor,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? const Color(0xFFFE8000) : Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: 2 * scaleFactor),
                                  Text(
                                    '$accountCount account${accountCount != 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 10 * scaleFactor,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Account Count Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8 * scaleFactor, 
                                vertical: 4 * scaleFactor,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFFFE8000)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12 * scaleFactor),
                              ),
                              child: Text(
                                '${accountCount}',
                                style: TextStyle(
                                  fontSize: 12 * scaleFactor,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSelection() {
    if (selectedBranch == null) return const SizedBox.shrink();
    
    // Get accounts for selected branch
    final accounts = <String>{};
    for (var item in collections) {
      if (item['page']?['branch']?['title'] == selectedBranch) {
        if (item['page']?['acc_num'] != null) {
          accounts.add(item['page']['acc_num']);
        }
      }
    }
    final accountList = accounts.toList()..sort();

    // Calculate responsive sizes
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = (screenWidth / 375).clamp(0.8, 1.2);

    return Padding(
      padding: EdgeInsets.all(16 * scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Branch Info Header
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(bottom: 16 * scaleFactor),
            padding: EdgeInsets.all(16 * scaleFactor),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFE8000).withOpacity(0.1),
                  const Color(0xFFFF9500).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16 * scaleFactor),
              border: Border.all(
                color: const Color(0xFFFE8000).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFE8000).withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6 * scaleFactor),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFE8000),
                            const Color(0xFFFF9500),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8 * scaleFactor),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16 * scaleFactor,
                      ),
                    ),
                    SizedBox(width: 12 * scaleFactor),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Branch',
                            style: TextStyle(
                              fontSize: 11 * scaleFactor,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2 * scaleFactor),
                          Text(
                            selectedBranch ?? 'Unknown Branch',
                            style: TextStyle(
                              fontSize: 18 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFE8000),
                              letterSpacing: 0.3,
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
                    Container(
                      padding: EdgeInsets.all(6 * scaleFactor),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue[600]!,
                            Colors.blue[700]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8 * scaleFactor),
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: Colors.white,
                        size: 16 * scaleFactor,
                      ),
                    ),
                    SizedBox(width: 12 * scaleFactor),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account',
                            style: TextStyle(
                              fontSize: 11 * scaleFactor,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2 * scaleFactor),
                          Text(
                            selectedAccount ?? 'Unknown Account',
                            style: TextStyle(
                              fontSize: 16 * scaleFactor,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              letterSpacing: 0.3,
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
          
          // Enhanced Account List
          Expanded(
            child: ListView.builder(
              itemCount: accountList.length,
              itemBuilder: (context, index) {
                final account = accountList[index];
                final isSelected = selectedAccount == account;
                
                // Calculate account details
                var totalCollateral = 0;
                var totalReservedPrice = 0.0;
                
                for (var item in collections) {
                  if (item['page']?['branch']?['title'] == selectedBranch &&
                      item['page']?['acc_num'] == account) {
                    totalCollateral += 1;
                    totalReservedPrice += (item['priceAfterDiscount'] ?? 0.0);
                  }
                }
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.only(bottom: 12 * scaleFactor),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isSelected 
                          ? [
                              const Color(0xFFFE8000).withOpacity(0.1),
                              const Color(0xFFFF9500).withOpacity(0.05),
                            ]
                          : [
                              Colors.white,
                              Colors.grey[50]!,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16 * scaleFactor),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFE8000) : Colors.grey[200]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                            ? const Color(0xFFFE8000).withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: isSelected ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16 * scaleFactor),
                      onTap: () {
                        setState(() {
                          selectedAccount = account;
                        });
                        Future.delayed(const Duration(milliseconds: 150), () {
                          _nextStep();
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16 * scaleFactor),
                        child: Row(
                          children: [
                            // Professional Icon Container
                            Container(
                              padding: EdgeInsets.all(8 * scaleFactor),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue[600]!,
                                    Colors.blue[700]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12 * scaleFactor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue[600]!.withOpacity(0.3),
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.account_balance,
                                color: Colors.white,
                                size: 18 * scaleFactor,
                              ),
                            ),
                            SizedBox(width: 16 * scaleFactor),
                            
                            // Account Info with Label
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account',
                                    style: TextStyle(
                                      fontSize: 11 * scaleFactor,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 2 * scaleFactor),
                                  Text(
                                    'Account: ${account.substring(0, 8)}...',
                                    style: TextStyle(
                                      fontSize: 16 * scaleFactor,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? const Color(0xFFFE8000) : Colors.grey[800],
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(height: 8 * scaleFactor),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.inventory_2,
                                        size: 14 * scaleFactor,
                                        color: Colors.blue[600],
                                      ),
                                      SizedBox(width: 4 * scaleFactor),
                                      Text(
                                        '$totalCollateral',
                                        style: TextStyle(
                                          fontSize: 12 * scaleFactor,
                                          color: Colors.blue[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 16 * scaleFactor),
                                      Icon(
                                        Icons.attach_money,
                                        size: 14 * scaleFactor,
                                        color: Colors.green[600],
                                      ),
                                      SizedBox(width: 4 * scaleFactor),
                                      Text(
                                        'RM ${totalReservedPrice.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 12 * scaleFactor,
                                          color: Colors.green[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Selection Indicator
                            if (isSelected)
                              Container(
                                padding: EdgeInsets.all(6 * scaleFactor),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFFE8000),
                                      const Color(0xFFFF9500),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12 * scaleFactor),
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16 * scaleFactor,
                                ),
                              )
                            else
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey[400],
                                size: 16 * scaleFactor,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollateralSelection() {
    if (selectedBranch == null || selectedAccount == null) return const SizedBox.shrink();
    
    // Calculate responsive sizes
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = (screenWidth / 375).clamp(0.8, 1.2);
    
    // Filter collaterals for selected branch and account
    final filteredCollaterals = collections.where((item) {
      return selectedBranch != null && 
             selectedAccount != null &&
             item['page']?['branch']?['title'] == selectedBranch &&
             item['page']?['acc_num'] == selectedAccount;
    }).toList();
    
    // Calculate summary statistics
    var totalItems = filteredCollaterals.length;
    var totalValue = 0.0;
    var categories = <String>{};
    
    for (var item in filteredCollaterals) {
      totalValue += (item['priceAfterDiscount'] ?? 0.0);
      if (item['category'] != null) {
        categories.add(item['category'] as String);
      }
    }

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(16 * scaleFactor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header with Summary
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(bottom: 16 * scaleFactor),
                padding: EdgeInsets.all(16 * scaleFactor),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFE8000).withOpacity(0.1),
                      const Color(0xFFFF9500).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16 * scaleFactor),
                  border: Border.all(
                    color: const Color(0xFFFE8000).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFE8000).withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Professional Branch and Account Info
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(6 * scaleFactor),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFFE8000),
                                          const Color(0xFFFF9500),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8 * scaleFactor),
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 14 * scaleFactor,
                                    ),
                                  ),
                                  SizedBox(width: 8 * scaleFactor),
                                  Text(
                                    selectedBranch ?? 'Unknown Branch',
                                    style: TextStyle(
                                      fontSize: 14 * scaleFactor,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFFE8000),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8 * scaleFactor),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(6 * scaleFactor),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue[600]!,
                                          Colors.blue[700]!,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8 * scaleFactor),
                                    ),
                                    child: Icon(
                                      Icons.account_balance,
                                      color: Colors.white,
                                      size: 14 * scaleFactor,
                                    ),
                                  ),
                                  SizedBox(width: 8 * scaleFactor),
                                  Text(
                                    selectedAccount ?? 'Unknown Account',
                                    style: TextStyle(
                                      fontSize: 12 * scaleFactor,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[800],
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor, vertical: 4 * scaleFactor),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFE8000).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12 * scaleFactor),
                          ),
                          child: Text(
                            '$totalItems',
                            style: TextStyle(
                              fontSize: 12 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFE8000),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16 * scaleFactor),
                    
                    // Professional Summary Statistics
                    Container(
                      padding: EdgeInsets.all(16 * scaleFactor),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[50]!,
                            Colors.grey[100]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12 * scaleFactor),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSummaryItem(
                              Icons.inventory_2,
                              'Items',
                              '$totalItems',
                              Colors.blue[600]!,
                              scaleFactor,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30 * scaleFactor,
                            color: Colors.grey[300],
                          ),
                          Expanded(
                            child: _buildSummaryItem(
                              Icons.attach_money,
                              'Value',
                              'RM ${totalValue.toStringAsFixed(0)}',
                              Colors.green[600]!,
                              scaleFactor,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30 * scaleFactor,
                            color: Colors.grey[300],
                          ),
                          Expanded(
                            child: _buildSummaryItem(
                              Icons.category,
                              'Types',
                              '${categories.length}',
                              Colors.purple[600]!,
                              scaleFactor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Enhanced Items List
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16 * scaleFactor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16 * scaleFactor),
                    child: _buildEnhancedItemsList(filteredCollaterals, scaleFactor),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Floating Back Button
        Positioned(
          bottom: 20 * scaleFactor,
          right: 20 * scaleFactor,
          child: FloatingActionButton(
            onPressed: _previousStep,
            backgroundColor: const Color(0xFFFE8000),
            elevation: 6,
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24 * scaleFactor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedItemsList(List filteredCollaterals, double scaleFactor) {
    if (filteredCollaterals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48 * scaleFactor,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12 * scaleFactor),
            Text(
              'No items available',
              style: TextStyle(
                fontSize: 16 * scaleFactor,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4 * scaleFactor),
            Text(
              'This account has no collateral items',
              style: TextStyle(
                fontSize: 12 * scaleFactor,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 8 * scaleFactor),
      itemCount: filteredCollaterals.length,
      itemBuilder: (context, index) {
        final item = filteredCollaterals[index];
        final originalPrice = item['fullPrice'] ?? 0.0;
        final discount = item['discount'] ?? 0.0;
        final reservedPrice = item['priceAfterDiscount'] ?? 0.0;
        final category = item['category'] ?? 'General';
        final title = item['title'] ?? 'Untitled Item';

        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(bottom: 12 * scaleFactor),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
            borderRadius: BorderRadius.circular(16 * scaleFactor),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.12),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12 * scaleFactor),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollateralPage(
                      collections: collections,
                      branch: selectedBranch ?? '',
                      account: selectedAccount ?? '',
                    ),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(12 * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Professional Icon and Price Row
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8 * scaleFactor),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFE8000),
                                const Color(0xFFFF9500),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12 * scaleFactor),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFE8000).withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            color: Colors.white,
                            size: 18 * scaleFactor,
                          ),
                        ),
                        SizedBox(width: 16 * scaleFactor),
                        Expanded(
                          child: _buildPriceColumn(
                            'Original',
                            'RM ${originalPrice.toStringAsFixed(0)}',
                            Colors.grey[600]!,
                            scaleFactor,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 24 * scaleFactor,
                          color: Colors.grey[300],
                        ),
                        Expanded(
                          child: _buildPriceColumn(
                            'Discount',
                            'RM ${discount.toStringAsFixed(0)}',
                            Colors.red[600]!,
                            scaleFactor,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 24 * scaleFactor,
                          color: Colors.grey[300],
                        ),
                        Expanded(
                          child: _buildPriceColumn(
                            'Reserved',
                            'RM ${reservedPrice.toStringAsFixed(0)}',
                            const Color(0xFFFE8000),
                            scaleFactor,
                            isHighlighted: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceColumn(String label, String value, Color color, double scaleFactor, {bool isHighlighted = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9 * scaleFactor,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4 * scaleFactor),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 13 * scaleFactor : 11 * scaleFactor,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceItem(String label, String value, Color color, double scaleFactor, {bool isHighlighted = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8 * scaleFactor,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2 * scaleFactor),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 12 * scaleFactor : 10 * scaleFactor,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value, Color color, double scaleFactor) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20 * scaleFactor,
        ),
        SizedBox(height: 6 * scaleFactor),
        Text(
          label,
          style: TextStyle(
            fontSize: 10 * scaleFactor,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 2 * scaleFactor),
        Text(
          value,
          style: TextStyle(
            fontSize: 14 * scaleFactor,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCompactStatCard(IconData icon, String label, String value, Color color, double scaleFactor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor, horizontal: 6 * scaleFactor),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8 * scaleFactor),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 16 * scaleFactor,
          ),
          SizedBox(height: 2 * scaleFactor),
          Text(
            label,
            style: TextStyle(
              fontSize: 8 * scaleFactor,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12 * scaleFactor,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (currentStep < 2) {
      setState(() {
        currentStep++;
      });
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
        if (currentStep == 0) {
          selectedBranch = null;
          selectedAccount = null;
        } else if (currentStep == 1) {
          selectedAccount = null;
        }
      });
    }
  }
}

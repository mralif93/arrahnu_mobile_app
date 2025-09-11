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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFE8000),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Browse Available Items',
          style: TextStyle(
            fontSize: 20,
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
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? const Color(0xFF10B981)
                  : isActive 
                      ? const Color(0xFFFE8000)
                      : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
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
          branchAccounts[branchTitle]!.add(accountNum);
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
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFE8000) : Colors.grey[200]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFFFE8000).withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: isSelected ? const Color(0xFFFE8000) : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                    title: Text(
                      branchTitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFFFE8000) : Colors.grey[800],
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFFFE8000).withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${accountCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFFFE8000) : Colors.grey[600],
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedBranch = branchTitle;
                      });
                      _nextStep();
                    },
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back),
                color: const Color(0xFFFE8000),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Branch: $selectedBranch',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFE8000) : Colors.grey[200]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFFFE8000).withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: isSelected ? const Color(0xFFFE8000) : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                    title: Text(
                      'Account: $account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFFFE8000) : Colors.grey[800],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Collaterals: $totalCollateral'),
                        Text('Reserved Price: RM ${totalReservedPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: isSelected 
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFFFE8000),
                            size: 24,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        selectedAccount = account;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedAccount != null ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE8000),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Next: View Items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollateralSelection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back),
                color: const Color(0xFFFE8000),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$selectedBranch - Account: $selectedAccount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DetailsPage(
                data: collections,
                name: selectedBranch!,
              ),
            ),
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

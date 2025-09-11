import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'collateral_selection_page.dart';

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
      body: accounts.isEmpty
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
                          child: Material(
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
                                    Container(
                                      padding: EdgeInsets.all(6 * scaleFactor),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[600]!.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.account_balance_wallet,
                                        color: Colors.blue[600],
                                        size: 18 * scaleFactor,
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
            ),
    );
  }
}

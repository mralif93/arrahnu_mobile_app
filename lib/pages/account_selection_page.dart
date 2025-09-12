import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'collateral_selection_page.dart';
import 'biddings.dart';
import '../constant/variables.dart';
import '../theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchCollateralData();
  }

  @override
  void dispose() {
    super.dispose();
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
    final scaleFactor = AppTheme.getScaleFactor(context);

    final accounts = widget.branchData[widget.selectedBranch]?.toList() ?? [];
    accounts.sort((a, b) => a.compareTo(b));

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Account',
          style: AppTheme.getAppBarTitleStyle(scaleFactor),
        ),
        backgroundColor: AppTheme.primaryOrange,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.textWhite,
            size: AppTheme.responsiveSize(AppTheme.iconXXLarge, scaleFactor),
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
              size: AppTheme.responsiveSize(AppTheme.iconXXLarge, scaleFactor),
            ),
            tooltip: 'View My Biddings',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.primaryOrange,
                  ),
                  SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),
                  Text(
                    'Loading accounts...',
                    style: AppTheme.getBodyStyle(scaleFactor),
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
                        size: AppTheme.responsiveSize(AppTheme.iconXXXLarge, scaleFactor),
                        color: AppTheme.textMuted,
                      ),
                      SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),
                      Text(
                        'No accounts available',
                        style: AppTheme.getHeaderStyle(scaleFactor),
                      ),
                      SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                      Text(
                        'This branch has no accounts',
                        style: AppTheme.getCaptionStyle(scaleFactor),
                      ),
                    ],
                  ),
                )
          : Padding(
              padding: AppTheme.getCardPadding(scaleFactor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clean Header
                  Container(
                    padding: AppTheme.getCardPadding(scaleFactor),
                    decoration: AppTheme.getCardDecoration(scaleFactor),
                    child: Row(
                      children: [
                        Container(
                          padding: AppTheme.getIconCirclePadding(scaleFactor),
                          decoration: AppTheme.getIconCircleDecoration(AppTheme.primaryOrange, scaleFactor),
                          child: Icon(
                            Icons.location_on,
                            size: AppTheme.responsiveSize(AppTheme.iconLarge, scaleFactor),
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                        SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                        Expanded(
                          child: Text(
                            widget.selectedBranch,
                            style: AppTheme.getBodyStyle(scaleFactor),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor), 
                            vertical: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor),
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusSmall, scaleFactor)),
                          ),
                          child: Text(
                            '${accounts.length} accounts',
                            style: TextStyle(
                              fontSize: AppTheme.responsiveSize(AppTheme.fontSizeSmall, scaleFactor),
                              fontWeight: AppTheme.fontWeightSemiBold,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXLarge, scaleFactor)),
                  
                  // Accounts List
                  Expanded(
                    child: ListView.builder(
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        final accountNumber = accounts[index];
                        
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          margin: EdgeInsets.only(bottom: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
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
                                  borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusXLarge, scaleFactor)),
                                  child: Container(
                                    padding: AppTheme.getCardPadding(scaleFactor),
                                    decoration: AppTheme.getCardDecoration(scaleFactor),
                                    child: Row(
                                      children: [
                                        // Account Image or Icon
                                        Container(
                                          width: AppTheme.responsiveSize(AppTheme.iconXXLarge, scaleFactor),
                                          height: AppTheme.responsiveSize(AppTheme.iconXXLarge, scaleFactor),
                                          decoration: AppTheme.getIconCircleDecoration(AppTheme.primaryOrange, scaleFactor),
                                          child: accountImages[accountNumber] != null
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusCircular, scaleFactor)),
                                                  child: Image.network(
                                                    '${Variables.baseUrl}${accountImages[accountNumber]}',
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return Container(
                                                        decoration: AppTheme.getIconCircleDecoration(AppTheme.textMuted.withOpacity(0.2), scaleFactor),
                                                        child: Center(
                                                          child: SizedBox(
                                                            width: AppTheme.responsiveSize(AppTheme.iconSmall, scaleFactor),
                                                            height: AppTheme.responsiveSize(AppTheme.iconSmall, scaleFactor),
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: AppTheme.primaryOrange,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        decoration: AppTheme.getIconCircleDecoration(AppTheme.primaryOrange, scaleFactor),
                                                        child: Icon(
                                                          Icons.account_balance_wallet,
                                                          color: AppTheme.primaryOrange,
                                                          size: AppTheme.responsiveSize(AppTheme.iconSmall, scaleFactor),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Container(
                                                  decoration: AppTheme.getIconCircleDecoration(AppTheme.primaryOrange, scaleFactor),
                                                  child: Icon(
                                                    Icons.account_balance_wallet,
                                                    color: AppTheme.primaryOrange,
                                                    size: AppTheme.responsiveSize(AppTheme.iconSmall, scaleFactor),
                                                  ),
                                                ),
                                        ),
                                        SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                                        Expanded(
                                          child: Text(
                                            accountNumber,
                                            style: AppTheme.getBodyStyle(scaleFactor),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor), 
                                            vertical: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor),
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryOrange.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusSmall, scaleFactor)),
                                          ),
                                          child: Text(
                                            '${accountCollateralCounts[accountNumber] ?? 0}',
                                            style: TextStyle(
                                              fontSize: AppTheme.responsiveSize(AppTheme.fontSizeSmall, scaleFactor),
                                              fontWeight: AppTheme.fontWeightSemiBold,
                                              color: AppTheme.primaryOrange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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

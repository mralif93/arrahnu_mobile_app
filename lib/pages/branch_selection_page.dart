import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/variables.dart';
import '../theme/app_theme.dart';
import 'account_selection_page.dart';
import 'biddings.dart';
import '../services/session_service.dart';

class BranchSelectionPage extends StatefulWidget {
  const BranchSelectionPage({Key? key}) : super(key: key);

  @override
  State<BranchSelectionPage> createState() => _BranchSelectionPageState();
}

class _BranchSelectionPageState extends State<BranchSelectionPage> {
  List<dynamic> collections = [];
  bool isLoading = true;
  Map<String, Set<String>> branchData = {};
  final SessionService _sessionService = SessionService();
  bool _isSessionActive = false;

  @override
  void initState() {
    super.initState();
    _checkSessionAndFetch();
  }

  Future<void> _checkSessionAndFetch() async {
    // Check if session is active
    final isSessionActive = await _sessionService.refreshSessionStatus();
    setState(() {
      _isSessionActive = isSessionActive;
    });

    if (isSessionActive) {
      _fetchCollections();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCollections() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse('${Variables.baseUrl}/api/collateral/'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          collections = data; // The API returns the list directly, not wrapped in a 'data' property
          _processBranchData();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load branches')),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _processBranchData() {
    branchData.clear();
    
    for (var item in collections) {
      if (item['page']?['branch']?['title'] != null && item['page']?['acc_num'] != null) {
        final branchTitle = item['page']['branch']['title'] as String;
        final accountNumber = item['page']['acc_num'] as String;
        
        if (!branchData.containsKey(branchTitle)) {
          branchData[branchTitle] = <String>{};
        }
        branchData[branchTitle]!.add(accountNumber);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = AppTheme.getScaleFactor(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Branch',
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
              Icons.list_alt,
              color: AppTheme.textWhite,
              size: AppTheme.responsiveSize(AppTheme.iconXXLarge, scaleFactor),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFFE8000)),
                      ),
                      SizedBox(height: 16 * scaleFactor),
                      Text(
                        'Loading branches...',
                        style: TextStyle(
                          fontSize: 16 * scaleFactor,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : branchData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64 * scaleFactor,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16 * scaleFactor),
                  Text(
                    'No branches available',
                    style: TextStyle(
                      fontSize: 16 * scaleFactor,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8 * scaleFactor),
                  Text(
                    'Please try again later',
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
                        padding: AppTheme.getCardPadding(scaleFactor),
                        decoration: AppTheme.getCardDecoration(scaleFactor),
                        child: Row(
                          children: [
                            Container(
                              padding: AppTheme.getIconCirclePadding(scaleFactor),
                              decoration: AppTheme.getIconCircleDecoration(AppTheme.primaryOrange, scaleFactor),
                              child: Icon(
                                Icons.business,
                                size: AppTheme.responsiveSize(AppTheme.iconSmall, scaleFactor),
                                color: AppTheme.primaryOrange,
                              ),
                            ),
                            SizedBox(width: AppTheme.spacingMedium),
                            Expanded(
                              child: Text(
                                'Available Branches',
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
                                borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusMedium, scaleFactor)),
                              ),
                              child: Text(
                                '${branchData.length} branches',
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
                      
                      SizedBox(height: 20 * scaleFactor),
                      
                      // Branches List
                      Expanded(
                        child: ListView.builder(
                          itemCount: branchData.length,
                          itemBuilder: (context, index) {
                            final branchTitle = branchData.keys.elementAt(index);
                            final accountCount = branchData[branchTitle]!.length;
                            
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 300 + (index * 50)),
                              margin: EdgeInsets.only(bottom: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(
                                      AccountSelectionPage(
                                        selectedBranch: branchTitle,
                                        branchData: branchData,
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusXLarge, scaleFactor)),
                                  child: Container(
                                    padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                                    decoration: AppTheme.getCardDecoration(scaleFactor),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: AppTheme.getIconCirclePadding(scaleFactor),
                                          decoration: AppTheme.getIconCircleDecoration(AppTheme.primaryOrange, scaleFactor),
                                          child: Icon(
                                            Icons.business,
                                            color: AppTheme.primaryOrange,
                                            size: AppTheme.responsiveSize(AppTheme.iconLarge, scaleFactor),
                                          ),
                                        ),
                                        SizedBox(width: AppTheme.spacingMedium),
                                        Expanded(
                                          child: Text(
                                            branchTitle,
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
                                            borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusMedium, scaleFactor)),
                                          ),
                                          child: Text(
                                            '$accountCount',
                                            style: TextStyle(
                                              fontSize: AppTheme.responsiveSize(AppTheme.fontSizeSmall, scaleFactor),
                                              fontWeight: AppTheme.fontWeightBold,
                                              color: AppTheme.primaryOrange,
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

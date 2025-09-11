import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/variables.dart';
import 'account_selection_page.dart';

class BranchSelectionPage extends StatefulWidget {
  const BranchSelectionPage({Key? key}) : super(key: key);

  @override
  State<BranchSelectionPage> createState() => _BranchSelectionPageState();
}

class _BranchSelectionPageState extends State<BranchSelectionPage> {
  List<dynamic> collections = [];
  bool isLoading = true;
  Map<String, Set<String>> branchData = {};

  @override
  void initState() {
    super.initState();
    _fetchCollections();
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = (screenWidth / 375).clamp(0.8, 1.2);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Select Branch',
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
                                Icons.business,
                                size: 14 * scaleFactor,
                                color: const Color(0xFFFE8000),
                              ),
                            ),
                            SizedBox(width: 12 * scaleFactor),
                            Expanded(
                              child: Text(
                                'Available Branches',
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
                                color: const Color(0xFFFE8000).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8 * scaleFactor),
                              ),
                              child: Text(
                                '${branchData.length} branches',
                                style: TextStyle(
                                  fontSize: 10 * scaleFactor,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFE8000),
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
                              margin: EdgeInsets.only(bottom: 12 * scaleFactor),
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
                                            color: const Color(0xFFFE8000).withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.business,
                                            color: const Color(0xFFFE8000),
                                            size: 18 * scaleFactor,
                                          ),
                                        ),
                                        SizedBox(width: 12 * scaleFactor),
                                        Expanded(
                                          child: Text(
                                            branchTitle,
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
                                            color: const Color(0xFFFE8000).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8 * scaleFactor),
                                          ),
                                          child: Text(
                                            '$accountCount',
                                            style: TextStyle(
                                              fontSize: 10 * scaleFactor,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFFE8000),
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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/variables.dart';
import 'collateral_details_page.dart';

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
  bool isLoading = true;

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
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load items')),
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = (screenWidth / 375).clamp(0.8, 1.2);

    // Filter collaterals for selected branch and account
    final filteredCollaterals = collections.where((item) {
      return item['page']?['branch']?['title'] == widget.selectedBranch &&
             item['page']?['acc_num'] == widget.selectedAccount;
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Collateral',
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
                    'Loading items...',
                    style: TextStyle(
                      fontSize: 16 * scaleFactor,
                      color: Colors.grey[600],
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
              // Clean Header with Summary
              Container(
                margin: EdgeInsets.only(bottom: 16 * scaleFactor),
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
                    child: Column(
                      children: [
                        // Simple Branch and Account Info
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
                                      Text(
                                        '${widget.selectedBranch}',
                                        style: TextStyle(
                                          fontSize: 12 * scaleFactor,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2 * scaleFactor),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(6 * scaleFactor),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[600]!.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.account_balance,
                                          size: 14 * scaleFactor,
                                          color: Colors.blue[600],
                                        ),
                                      ),
                                      SizedBox(width: 12 * scaleFactor),
                                      Text(
                                        '${widget.selectedAccount}',
                                        style: TextStyle(
                                          fontSize: 10 * scaleFactor,
                                          color: Colors.grey[600],
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
                                borderRadius: BorderRadius.circular(8 * scaleFactor),
                              ),
                              child: Text(
                                '$totalItems items',
                                style: TextStyle(
                                  fontSize: 10 * scaleFactor,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFE8000),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 16 * scaleFactor),
                        
                        // Clean Summary Statistics
                        Container(
                          padding: EdgeInsets.all(16 * scaleFactor),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8 * scaleFactor),
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
                    child: _buildEnhancedItemsList(filteredCollaterals, scaleFactor),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value, Color color, double scaleFactor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9 * scaleFactor,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2 * scaleFactor),
        Text(
          value,
          style: TextStyle(
            fontSize: 11 * scaleFactor,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
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
      padding: EdgeInsets.symmetric(horizontal: 1 * scaleFactor, vertical: 8 * scaleFactor),
      itemCount: filteredCollaterals.length,
      itemBuilder: (context, index) {
        final item = filteredCollaterals[index];
        final category = item['category'] as String?;
        final title = item['title'] as String?;
        // Try different possible field names for prices
        final priceAfterDiscount = item['priceAfterDiscount'] as num? ?? 
                                  item['price_after_discount'] as num? ??
                                  item['finalPrice'] as num? ??
                                  item['final_price'] as num?;
        
        final priceBeforeDiscount = item['priceBeforeDiscount'] as num? ?? 
                                   item['price_before_discount'] as num? ??
                                   item['originalPrice'] as num? ??
                                   item['original_price'] as num? ??
                                   item['fullPrice'] as num? ??
                                   item['price'] as num?;
        
        final discount = item['discount'] as num? ?? 
                        item['discountAmount'] as num? ??
                        item['discount_amount'] as num?;
        
        // Calculate before price if not available
        final calculatedBeforePrice = priceBeforeDiscount ?? 
                                    (priceAfterDiscount != null && discount != null ? 
                                     priceAfterDiscount + discount : null);
        

        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 50)),
          margin: EdgeInsets.only(bottom: 8 * scaleFactor),
          child: Material(
            color: Colors.transparent,
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
                    // Item Icon - Simple orange square
                    Container(
                      width: 36 * scaleFactor,
                      height: 36 * scaleFactor,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE8000),
                        borderRadius: BorderRadius.circular(6 * scaleFactor),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: Colors.white,
                        size: 18 * scaleFactor,
                      ),
                    ),
                    
                    SizedBox(width: 12 * scaleFactor),
                    
                    // Price Details - Horizontal Layout with Separators
                    Expanded(
                      child: Row(
                        children: [
                          // Before Column
                          Expanded(
                            child: _buildPriceColumn(
                              'Before',
                              calculatedBeforePrice?.toDouble() ?? 0.0,
                              Colors.grey[600]!,
                              scaleFactor,
                            ),
                          ),
                          // Simple Separator
                          Container(
                            height: 20 * scaleFactor,
                            width: 1,
                            color: Colors.grey[200],
                          ),
                          // Discount Column
                          Expanded(
                            child: _buildPriceColumn(
                              'Discount',
                              discount?.toDouble() ?? 0.0,
                              Colors.red[600]!,
                              scaleFactor,
                            ),
                          ),
                          // Simple Separator
                          Container(
                            height: 20 * scaleFactor,
                            width: 1,
                            color: Colors.grey[200],
                          ),
                          // After Column
                          Expanded(
                            child: _buildPriceColumn(
                              'After',
                              priceAfterDiscount?.toDouble() ?? 0.0,
                              Colors.green[600]!,
                              scaleFactor,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildStatRow(String label, String value, Color color, double scaleFactor) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12 * scaleFactor,
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
        ),
      ],
    );
  }

  Widget _buildPriceColumn(String label, double value, Color color, double scaleFactor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9 * scaleFactor,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2 * scaleFactor),
        Text(
          'RM ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 10 * scaleFactor,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

}

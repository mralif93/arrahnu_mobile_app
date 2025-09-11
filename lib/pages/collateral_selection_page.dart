import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/variables.dart';
import '../controllers/authorization.dart';
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
  String? accountImageUrl;
  bool isLoading = true;
  
  // Bidding form variables
  final _formKey = GlobalKey<FormState>();
  final _bidController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchCollections();
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  // Submit bidding price for all items in the account
  Future<void> _submitBid() async {
    if (!_formKey.currentState!.validate()) return;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bid submitted successfully for all items'),
            backgroundColor: Colors.green,
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
    final scaleFactor = MediaQuery.of(context).size.width / 375.0;
    
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
      appBar: AppBar(
        title: Text('Collateral'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8 * scaleFactor),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                  size: 16 * scaleFactor,
                                ),
                              ),
                              SizedBox(width: 12 * scaleFactor),
                              Expanded(
                                child: Text(
                                  widget.selectedBranch,
                                  style: TextStyle(
                                    fontSize: 12 * scaleFactor,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8 * scaleFactor),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8 * scaleFactor),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.account_balance,
                                  color: Colors.green,
                                  size: 16 * scaleFactor,
                                ),
                              ),
                              SizedBox(width: 12 * scaleFactor),
                              Expanded(
                                child: Text(
                                  widget.selectedAccount,
                                  style: TextStyle(
                                    fontSize: 12 * scaleFactor,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
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

                    // Bidding Card
                    Container(
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
                                    fontSize: 14 * scaleFactor,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8 * scaleFactor),
                            Text(
                              'This will place the same bid amount for all $totalItems items in this account.',
                              style: TextStyle(
                                fontSize: 12 * scaleFactor,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 16 * scaleFactor),
                            TextFormField(
                              controller: _bidController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Bid Amount (RM)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8 * scaleFactor),
                                ),
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter bid amount';
                                }
                                final amount = double.tryParse(value);
                                if (amount == null || amount <= 0) {
                                  return 'Please enter valid amount';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16 * scaleFactor),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting ? null : _submitBid,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 12 * scaleFactor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8 * scaleFactor),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? SizedBox(
                                            height: 20 * scaleFactor,
                                            width: 20 * scaleFactor,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Text('Submit Bid'),
                                  ),
                                ),
                                SizedBox(width: 12 * scaleFactor),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      _bidController.clear();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 12 * scaleFactor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8 * scaleFactor),
                                      ),
                                    ),
                                    child: Text('Cancel'),
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
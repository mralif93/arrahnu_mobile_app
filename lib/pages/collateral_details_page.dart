import 'package:flutter/material.dart';
import '../constant/variables.dart';

class CollateralDetailsPage extends StatefulWidget {
  final Map<String, dynamic> collateralItem;
  final String selectedBranch;
  final String selectedAccount;

  const CollateralDetailsPage({
    Key? key,
    required this.collateralItem,
    required this.selectedBranch,
    required this.selectedAccount,
  }) : super(key: key);

  @override
  State<CollateralDetailsPage> createState() => _CollateralDetailsPageState();
}

class _CollateralDetailsPageState extends State<CollateralDetailsPage> {
  // Helper method to safely parse values to double
  double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = (screenWidth / 375).clamp(0.8, 1.2);

    try {
      // Extract data from collateral item
    final category = widget.collateralItem['category'] as String? ?? 'N/A';
    final title = widget.collateralItem['title'] as String? ?? 'N/A';
    final goldWeight = _parseToDouble(widget.collateralItem['gold_weight']) ?? 0.0;
    final goldStandard = widget.collateralItem['gold_standard']?['title'] as String? ?? 'N/A';
    final goldType = widget.collateralItem['gold_type']?['title'] as String? ?? 'N/A';
    final preciousStones = widget.collateralItem['precious_stones'] as bool? ?? false;
    final remarks = widget.collateralItem['remarks'] as String? ?? 'No remarks';
    
    // Price information with safe parsing
    final priceAfterDiscount = _parseToDouble(widget.collateralItem['priceAfterDiscount']) ?? 
                              _parseToDouble(widget.collateralItem['price_after_discount']) ??
                              _parseToDouble(widget.collateralItem['finalPrice']) ??
                              _parseToDouble(widget.collateralItem['final_price']);
    
    final priceBeforeDiscount = _parseToDouble(widget.collateralItem['priceBeforeDiscount']) ?? 
                               _parseToDouble(widget.collateralItem['price_before_discount']) ??
                               _parseToDouble(widget.collateralItem['originalPrice']) ??
                               _parseToDouble(widget.collateralItem['original_price']) ??
                               _parseToDouble(widget.collateralItem['fullPrice']) ??
                               _parseToDouble(widget.collateralItem['price']);
    
    final discount = _parseToDouble(widget.collateralItem['discount']) ?? 
                    _parseToDouble(widget.collateralItem['discountAmount']) ??
                    _parseToDouble(widget.collateralItem['discount_amount']);
    
    final calculatedBeforePrice = priceBeforeDiscount ?? 
                                (priceAfterDiscount != null && discount != null ? 
                                 priceAfterDiscount + discount : null);

    // Images
    final images = widget.collateralItem['images'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Collateral Details',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16 * scaleFactor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
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
                    ],
                  ),
                  SizedBox(height: 8 * scaleFactor),
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
                      Expanded(
                        child: Text(
                          widget.selectedAccount,
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

            SizedBox(height: 16 * scaleFactor),

            // Item Details Card
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item Information',
                    style: TextStyle(
                      fontSize: 16 * scaleFactor,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16 * scaleFactor),
                  
                  _buildDetailRow('Title', title, scaleFactor),
                  _buildDetailRow('Category', category, scaleFactor),
                  _buildDetailRow('Gold Type', goldType, scaleFactor),
                  _buildDetailRow('Gold Standard', goldStandard, scaleFactor),
                  _buildDetailRow('Gold Weight', '${goldWeight.toStringAsFixed(2)} grams', scaleFactor),
                  _buildDetailRow('Precious Stones', preciousStones ? 'Yes' : 'No', scaleFactor),
                  _buildDetailRow('Remarks', remarks, scaleFactor),
                ],
              ),
            ),

            SizedBox(height: 16 * scaleFactor),

            // Price Details Card
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pricing Information',
                    style: TextStyle(
                      fontSize: 16 * scaleFactor,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16 * scaleFactor),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriceCard(
                          'Before',
                          calculatedBeforePrice?.toDouble() ?? 0.0,
                          Colors.grey[600]!,
                          scaleFactor,
                        ),
                      ),
                      SizedBox(width: 12 * scaleFactor),
                      Expanded(
                        child: _buildPriceCard(
                          'Discount',
                          discount?.toDouble() ?? 0.0,
                          Colors.red[600]!,
                          scaleFactor,
                        ),
                      ),
                      SizedBox(width: 12 * scaleFactor),
                      Expanded(
                        child: _buildPriceCard(
                          'After',
                          priceAfterDiscount?.toDouble() ?? 0.0,
                          Colors.green[600]!,
                          scaleFactor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (images.isNotEmpty) ...[
              SizedBox(height: 16 * scaleFactor),
              
              // Images Card
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Images',
                      style: TextStyle(
                        fontSize: 16 * scaleFactor,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    
                    // Display images in a grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8 * scaleFactor,
                        mainAxisSpacing: 8 * scaleFactor,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final imageUrl = '${Variables.baseUrl}${images[index]}';
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8 * scaleFactor),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8 * scaleFactor),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                    size: 32 * scaleFactor,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
    } catch (e) {
      // Return error screen if there's an issue with data parsing
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Collateral Details',
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
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16 * scaleFactor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64 * scaleFactor,
                  color: Colors.red[400],
                ),
                SizedBox(height: 16 * scaleFactor),
                Text(
                  'Error Loading Details',
                  style: TextStyle(
                    fontSize: 18 * scaleFactor,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8 * scaleFactor),
                Text(
                  'Unable to load collateral details. Please try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14 * scaleFactor,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16 * scaleFactor),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFE8000),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value, double scaleFactor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * scaleFactor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100 * scaleFactor,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12 * scaleFactor,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12 * scaleFactor,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(String label, double value, Color color, double scaleFactor) {
    return Container(
      padding: EdgeInsets.all(12 * scaleFactor),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8 * scaleFactor),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10 * scaleFactor,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(height: 4 * scaleFactor),
          Text(
            'RM ${value.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14 * scaleFactor,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

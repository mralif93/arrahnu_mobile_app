import 'package:flutter/material.dart';
import '../controllers/authorization.dart';
import '../theme/app_theme.dart';

class PricesPage extends StatefulWidget {
  const PricesPage({super.key});

  @override
  State<PricesPage> createState() => _PricesPageState();
}

class _PricesPageState extends State<PricesPage> {
  List<dynamic> goldPrices = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGoldPrices();
  }

  Future<void> _loadGoldPrices() async {
    try {
      final response = await AuthController().getGoldPrices();
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          goldPrices = response.data!;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.error?.message ?? 'Failed to load gold prices';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading gold prices: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Gold Prices',
          style: AppTheme.getAppBarTitleStyle(scaleFactor),
        ),
        backgroundColor: AppTheme.primaryOrange,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppTheme.textWhite,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                  ),
                  SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),
                  Text(
                    'Loading gold prices...',
                    style: AppTheme.getBodyStyle(scaleFactor),
                  ),
                ],
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: AppTheme.responsiveSize(AppTheme.iconXXXLarge, scaleFactor),
                        color: AppTheme.secondaryRed,
                      ),
                      SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),
                      Text(
                        'Unable to Load Data',
                        style: AppTheme.getHeaderStyle(scaleFactor).copyWith(
                          color: AppTheme.secondaryRed,
                        ),
                      ),
                      SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                      Text(
                        errorMessage!,
                        style: AppTheme.getBodyStyle(scaleFactor),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),
                      ElevatedButton(
                        onPressed: _loadGoldPrices,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: AppTheme.textWhite,
                        ),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : goldPrices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: AppTheme.responsiveSize(AppTheme.iconXXXLarge, scaleFactor),
                            color: AppTheme.textMuted,
                          ),
                          SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),
                          Text(
                            'No Gold Prices Available',
                            style: AppTheme.getHeaderStyle(scaleFactor),
                          ),
                          SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                          Text(
                            'Please try again later',
                            style: AppTheme.getBodyStyle(scaleFactor),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadGoldPrices,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                              itemCount: goldPrices.length,
                              itemBuilder: (context, index) {
                                final goldPrice = goldPrices[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                                  padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                                  decoration: AppTheme.getCardDecoration(scaleFactor),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: AppTheme.getIconCirclePadding(scaleFactor),
                                        decoration: AppTheme.getIconCircleDecoration(AppTheme.primaryOrange, scaleFactor),
                                        child: Icon(
                                          Icons.attach_money,
                                          color: AppTheme.primaryOrange,
                                          size: AppTheme.responsiveSize(AppTheme.iconLarge, scaleFactor),
                                        ),
                                      ),
                                      SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              goldPrice['title'] ?? 'Unknown Gold Type',
                                              style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                                                fontWeight: AppTheme.fontWeightBold,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
                                            Text(
                                              'Gold Standard',
                                              style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'RM ${goldPrice['gold_price'] ?? 'N/A'}/g',
                                        style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                                          fontWeight: AppTheme.fontWeightBold,
                                          color: AppTheme.primaryOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          // Information note at the bottom
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(
                              left: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor),
                              right: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor),
                              top: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor),
                              bottom: AppTheme.responsiveSize(AppTheme.spacingLarge * 4, scaleFactor),
                            ),
                            padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusMedium, scaleFactor)),
                              border: Border.all(
                                color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: AppTheme.responsiveSize(AppTheme.iconMedium, scaleFactor),
                                      color: AppTheme.primaryOrange,
                                    ),
                                    SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                                    Text(
                                      'Price Information',
                                      style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                                        fontWeight: AppTheme.fontWeightBold,
                                        color: AppTheme.primaryOrange,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                                Text(
                                  'Gold prices are sourced from BMMB (Bank Muamalat Malaysia Berhad) and are updated regularly. Prices are for reference only and may vary based on market conditions.',
                                  style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                                    color: AppTheme.textMuted,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                                SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.update,
                                      size: AppTheme.responsiveSize(AppTheme.iconSmall, scaleFactor),
                                      color: AppTheme.textMuted,
                                    ),
                                    SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor)),
                                    Text(
                                      'Last updated: ${DateTime.now().toString().split(' ')[0]}',
                                      style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                                        color: AppTheme.textMuted,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

}

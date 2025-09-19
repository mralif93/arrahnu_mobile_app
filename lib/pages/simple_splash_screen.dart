import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/session_service.dart';
import 'campaign.dart';

class SimpleSplashScreen extends StatefulWidget {
  const SimpleSplashScreen({super.key});

  @override
  State<SimpleSplashScreen> createState() => _SimpleSplashScreenState();
}

class _SimpleSplashScreenState extends State<SimpleSplashScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation.addListener(() {
      if (mounted) {
        setState(() {
          _progress = _progressAnimation.value;
        });
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Initialize session service (0-50% progress)
      await Future.any([
        SessionService().initializeSession(),
        Future.delayed(const Duration(seconds: 3)), // 3 second timeout
      ]);
      
      // Update progress to 50%
      if (mounted) {
        setState(() {
          _progress = 0.5;
        });
      }
      
      // Step 2: Simulate additional loading (50-75% progress)
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _progress = 0.75;
        });
      }
      
      // Step 3: Finalize (75-90% progress)
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() {
          _progress = 0.9;
        });
      }
      
      // Step 4: Complete to 100%
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          _progress = 1.0;
        });
      }
      
      // Wait to show 100% completion before redirecting
      await Future.delayed(const Duration(milliseconds: 800));
      
    } catch (e) {
      debugPrint('App initialization error: $e');
      // Set progress to 100% even on error
      if (mounted) {
        setState(() {
          _progress = 1.0;
        });
      }
      // Wait to show 100% completion even on error
      await Future.delayed(const Duration(milliseconds: 800));
    }
    
    // Only navigate after progress reaches 100%
    if (mounted && _progress >= 1.0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CampaignPage()),
      );
    }
  }

  String _getLoadingText() {
    if (_progress < 0.25) {
      return 'Starting app...';
    } else if (_progress < 0.5) {
      return 'Loading session...';
    } else if (_progress < 0.75) {
      return 'Preparing data...';
    } else if (_progress < 0.9) {
      return 'Finalizing...';
    } else if (_progress < 1.0) {
      return 'Almost ready...';
    } else {
      return 'Ready!';
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    
    return Scaffold(
      backgroundColor: AppTheme.primaryOrange,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryOrange,
              AppTheme.primaryOrange.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: AppTheme.responsiveSize(150, scaleFactor),
                  height: AppTheme.responsiveSize(150, scaleFactor),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.textWhite,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/splash.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                SizedBox(height: AppTheme.responsiveSize(30, scaleFactor)),
                
                // App name
                Text(
                  'BMMB Pajak Gadai-I',
                  style: AppTheme.getHeaderStyle(scaleFactor).copyWith(
                    color: AppTheme.textWhite,
                    fontSize: AppTheme.responsiveSize(24, scaleFactor),
                    fontWeight: AppTheme.fontWeightBold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: AppTheme.responsiveSize(10, scaleFactor)),
                
                // Subtitle
                Text(
                  'Sistem e-Lelong',
                  style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                    color: AppTheme.textWhite.withValues(alpha: 0.9),
                    fontSize: AppTheme.responsiveSize(16, scaleFactor),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: AppTheme.responsiveSize(40, scaleFactor)),
                
                // Progress bar
                Container(
                  width: AppTheme.responsiveSize(250, scaleFactor),
                  child: Column(
                    children: [
                      // Progress bar
                      Container(
                        height: AppTheme.responsiveSize(4, scaleFactor),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.responsiveSize(2, scaleFactor)),
                          color: AppTheme.textWhite.withValues(alpha: 0.3),
                        ),
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: AppTheme.responsiveSize(250, scaleFactor) * _progress,
                              height: AppTheme.responsiveSize(4, scaleFactor),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppTheme.responsiveSize(2, scaleFactor)),
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.textWhite,
                                    AppTheme.textWhite.withValues(alpha: 0.8),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: AppTheme.responsiveSize(12, scaleFactor)),
                      
                      // Progress percentage
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(_progress * 100).toInt()}%',
                            style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                              color: AppTheme.textWhite,
                              fontSize: AppTheme.responsiveSize(14, scaleFactor),
                              fontWeight: AppTheme.fontWeightSemiBold,
                            ),
                          ),
                          if (_progress >= 1.0) ...[
                            SizedBox(width: AppTheme.responsiveSize(8, scaleFactor)),
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.textWhite,
                              size: AppTheme.responsiveSize(16, scaleFactor),
                            ),
                          ],
                        ],
                      ),
                      
                      SizedBox(height: AppTheme.responsiveSize(8, scaleFactor)),
                      
                      // Loading text
                      Text(
                        _getLoadingText(),
                        style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                          color: AppTheme.textWhite.withValues(alpha: 0.8),
                          fontSize: AppTheme.responsiveSize(12, scaleFactor),
                        ),
                        textAlign: TextAlign.center,
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
  }
}

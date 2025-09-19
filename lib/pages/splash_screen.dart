import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/session_service.dart';
import 'campaign.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isInitializing = true;
  String _loadingText = 'Initializing your experience...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo scale and fade animation
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Text fade animation
    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    // Progress bar animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Slide animation for text
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));

    // Pulse animation for logo
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSplashSequence() async {
    try {
      debugPrint('Splash: Starting sequence');
      
      // Start logo animation
      _logoController.forward();
      debugPrint('Splash: Logo animation started');
      
      // Wait a bit then start text animation
      await Future.delayed(const Duration(milliseconds: 500));
      _textController.forward();
      debugPrint('Splash: Text animation started');
      
      // Start progress animation
      await Future.delayed(const Duration(milliseconds: 300));
      _progressController.forward();
      debugPrint('Splash: Progress animation started');
      
      // Start pulse animation
      _pulseController.repeat(reverse: true);
      debugPrint('Splash: Pulse animation started');
      
      // Set a maximum splash duration of 10 seconds
      final splashTimeout = Future.delayed(const Duration(seconds: 10));
      
      // Initialize session service with progress updates
      debugPrint('Splash: Starting initialization');
      final initialization = _initializeAppWithProgress();
      
      // Wait for either initialization to complete or timeout
      await Future.any([initialization, splashTimeout]);
      debugPrint('Splash: Initialization completed or timed out');
      
      // Stop pulse animation
      _pulseController.stop();
      
      // Wait for minimum splash time
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Navigate to main app
      debugPrint('Splash: Navigating to main app');
      _navigateToMainApp();
    } catch (e) {
      debugPrint('Splash sequence error: $e');
      // Navigate anyway after a timeout
      await Future.delayed(const Duration(milliseconds: 2000));
      _navigateToMainApp();
    }
  }

  void _navigateToMainApp() {
    debugPrint('Splash: _navigateToMainApp called, mounted: $mounted');
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
      
      debugPrint('Splash: Starting navigation to CampaignPage');
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            debugPrint('Splash: CampaignPage pageBuilder called');
            return const CampaignPage();
          },
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              ),
            );
          },
        ),
      );
      debugPrint('Splash: Navigation completed');
    } else {
      debugPrint('Splash: Widget not mounted, cannot navigate');
    }
  }

  Future<void> _initializeAppWithProgress() async {
    try {
      // Step 1: Initialize session service with timeout
      await Future.any([
        SessionService().initializeSession(),
        Future.delayed(const Duration(seconds: 5)), // 5 second timeout
      ]);
      
      // Step 2: Simulate additional app initialization
      await Future.delayed(const Duration(milliseconds: 400));
      
      // Step 3: Load app data
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Step 4: Finalize initialization
      await Future.delayed(const Duration(milliseconds: 200));
      
    } catch (e) {
      // Handle initialization errors gracefully
      debugPrint('App initialization error: $e');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    
    return Scaffold(
      backgroundColor: AppTheme.primaryOrange,
      body: GestureDetector(
        onTap: _isInitializing ? _navigateToMainApp : null,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryOrange,
                AppTheme.primaryOrange.withValues(alpha: 0.8),
                AppTheme.primaryOrange.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top spacing
                SizedBox(height: AppTheme.responsiveSize(60, scaleFactor)),
                
                // Logo section
                Expanded(
                  flex: 3,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_logoAnimation, _pulseAnimation]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoAnimation.value * _pulseAnimation.value,
                          child: Opacity(
                            opacity: _logoAnimation.value.clamp(0.0, 1.0),
                            child: Container(
                              width: AppTheme.responsiveSize(200, scaleFactor),
                              height: AppTheme.responsiveSize(200, scaleFactor),
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
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // App name and description
                Expanded(
                  flex: 2,
                  child: AnimatedBuilder(
                    animation: _textAnimation,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: Opacity(
                          opacity: _textAnimation.value.clamp(0.0, 1.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'BMMB Pajak Gadai-I',
                                style: AppTheme.getHeaderStyle(scaleFactor).copyWith(
                                  color: AppTheme.textWhite,
                                  fontSize: AppTheme.responsiveSize(28, scaleFactor),
                                  fontWeight: AppTheme.fontWeightBold,
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppTheme.responsiveSize(12, scaleFactor)),
                              Text(
                                'Ar-Rahnu Digital Platform',
                                style: AppTheme.getBodyStyle(scaleFactor).copyWith(
                                  color: AppTheme.textWhite.withValues(alpha: 0.9),
                                  fontSize: AppTheme.responsiveSize(16, scaleFactor),
                                  fontWeight: AppTheme.fontWeightMedium,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppTheme.responsiveSize(8, scaleFactor)),
                              Text(
                                'Islamic Pawnbroking Made Easy',
                                style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                                  color: AppTheme.textWhite.withValues(alpha: 0.8),
                                  fontSize: AppTheme.responsiveSize(14, scaleFactor),
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Progress section
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.responsiveSize(40, scaleFactor),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Progress bar
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return Container(
                              height: AppTheme.responsiveSize(4, scaleFactor),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.responsiveSize(2, scaleFactor),
                                ),
                                color: AppTheme.textWhite.withValues(alpha: 0.3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.responsiveSize(2, scaleFactor),
                                    ),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.textWhite,
                                        AppTheme.textWhite.withValues(alpha: 0.8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        SizedBox(height: AppTheme.responsiveSize(16, scaleFactor)),
                        
                        // Loading text
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _progressAnimation.value.clamp(0.0, 1.0),
                              child: Text(
                                _loadingText,
                                style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                                  color: AppTheme.textWhite.withValues(alpha: 0.8),
                                  fontSize: AppTheme.responsiveSize(12, scaleFactor),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Tap to skip hint
                if (_isInitializing)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppTheme.responsiveSize(20, scaleFactor)),
                    child: AnimatedOpacity(
                      opacity: _textAnimation.value.clamp(0.0, 1.0),
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        'Tap anywhere to skip',
                        style: AppTheme.getCaptionStyle(scaleFactor).copyWith(
                          color: AppTheme.textWhite.withValues(alpha: 0.7),
                          fontSize: AppTheme.responsiveSize(12, scaleFactor),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                
                // Bottom spacing
                SizedBox(height: AppTheme.responsiveSize(20, scaleFactor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
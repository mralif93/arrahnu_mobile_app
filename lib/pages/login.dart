import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/QButton.dart';
import '../components/QLogo.dart';
import '../components/QTextButton.dart';
import '../components/QTextField.dart';
import '../components/sweet_alert.dart';
import '../constant/style.dart';
import '../constant/variables.dart';
import '../theme/app_theme.dart';
import '../controllers/authorization.dart';
import '../pages/campaign.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TapGestureRecognizer _registerGestureRecognizer = TapGestureRecognizer()
    ..onTap = () async {
      Uri registerUrl = Uri.parse("${Variables.baseUrl}${Variables.signupUrl}");
      if (await canLaunchUrl(registerUrl)) {
        await launchUrl(registerUrl, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $registerUrl');
      }
    };

  final TapGestureRecognizer _forgotPasswordGestureRecognizer =
      TapGestureRecognizer()
        ..onTap = () async {
          var resetPassword = Uri.parse('${Variables.baseUrl}${Variables.passwordResetUrl}');
          if (await canLaunchUrl(resetPassword)) {
            await launchUrl(resetPassword, mode: LaunchMode.externalApplication);
          } else {
            throw Exception('Could not launch $resetPassword');
          }
        };

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  void checkSession() async {
    try {
      final res = await AuthController().session();
      if (res) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const CampaignPage()),
              (route) => false);
        }
      }
    } catch (e) {
      print('Session check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: AppTheme.textWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textWhite),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const CampaignPage()),
              (route) => false,
            );
          },
        ),
        title: Text(
          'Login',
          style: AppTheme.getAppBarTitleStyle(scaleFactor),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.responsiveSize(24, scaleFactor),
            vertical: AppTheme.responsiveSize(4, scaleFactor),
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppTheme.responsiveSize(12, scaleFactor)),

                // Logo section
                Transform.translate(
                  offset: Offset(0, AppTheme.responsiveSize(-8, scaleFactor)),
                  child: Image.asset(
                    "assets/images/pajak-orange.png",
                    width: AppTheme.responsiveSize(280, scaleFactor),
                    height: AppTheme.responsiveSize(120, scaleFactor),
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: AppTheme.responsiveSize(12, scaleFactor)),

                // Welcome text
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: AppTheme.responsiveSize(20, scaleFactor),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),

                SizedBox(height: AppTheme.responsiveSize(4, scaleFactor)),

                Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: AppTheme.responsiveSize(12, scaleFactor),
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: AppTheme.responsiveSize(24, scaleFactor)),

                // Email field
                QTextField(
                  hintText: 'Email or Username',
                  controller: _emailController,
                  obscureText: false,
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  fontSize: AppTheme.responsiveSize(12, scaleFactor),
                  fillColor: Colors.grey[50],
                  borderColor: Colors.grey[200]!,
                  focusedBorderColor: Colors.orange,
                ),

                const SizedBox(height: 20),

                // Password field
                QTextField(
                  hintText: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  icon: Icons.lock_outline,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: signUserIn,
                  fontSize: AppTheme.responsiveSize(12, scaleFactor),
                  fillColor: Colors.grey[50],
                  borderColor: Colors.grey[200]!,
                  focusedBorderColor: Colors.orange,
                ),

                SizedBox(height: AppTheme.responsiveSize(8, scaleFactor)),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: QTextButton(
                    text: 'Forgot Password?',
                    onPressed: () async {
                      try {
                        Uri resetPassword = Uri.parse('${Variables.baseUrl}${Variables.passwordResetUrl}');
                        print('Forgot Password URL: $resetPassword');
                        if (await canLaunchUrl(resetPassword)) {
                          await launchUrl(resetPassword, mode: LaunchMode.externalApplication);
                        } else {
                          print('Cannot launch forgot password URL: $resetPassword');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cannot open forgot password page. Please try again later.'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error launching forgot password URL: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error opening forgot password page: $e'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    textColor: Colors.orange[600],
                    fontSize: AppTheme.responsiveSize(12, scaleFactor),
                    fontWeight: FontWeight.w500,
                    alignment: MainAxisAlignment.end,
                  ),
                ),

                SizedBox(height: AppTheme.responsiveSize(16, scaleFactor)),

                // Sign in button
                QButton(
                  text: 'Sign In',
                  onPressed: signUserIn,
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  fontSize: AppTheme.responsiveSize(12, scaleFactor),
                  fontWeight: FontWeight.w600,
                  borderRadius: 12,
                  height: AppTheme.responsiveSize(AppTheme.buttonHeightMedium, scaleFactor),
                ),

                SizedBox(height: AppTheme.responsiveSize(16, scaleFactor)),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: AppTheme.responsiveSize(14, scaleFactor),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppTheme.responsiveSize(16, scaleFactor)),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: AppTheme.responsiveSize(12, scaleFactor),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    QTextButton(
                      text: 'Sign Up',
                      onPressed: () async {
                        try {
                          Uri registerUrl = Uri.parse("${Variables.baseUrl}${Variables.signupUrl}");
                          print('Sign Up URL: $registerUrl');
                          if (await canLaunchUrl(registerUrl)) {
                            await launchUrl(registerUrl, mode: LaunchMode.externalApplication);
                          } else {
                            print('Cannot launch sign up URL: $registerUrl');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cannot open sign up page. Please try again later.'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        } catch (e) {
                          print('Error launching sign up URL: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error opening sign up page: $e'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      textColor: Colors.orange[600],
                      fontWeight: FontWeight.w600,
                      fontSize: AppTheme.responsiveSize(12, scaleFactor),
                      alignment: MainAxisAlignment.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signUserIn() async {
    // validate input
    if (_emailController.text.isEmpty) {
      SweetAlert.error(
        title: 'Validation Error',
        message: 'Email address or Username cannot be empty',
        confirmText: 'OK',
      );
      return;
    }
    // validate password
    else if (_passwordController.text.isEmpty) {
      SweetAlert.error(
        title: 'Validation Error',
        message: 'Password cannot be empty',
        confirmText: 'OK',
      );
      return;
      // validate email and password
    } else if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      // sign user in
      try {
        final response = await AuthController().login(
            _emailController.text.toString(),
            _passwordController.text.toString());

        if (response.isSuccess) {
          // reset input
          _emailController.clear();
          _passwordController.clear();

          // Navigate to Campaign page
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CampaignPage()),
            (route) => false,
          );
        } else {
          // Display error message
          SweetAlert.error(
            title: "Login Failed",
            message: 'An unexpected error occurred. Please try logging in again. If the problem persists, please contact support.',
            confirmText: "OK",
          );
        }
      } catch (e) {
        print(e);
        SweetAlert.error(
          title: "Login Error",
          message: 'An error occurred during login. Please try again.',
          confirmText: "OK",
        );
      }
    }
  }
}
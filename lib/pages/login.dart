import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/QButton.dart';
import '../components/QLogo.dart';
import '../components/QTextField.dart';
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
        await launchUrl(registerUrl);
      } else {
        throw Exception('Could not launch $registerUrl');
      }
    };

  final TapGestureRecognizer _forgotPasswordGestureRecognizer =
      TapGestureRecognizer()
        ..onTap = () async {
          var resetPassword = Uri.parse('${Variables.baseUrl}${Variables.passwordResetUrl}');
          if (await canLaunchUrl(resetPassword)) {
            await launchUrl(resetPassword);
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
                // Logo section
                Transform.translate(
                  offset: Offset(0, AppTheme.responsiveSize(-8, scaleFactor)),
                  child: Image.asset(
                    "assets/images/muamalat_logo_01.png",
                    width: AppTheme.responsiveSize(280, scaleFactor),
                    height: AppTheme.responsiveSize(120, scaleFactor),
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: AppTheme.responsiveSize(8, scaleFactor)),

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
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(
                    fontSize: AppTheme.responsiveSize(16, scaleFactor),
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Email or Username',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: AppTheme.responsiveSize(12, scaleFactor),
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.orange,
                        width: 2,
                      ),
                    ),
                    fillColor: Colors.grey[50],
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppTheme.responsiveSize(16, scaleFactor),
                      vertical: AppTheme.responsiveSize(12, scaleFactor),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => signUserIn(),
                  style: TextStyle(
                    fontSize: AppTheme.responsiveSize(16, scaleFactor),
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Password',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: AppTheme.responsiveSize(12, scaleFactor),
                  fontWeight: FontWeight.w400,
                ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.orange,
                        width: 2,
                      ),
                    ),
                    fillColor: Colors.grey[50],
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppTheme.responsiveSize(16, scaleFactor),
                      vertical: AppTheme.responsiveSize(12, scaleFactor),
                    ),
                  ),
                ),

                SizedBox(height: AppTheme.responsiveSize(8, scaleFactor)),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      Uri resetPassword = Uri.parse('${Variables.baseUrl}${Variables.passwordResetUrl}');
                      if (await canLaunchUrl(resetPassword)) {
                        await launchUrl(resetPassword);
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontSize: AppTheme.responsiveSize(12, scaleFactor),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppTheme.responsiveSize(16, scaleFactor)),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  height: AppTheme.responsiveSize(48, scaleFactor),
                  child: ElevatedButton(
                    onPressed: signUserIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: AppTheme.responsiveSize(12, scaleFactor),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                  ),
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
                    TextButton(
                      onPressed: () async {
                        Uri registerUrl = Uri.parse("${Variables.baseUrl}${Variables.signupUrl}");
                        if (await canLaunchUrl(registerUrl)) {
                          await launchUrl(registerUrl);
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w600,
                          fontSize: AppTheme.responsiveSize(12, scaleFactor),
                        ),
                      ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Durations.extralong3,
          content: Text("Email address or Username cannot be empty"),
        ),
      );
      return;
    }
    // validate password
    else if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Durations.extralong3,
          content: Text("Password cannot be empty"),
        ),
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
          Get.defaultDialog(
            title: "Error",
            middleText: 'An unexpected error occurred. Please try login in again. If the problem persists, please contact support.',
            textConfirm: "OK",
            onConfirm: () {
              Navigator.of(context).pop();
            },
          );
        }
      } catch (e) {
        print(e);
      }
    }
  }
}
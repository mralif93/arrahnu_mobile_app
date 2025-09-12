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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo section
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/muamalat_logo_01.png",
                    width: 80,
                    height: 80,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Welcome text
              Text(
                'Welcome Back',
                style: AppTheme.getWelcomeStyle(scaleFactor),
              ),

              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),

              Text(
                'Sign in to continue',
                style: AppTheme.getCaptionStyle(scaleFactor),
              ),

              const SizedBox(height: 48),

              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Email or Username',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
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
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                ),
              ),

              const SizedBox(height: 16),

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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Sign in button
              SizedBox(
                width: double.infinity,
                height: 56,
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
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

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
                        fontSize: 14,
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

              const SizedBox(height: 32),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
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
                        fontSize: 14,
                      ),
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
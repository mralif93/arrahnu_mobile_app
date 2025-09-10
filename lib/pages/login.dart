import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/QTextField.dart';
import '../controllers/authorization.dart';
import '../pages/dashboard.dart';
import '../constant/variables.dart';
import '../constant/style.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  //  Variables
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    // Called once when the widget is created
    checkSession();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void checkSession() async {
    try {
      final res = await AuthController().session();
      if (res) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
              (route) => false);
        }
      }
    } catch (e) {
      // If session check fails, just continue to login page
      print('Session check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const SizedBox(height: 40),
              
              // Welcome section
              Column(
                children: [
                  // logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/images/muamalat_logo_01.png",
                      height: 80,
                      width: 80,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Welcome text
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Sign in to your account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Login form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      // email text field
                      TextFormField(
                        controller: _emailController,
                        cursorColor: Colors.orange,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.grey[600],
                          ),
                          hintText: 'Username or Email',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.orange,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          fillColor: Colors.grey[50],
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your username or email";
                          }
                          return null;
                        },
                      ),

                    // TextFormField(
                    //   controller: _emailController,
                    //   cursorColor: Colors.orange,
                    //   decoration: InputDecoration(
                    //     prefixIcon: const Icon(Icons.mail_outline),
                    //     hintText: 'Email Address or Username',
                    //     border: InputBorder.none,
                    //     contentPadding: const EdgeInsets.all(16),
                    //     filled: true,
                    //     fillColor: Colors.grey[200],
                    //     isDense: true,
                    //   ),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return "Please enter your email address or username";
                    //     }
                    //     return null;
                    //   },
                    // ),

                      const SizedBox(height: 20),

                      // password text field
                      TextFormField(
                        obscureText: true,
                        controller: _passwordController,
                        cursorColor: Colors.orange,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          if (_formKey.currentState!.validate()) {
                            login(_emailController.text, _passwordController.text);
                          }
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.grey[600],
                          ),
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.orange,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          fillColor: Colors.grey[50],
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your password";
                          }
                          return null;
                        },
                      ),

                    // TextFormField(
                    //   obscureText: true,
                    //   controller: _passwordController,
                    //   cursorColor: Colors.orange,
                    //   decoration: InputDecoration(
                    //     prefixIcon: const Icon(Icons.lock_outlined),
                    //     hintText: 'Password',
                    //     border: InputBorder.none,
                    //     contentPadding: const EdgeInsets.all(16),
                    //     filled: true,
                    //     fillColor: Colors.grey[200],
                    //     isDense: true,
                    //   ),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return "Please enter your password";
                    //     }
                    //     return null;
                    //   },
                    // ),

                      const SizedBox(height: 16),

                      // forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            Uri resetPassword = Uri.parse('${Variables.baseUrl}${Variables.passwordResetUrl}');
                            if (await canLaunchUrl(resetPassword)) {
                              await launchUrl(resetPassword);
                            }
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.orange[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // sign in button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isLoading ? Colors.grey[400] : Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: _isLoading ? 0 : 2,
                            shadowColor: _isLoading ? Colors.transparent : Colors.orange.withOpacity(0.3),
                          ),
                          onPressed: _isLoading ? null : () async {
                            if (_formKey.currentState!.validate()) {
                              await login(
                                  _emailController.text, _passwordController.text);
                            }
                          },
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

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

                      const SizedBox(height: 24),

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
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.orange[600],
                                fontWeight: FontWeight.bold,
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
            ],
          ),
        ),
      ),
    );
  }

  login(String username, String password) async {
    // Validate input
    if (username.trim().isEmpty) {
      _showErrorDialog('Please enter your username or email address');
      return;
    }
    
    if (password.trim().isEmpty) {
      _showErrorDialog('Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthController().login(username.trim(), password);

      setState(() {
        _isLoading = false;
      });

      if (response.isSuccess) {
        // Reset input
        _emailController.clear();
        _passwordController.clear();

        // Navigate to dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
          (route) => false,
        );
      } else {
        // Display error message
        String errorMessage = 'Login failed. Please check your credentials and try again.';
        
        if (response.error != null) {
          if (response.error!.statusCode == 401) {
            errorMessage = 'Invalid username or password. Please check your credentials and try again.';
          } else if (response.error!.statusCode == 403) {
            errorMessage = 'Account is not active. Please contact support.';
          } else if (response.error!.statusCode == 404) {
            errorMessage = 'Account not found. Please check your username and try again.';
          } else {
            errorMessage = response.error!.userMessage;
          }
        }
        
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Display error message
      _showErrorDialog('Network error. Please check your internet connection and try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[600],
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Login Failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Try Again',
              style: TextStyle(
                color: Colors.orange[600],
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

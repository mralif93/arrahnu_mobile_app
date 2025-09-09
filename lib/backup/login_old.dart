import '../components/QTextField.dart';
import '../controllers/authorization.dart';
import '../pages/dashboard.dart';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constant/variables.dart';
import '../constant/style.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //  Variables
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TapGestureRecognizer _registerGestureRecognizer = TapGestureRecognizer()
    ..onTap = () async {
      Uri registerUrl = Uri.parse("${Variables.baseUrl}/signup/");
      if (await canLaunchUrl(registerUrl)) {
        await launchUrl(registerUrl);
      } else {
        throw Exception('Could not launch $registerUrl');
      }
    };

  final TapGestureRecognizer _forgotPasswordGestureRecognizer =
      TapGestureRecognizer()
        ..onTap = () async {
          var resetPassword = Uri.parse('${Variables.baseUrl}/password/reset/');
          if (await canLaunchUrl(resetPassword)) {
            await launchUrl(resetPassword);
          } else {
            throw Exception('Could not launch $resetPassword');
          }
        };

  @override
  void initState() {
    super.initState();
    // Called once when the widget is created
    checkSession();
  }

  void checkSession() async {
    final res = await AuthController().session();
    if (res) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
          (route) => false);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset("assets/images/muamalat_logo_01.png"),
              // const SizedBox(height: 64),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // logo
                    Image.asset("assets/images/muamalat_logo_01.png"),

                    // space
                    const SizedBox(height: 16),

                    // email text field
                    QTextField(
                      hintText: 'Email Address or Username',
                      controller: _emailController,
                      obscureText: false,
                      icon: const Icon(Icons.mail_outline),
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

                    // space
                    const SizedBox(height: 15),

                    // password text field
                    QTextField(
                      hintText: 'Password',
                      controller: _passwordController,
                      obscureText: true,
                      icon: const Icon(Icons.lock_outlined),
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

                     // space
                    const SizedBox(height: 15),

                    // forgot password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                            child: RichText(
                              text: TextSpan(
                                text: 'Forgot Password?',
                                recognizer: _forgotPasswordGestureRecognizer,
                                style: StyleConstants.textStyle,
                              ),
                            )),
                      ],
                    ),

                    // sign in button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        minimumSize: const Size.fromHeight(45),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await login(
                              _emailController.text, _passwordController.text);
                        }
                      },
                      child: const Text('SIGN IN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                          )),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Don\'t have an account? ',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            TextSpan(
                              text: ' Sign Up',
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                              ),
                              recognizer: _registerGestureRecognizer,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ]),
      ),
    );
  }

  login(String username, String password) async {
    // Display Loading
    showDialog(
      context: context,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(
          color: Colors.deepOrange,
        ),
      ),
    );

    try {
      final resp = await AuthController().login(username, password);
      Map<String, dynamic> data = jsonDecode(resp.body);

      if (resp.statusCode == 200) {
        // reset input
        _emailController.clear();
        _passwordController.clear();

        //  pop the loading circle
        Navigator.of(context).pop();

        // Navigate to dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
          (route) => false,
        );
      } else {
        //  pop the loading circle
        Navigator.of(context).pop();

        // Display error message
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Unable to log in'),
            content: const Text(
                'An unexpected error occurred. Please try loggin in again. If the problem persists, please contact support.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }
}

import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/QButton.dart';
import '../components/QLogo.dart';
import '../components/QTextButton.dart';
import '../components/QTextField.dart';
import '../constant/style.dart';
import '../constant/variables.dart';
import '../controllers/authorization.dart';
import '../pages/dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
        final resp = await AuthController().login(
            _emailController.text.toString(),
            _passwordController.text.toString());
        Map<String, dynamic> data = jsonDecode(resp.body);

        if (resp.statusCode == 200) {
          // reset input
          _emailController.clear();
          _passwordController.clear();

          // Navigate to dashboard
          Get.to(const DashboardPage());
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
  void initState() {
    super.initState();
    // Called once when the widget is created
    checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            const QLogo(
              image: "assets/images/muamalat_logo_01.png",
            ),

            // space
            const SizedBox(height: 32),

            // email text field
            QTextField(
              hintText: 'Email Address or Username',
              controller: _emailController,
              icon: const Icon(Icons.mail_outline),
              obscureText: false,
            ),

            // space
            const SizedBox(height: 16),

            // password text field
            QTextField(
              hintText: 'Password',
              controller: _passwordController,
              icon: const Icon(Icons.lock_outlined),
              obscureText: true,
            ),

            // space
            const SizedBox(height: 16),

            // forgot password
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: RichText(
                      text: TextSpan(
                        text: 'Forgot Password?',
                        recognizer: _forgotPasswordGestureRecognizer,
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                ),
              ],
            ),

            // space
            const SizedBox(height: 16),

            // sign in button
            QButton(
              text: 'Sign In',
              onTap: signUserIn,
            ),

            // space
            const SizedBox(height: 16),
            
            Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Don\'t have an account? ',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: ' Sign Up',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: _registerGestureRecognizer,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final TapGestureRecognizer _registerGestureRecognizer = TapGestureRecognizer()
    ..onTap = () async {
      Uri registerUrl = Uri.parse('${Variables.baseUrl}/signup/');
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

}

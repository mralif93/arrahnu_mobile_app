import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.amber[800],
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // space
                const SizedBox(height: 80),

                //  logo
                Image.asset("assets/images/muamalat_logo_01.png", width: 400,),

                // title
                const Text(
                  'BMMB Pajak Gadai-i',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                // space
                const SizedBox(height: 30),

                // container
                Container(
                  height: 480,
                  width: 325,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // space
                      const SizedBox(height: 30),
                      // text
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                        ),
                      ),
                      // space
                      const SizedBox(height: 10),
                      // text
                      const Text(
                        'Please Login to Your Account',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      // space
                      const SizedBox(height: 20),
                      // email
                      Container(
                        width: 250,
                        child: const TextField(
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            suffixIcon: Icon(
                              Icons.mail_outline,
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 250,
                        child: const TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: Icon(
                              Icons.visibility_off_outlined,
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 40, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Forget Password?',
                              style: TextStyle(
                                color: Colors.orangeAccent[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // space
                      const SizedBox(height: 20),
                      // login button
                      GestureDetector(
                        child: Container(
                          alignment: Alignment.center,
                          width: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.orangeAccent,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // space
                      const SizedBox(height: 30),
                      // register link
                      const Text(
                        'Don\'t have account? Create new account.',
                        style: TextStyle(
                          fontSize: 12,
                        ),
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
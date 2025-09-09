import 'package:bmmb_pajak_gadai_i/pages/navigation.dart';
import 'package:flutter/material.dart';
import '../controllers/authorization.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  // Controller
  final TextEditingController oldPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  void checkSession() async {
    final res = await AuthController().session();
    if (!res) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => NavigationPage()),
          (route) => false);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMMB Pajak Gadai-i"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              child: Column(
                children: [
                  TextFormField(
                    cursorColor: Colors.indigo,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Old Password'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    cursorColor: Colors.indigo,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'New Password'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    cursorColor: Colors.indigo,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Confirm New Password'),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                ),
                onPressed: () {},
                child: const Text(
                  'SUBMIT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

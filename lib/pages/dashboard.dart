import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../components/QAvatar.dart';
import '../components/QButton.dart';
import '../components/QListTiles.dart';
import '../constant/variables.dart';
import '../controllers/authorization.dart';
import '../model/user.dart';
import 'biddings.dart';
import 'branch.dart';
import 'navigation.dart';
import 'profile.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // variables
  bool statusView = false;
  var profile = User(
    id: 0,
    idNum: '',
    fullName: '',
    address: '',
    postalCode: 0,
    city: '',
    state: '',
    country: '',
    hpNumber: 0,
    user: 0,
  );

  @override
  void initState() {
    super.initState();

    // extra
    checkSession();
    fetchProfile();
    checkBidingTime();
  }

  void checkSession() async {
    final res = await AuthController().session();
    if (!res) {
      Get.to(const NavigationPage());

      // Show snackbar
      final snackBar = SnackBar(
        content: const Text('Session Timeout!'),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
  }

  void fetchProfile() async {
    final response = await AuthController().getUserProfile();
    if (response.isSuccess && response.data != null) {
      setState(() {
        profile = response.data!;
      });
    }
  }

  void signOutUser() {
    Get.defaultDialog(
      title: 'Sign Out',
      middleText: 'Are you sure you want to sign out?',
      textConfirm: 'Yes',
      textCancel: 'No',
      onConfirm: () async {
        // signout user session
        try {
          final response = await AuthController().logout();

          // success signout
          if (response.isSuccess && response.data == true) {
            Get.offAll(const NavigationPage());
          }
        } on Exception catch (e) {
          print(e);
        }
      },
      onCancel: () {},
    );
  }

  Future checkBidingTime() async {
    // Get data from API
    var response = await http.get(Uri.parse(
        '${Variables.baseUrl}/api/v2/pages/?type=product.BranchIndexPage&fields=*'));
    if (response.statusCode == 200) {
      // Parse JSON to Dart object
      Map<String, dynamic> jsonData = jsonDecode(response.body);

      var currentDate = DateTime.now();
      var startDate =
          DateTime.parse(jsonData['items'][0]["start_bidding_session"]);
      var endDate = DateTime.parse(jsonData['items'][0]["end_bidding_session"]);

      print(startDate);
      print(endDate);
      print(currentDate.compareTo(startDate));
      print(currentDate.compareTo(endDate));

      if (currentDate.compareTo(startDate) == 1 &&
          currentDate.compareTo(endDate) == 1) {
        print('Waiting for Bidding!');
        setState(() {
          statusView = false;
        });
      } else if (currentDate.compareTo(startDate) == 1 &&
          currentDate.compareTo(endDate) == -1) {
        print('Bidding on Progress!');
        setState(() {
          statusView = true;
        });
      } else if (currentDate.compareTo(startDate) == -1 &&
          currentDate.compareTo(endDate) == -1) {
        print('Already Done Bidding!');
        setState(() {
          statusView = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 24,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              // Welcome message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.dashboard_outlined,
                      size: 48,
                      color: Colors.orange[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Colors.orange[800],
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your account and bidding activities',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // User avatar section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.orange[100],
                      backgroundImage: NetworkImage(Variables.defaultAvatarUrl),
                      child: profile.fullName.isNotEmpty
                          ? Text(
                              profile.fullName.isNotEmpty
                                  ? profile.fullName[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[800],
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.orange[600],
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.fullName.isNotEmpty ? profile.fullName : 'User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+60${profile.hpNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Menu items
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    // My Profile
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                      onTap: () {
                        Get.to(const ProfilePage());
                      },
                    ),
                    
                    Divider(
                      color: Colors.grey[200],
                      height: 1,
                      indent: 24,
                      endIndent: 24,
                    ),
                    
                    // My Bidding
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.gavel_outlined,
                          color: Colors.green[600],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'My Bidding',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                      onTap: () {
                        Get.to(const BiddingPage());
                      },
                    ),

                    if (statusView) ...[
                      Divider(
                        color: Colors.grey[200],
                        height: 1,
                        indent: 24,
                        endIndent: 24,
                      ),
                      
                      // Bidding Now
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.flash_on,
                            color: Colors.red[600],
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Bidding Now !!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                        onTap: () {
                          Get.to(const BranchPage());
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Sign out button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: signOutUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red[600],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red[200]!),
                    ),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

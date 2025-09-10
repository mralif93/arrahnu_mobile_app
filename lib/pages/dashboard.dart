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
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // my avatar
                QAvatar(
                  name: profile.fullName,
                  mobile: '+60${profile.hpNumber}',
                  image:
                      Variables.defaultAvatarUrl,
                ),

                // sQpace
                const SizedBox(height: 16),

                // my profile
                QListTiles(
                  text: 'My Profile',
                  onTap: () {
                    Get.to(const ProfilePage());
                  },
                ),

                // space
                const SizedBox(height: 16),

                // my bidding
                QListTiles(
                  text: 'My Bidding',
                  onTap: () {
                    Get.to(const BiddingPage());
                  },
                ),

                // space
                const SizedBox(height: 16),

                if (statusView)
                  // my bidding
                  QListTiles(
                    text: 'Bidding Now !!',
                    onTap: () {
                      Get.to(const BranchPage());
                    },
                  ),

                // space
                const SizedBox(height: 16),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // button sign out
                QButton(
                  text: 'Sign Out',
                  onTap: signOutUser,
                ),

                // space
                const SizedBox(height: 25),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

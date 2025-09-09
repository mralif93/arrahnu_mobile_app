import 'dart:convert';

import 'package:bmmb_pajak_gadai_i/components/QListTiles.dart';
import 'package:bmmb_pajak_gadai_i/constant/style.dart';
import 'package:bmmb_pajak_gadai_i/pages/branch.dart';
import 'package:bmmb_pajak_gadai_i/pages/navigation.dart';
import 'package:flutter/material.dart';
import '../model/user.dart';
import '../pages/profile.dart';
import '../pages/biddings.dart';
import '../controllers/authorization.dart';
import '../constant/variables.dart';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
      user: 0);

  bool statusView = false;

  @override
  void initState() {
    super.initState();
    checkSession();
    fetchProfile();
    checkBidingTime();
  }

  void checkSession() async {
    final res = await AuthController().session();
    if (!res) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => NavigationPage()),
          (route) => false);

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
    final res = await AuthController().getUserProfile();
    setState(() {
      profile = res;
    });
    // print("Failed to fetch profile!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMMB Pajak Gadai-i',
            style: StyleConstants.textHeaderStyle),
      ),
      body: RefreshIndicator(
          onRefresh: _refresh,
          strokeWidth: 3,
          color: Colors.orangeAccent,
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              Column(
                children: [
                  // profile picture
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 4,
                        color: Colors.white,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.1),
                        )
                      ],
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            'https://cdn1.iconfinder.com/data/icons/user-pictures/100/unknown-514.png'),
                      ),
                    ),
                  ),

                  // space
                  const SizedBox(height: 16),

                  // text
                  Text(
                    profile.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // text
                  Text(
                    '+60${profile.hpNumber}',
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),

                  // space
                  const SizedBox(height: 16),

                  // my profile
                  QListTiles(
                    text: 'My Profile',
                    onTap: () {},
                  ),

                  // space
                  const SizedBox(height: 16),

                  // my profile
                  QListTiles(
                    text: 'My Bidding',
                    onTap: () {},
                  ),

                  // space
                  const SizedBox(height: 16),

                  ListTile(
                    title: const Text('My Profile'),
                    tileColor: Theme.of(context).colorScheme.onPrimary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                    leading: const Icon(Icons.person_outline_outlined),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),

                  // my bidding
                  ListTile(
                    title: const Text('My Bidding'),
                    tileColor: Theme.of(context).colorScheme.onPrimary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BiddingPage(),
                        ),
                      );
                    },
                    leading: const Icon(Icons.price_check_outlined),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      if (statusView)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const BranchPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Start Bidding Now!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          // minimumSize: const Size.fromHeight(45),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (ctx) =>
                                  // Alert
                                  AlertDialog(
                                    title: const Text("Confirm Sign Out"),
                                    content:
                                        const Text("Are you sure to sign out?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('CANCEL'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await logout();
                                        },
                                        child: const Text('OK'),
                                      )
                                    ],
                                  ));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Future _refresh() {
    checkBidingTime();
    checkSession();

    return Future.delayed(
      const Duration(seconds: 1),
    );
  }

  logout() async {
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
      final res = await AuthController().logout();

      //  pop the loading circle
      Navigator.of(context).pop();

      if (res) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => NavigationPage()),
          (route) => false,
        );
      }
    } catch (e) {
      print(e.toString());
    }
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

      return jsonData;
    } else {
      // throw exception
      throw Exception('Failed to load Bid Info');
    }
  }
}

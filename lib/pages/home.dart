import 'package:bmmb_pajak_gadai_i/pages/branch.dart';
import 'package:bmmb_pajak_gadai_i/pages/calculator.dart';
import 'package:bmmb_pajak_gadai_i/pages/features.dart';
import 'package:bmmb_pajak_gadai_i/pages/prices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../constant/variables.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var height = 0.0, width = 0.0;
  List items = [];
  List products = [];
  List branches = [];
  bool statusView = false;

  final _images = [
    "assets/images/product_features.png",
    "assets/images/gold_price.png",
    "assets/images/calculator.png",
    "assets/images/auction.png",
  ];

  @override
  void initState() {
    super.initState();

    checkBidingTime();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: height / 6,
                width: width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Material(
                      color: Colors.white,
                      elevation: 4,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const FeaturesPage()));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                  color: Colors.deepOrangeAccent, width: 3),
                              shape: BoxShape.circle,
                            ),
                            child:
                                Image.asset(_images[0], height: 80, width: 80),
                          )),
                    ),
                    Material(
                      color: Colors.white,
                      elevation: 4,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PricesPage()));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                  color: Colors.deepOrangeAccent, width: 3),
                              shape: BoxShape.circle,
                            ),
                            child:
                                Image.asset(_images[1], height: 80, width: 80),
                          )),
                    ),
                    Material(
                      color: Colors.white,
                      elevation: 4,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CalculatorPage()));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                  color: Colors.deepOrangeAccent, width: 3),
                              shape: BoxShape.circle,
                            ),
                            child:
                                Image.asset(_images[2], height: 80, width: 80),
                          )),
                    ),
                    if (statusView)
                      Material(
                        color: Colors.white,
                        elevation: 4,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const BranchPage()));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                    color: Colors.deepOrangeAccent, width: 3),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(_images[3],
                                  height: 80, width: 80),
                            )),
                      ),
                  ],
                ),
              ),
              Container(
                  height: height / 1.5,
                  width: width,
                  child: FutureBuilder(
                    future: fetchBiddingInfo(),
                    builder: (context, snapshot) {
                      List<Widget> children = [];

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show Loading
                        EasyLoading.instance
                          ..indicatorType =
                              EasyLoadingIndicatorType.fadingCircle
                          ..loadingStyle = EasyLoadingStyle.dark;
                        EasyLoading.show(status: 'Please wait');
                      } else if (snapshot.hasError) {
                        // Dismiss Loading
                        EasyLoading.dismiss();
                        final error = snapshot.error.toString();
                        children = <Widget>[
                          Center(child: Text(error)),
                        ];
                      } else if (snapshot.hasData) {
                        // Dismiss Loading
                        EasyLoading.dismiss();

                        final data = snapshot.data;
                        final startBidding =
                            DateTime.parse(data[0]["start_bidding_session"])
                                .toLocal();
                        final endBidding =
                            DateTime.parse(data[0]["end_bidding_session"])
                                .toLocal();

                        children = <Widget>[
                          const Text('Sistem e-Lelong (Pajak Gadai-i)',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text('Ar-Rahnu Online Auction System',
                              style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 30),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Bidding Session Start at:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Text(DateFormat('EEEE').format(startBidding)),
                              const SizedBox(height: 5),
                              Text(DateFormat('dd/MM/yyyy hh:mm a')
                                  .format(startBidding)),
                              const SizedBox(height: 15),
                              const Text('Bidding Session End at:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Text(DateFormat('EEEE').format(endBidding)),
                              const SizedBox(height: 5),
                              Text(DateFormat('dd/MM/yyyy hh:mm a')
                                  .format(endBidding)),
                            ],
                          ),
                        ];
                      } else {
                        // Dismiss Loading
                        EasyLoading.dismiss();
                        children = <Widget>[
                          const Center(child: Text('Good!')),
                        ];
                      }

                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: children,
                        ),
                      );
                    },
                  )),
            ],
          ),
        ));
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

  Future fetchBiddingInfo() async {
    // Get data from API
    var response = await http.get(Uri.parse(
        '${Variables.baseUrl}/api/v2/pages/?type=product.BranchIndexPage&fields=*'));
    if (response.statusCode == 200) {
      // Parse JSON to Dart object
      Map<String, dynamic> jsonData = jsonDecode(response.body);

      return jsonData['items'];
    }

    throw Exception('Failed to load data!');
  }
}

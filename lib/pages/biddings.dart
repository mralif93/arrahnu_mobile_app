import 'dart:convert';
import 'package:bmmb_pajak_gadai_i/constant/style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/bidding.dart';
import '../pages/navigation.dart';
import '../controllers/authorization.dart';

class BiddingPage extends StatefulWidget {
  const BiddingPage({super.key});

  @override
  State<BiddingPage> createState() => _BiddingPageState();
}

class _BiddingPageState extends State<BiddingPage> {
  // variable
  late var biddingsData = [];

  // variable to call and store future list of biddings
  Future<List<Bidding>> biddingsFuture = getBiddings();
  // function to fetch data from api and return future list of biddings
  static Future<List<Bidding>> getBiddings() async {
    final response = await AuthController().getUserBidding();
    if (response.isSuccess && response.data != null) {
      return response.data!.map((e) => Bidding.fromJson(e)).toList();
    }
    return [];
  }

  // get matching ID for title page
  Future getAccountBiddings() async {
    final response1 = await AuthController().getUserBidding();
    final response2 = await AuthController().getBiddingAccounts();
    
    if (!response1.isSuccess || !response2.isSuccess) {
      return;
    }
    
    var jsonData1 = response1.data!;
    var jsonData2 = response2.data!;

    if (jsonData1.length > 0) {
      for (var k = 0; k < jsonData1.length; k++) {
        if (jsonData2.length > 0) {
          for (var i = 0; i < jsonData2.length; i++) {
            if (jsonData1[k]['product'] == jsonData2[i]['id']) {
              jsonData1[k]['title'] = jsonData2[i]['title'];
            }
          }
        }
      }

      setState(() {
        biddingsData = jsonData1;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkSession();
    getAccountBiddings();
  }

  // check session
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
          title: const Text("BMMB Pajak Gadai-i",
              style: StyleConstants.textHeaderStyle),
        ),
        body: Center(
          child: FutureBuilder<List<Bidding>>(
            future: biddingsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // until data is fetchedm show loader
                return const CircularProgressIndicator();
              } else if (snapshot.hasData && biddingsData.isNotEmpty) {
                // once data is fetched, display it on screen (call buildBiddinds())
                // final biddings = snapshot.data!;
                return buildBiddings();
              } else {
                // if no data, show simple text
                return const Text("No data available");
              }
            },
          ),
        ));
  }

  // function to display fetched data on screen
  Widget buildBiddings() {
    return ListView.builder(
        itemCount: biddingsData.length,
        itemBuilder: (context, index) {
          final bid = biddingsData[index];
          return Column(
            children: [
              if (index == 0) const Divider(),
              ListTile(
                title: Text(
                  "${bid['title']}",
                  textAlign: TextAlign.end,
                  style: StyleConstants.text12BoldStyle,
                ),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text("Reserved Price (RM) : ${bid['reserved_price']}",
                          style: StyleConstants.textStyle),
                      Text("Bid Price (RM) : ${bid['bid_offer']}",
                          style: StyleConstants.textStyle),
                      Text(
                        "Created : ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(bid['created_at']).toLocal())}",
                        style: StyleConstants.dateTimeStyle,
                      ),
                    ]),
              ),
              const Divider(),
            ],
          );
        });
  }
}

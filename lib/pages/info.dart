import 'package:bmmb_pajak_gadai_i/pages/details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/variables.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  // Data Variables
  List collections = [];

  // Style
  final textHeaderStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  final titleStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 16,
  );

  final subtitleStyle = const TextStyle(
    fontWeight: FontWeight.normal,
    color: Colors.white,
    fontSize: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMMB Pajak Gadai-i', style: textHeaderStyle),
      ),
      body: FutureBuilder(
        future: fetchBiddingDetails(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
              itemCount: snapshot.data.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailsPage(
                                data: collections,
                                name: snapshot.data[index],
                              )),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(height: 0);
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Not Found Data'));
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future fetchBiddingDetails() async {
    // get data from API
    var response =
        await http.get(Uri.parse('${Variables.baseUrl}/api/collateral/'));
    if (response.statusCode == 200) {
      //  declare variables
      List branches = [];

      // Parse JSON to Dart object
      final jsonData = json.decode(response.body);

      collections = jsonData;

      // getting list of branches
      for (var i = 0; i < jsonData.length; i++) {
        if (!branches.contains(jsonData[i]['page']['branch']['title'])) {
          branches.add(jsonData[i]['page']['branch']['title']);
        }
      }

      // sorting
      branches.sort();

      // return list
      return branches;
    } else {
      // throw exception
      throw Exception('Failed to load Bid Info');
    }
  }
}

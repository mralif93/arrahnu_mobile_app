import 'package:bmmb_pajak_gadai_i/pages/collateral.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailsPage extends StatelessWidget {
  final List data;
  final String name;
  const DetailsPage({super.key, required this.data, required this.name});

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
    Future fetchData() async {
      //  declare variables
      final List dataCompile = [];
      final List accounts = [];
      var totalCollateral = 0;
      var totalOriginalPrice = 0.0;
      var totalDiscountedPrice = 0.0;
      var totalReservedPrice = 0.0;

      // get account number
      for (var i in data) {
        if (i['page']['branch']['title'] == name) {
          if (!accounts.contains(i['page']['acc_num'])) {
            accounts.add(i['page']['acc_num']);
          }
        }
      }

      for (var x in accounts) {
        totalCollateral = 0;
        totalOriginalPrice = 0.0;
        totalDiscountedPrice = 0.0;
        totalReservedPrice = 0.0;

        for (var i in data) {
          if (x == i['page']['acc_num']) {
            totalOriginalPrice += i['fullPrice'];
            totalDiscountedPrice += i['discount'];
            totalReservedPrice += i['priceAfterDiscount'];
            totalCollateral += 1;
          }
        }

        var f = NumberFormat('###,###,###.00', 'en_Us');
        dataCompile.add({
          'acc_num': x,
          'totalCollateral': totalCollateral,
          'totalOriginalPrice': f.format(totalOriginalPrice),
          'totalDiscountedPrice': f.format(totalDiscountedPrice),
          'totalReservedPrice': f.format(totalReservedPrice),
        });
      }

      // combine
      return dataCompile;
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(name, style: textHeaderStyle),
        ),
        body: FutureBuilder(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final items = snapshot.data;
                return ListView.separated(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Account Number: ${item['acc_num']}",
                              style: const TextStyle(fontSize: 14)),
                          Text(
                              "Number of Collateral: ${item['totalCollateral']}",
                              style: const TextStyle(fontSize: 14)),
                          Text(
                              "Total Original Price (RM): ${item['totalOriginalPrice']}",
                              style: const TextStyle(fontSize: 14)),
                          Text(
                              "Total Discount Price (RM): ${item['totalDiscountedPrice']}",
                              style: const TextStyle(fontSize: 14)),
                          Text(
                              "Total Reserved Price (RM): ${item['totalReservedPrice']}",
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CollateralPage(
                                    collections: data,
                                    branch: name,
                                    account: item['acc_num'],
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
            }));
  }
}

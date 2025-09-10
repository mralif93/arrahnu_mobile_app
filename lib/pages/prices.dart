import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/variables.dart';
import '../controllers/authorization.dart';

class PricesPage extends StatefulWidget {
  const PricesPage({super.key});

  @override
  State<PricesPage> createState() => _PricesPageState();
}

class _PricesPageState extends State<PricesPage> {
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
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: goldPrices(),
          builder: (context, snapshot) {
            List<Widget> children = [];

            if (snapshot.hasData) {
              // Dismiss Loading
              EasyLoading.dismiss();

              final data = snapshot.data;
              children = <Widget>[
                ListView.separated(
                  itemCount: data.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final goldPrice = data[index];
                    return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gold Standard: ${goldPrice['title']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        leading: const Icon(Icons.attach_money_outlined),
                        trailing: Text('RM ${goldPrice['gold_price']}/g'));
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(height: 1);
                  },
                ),
                const Divider(height: 1),
              ];
            } else if (snapshot.hasError) {
              // Dismiss Loading
              EasyLoading.dismiss();

              children = <Widget>[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}'),
                ),
              ];
            } else {
              // Show Loading
              EasyLoading.instance
                ..indicatorType = EasyLoadingIndicatorType.fadingCircle
                ..loadingStyle = EasyLoadingStyle.dark;
              EasyLoading.show(status: 'Please wait');

              children = const <Widget>[];
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ),
            );
          },
        ),
      ),
    );
  }

  Future goldPrices() async {
    final response = await AuthController().getGoldPrices();
    
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    
    throw Exception(response.error?.userMessage ?? Variables.failedLoadBidInfoText);
  }
}

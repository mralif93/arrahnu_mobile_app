import 'dart:convert';

import 'package:bmmb_pajak_gadai_i/controllers/authorization.dart';
import 'package:bmmb_pajak_gadai_i/pages/gallery.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' as html_parser;

import '../constant/variables.dart';

class CollateralPage extends StatefulWidget {
  final List collections;
  final String branch;
  final String account;

  const CollateralPage(
      {super.key,
      required this.collections,
      required this.branch,
      required this.account});

  @override
  State<CollateralPage> createState() => _CollateralPageState();
}

class _CollateralPageState extends State<CollateralPage> {
  // Data Variables
  var statusLogin = false;
  final controller = CarouselController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _inputController = TextEditingController();

  List dataCompile = [];
  List uBiddings = [];
  var profile;
  var totalImage = '';
  var totalCollateral = 0;
  var totalOriginalPrice = 0.0;
  var totalDiscountedPrice = 0.0;
  var totalReservedPrice = 0.0;

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

  Future futureAccountDetails() async {
    //  variables
    final List accounts = [];

    // fetch account number
    for (var i in widget.collections) {
      if (i['page']['branch']['title'] == widget.branch) {
        if (i['page']['acc_num'] == widget.account) {
          accounts.add(i);
        }
      }
    }

    for (var account in accounts) {
      final List images = [];
      final document = html_parser.parseFragment('''${account['images']}''');
      final anchors = document.querySelectorAll('img');
      for (final anchor in anchors) {
        final src = anchor.attributes['src'];
        images.add('${Variables.baseUrl}$src');
      }
      // reassign images url
      account['images_path'] = images;

      // find user biddings
      // if (statusLogin) {
      // final response = await AuthController().getUserBidding();
      // var uBid = jsonDecode(response);
      // print(uBid);

      //   for (var u in uBid) {
      //     if (u['product'].toString() == account['page']['id'].toString()) {
      //       uBiddings.add(u);
      //     }
      //   }
      // }
    }

    dataCompile = [];
    totalImage = '';
    totalCollateral = 0;
    totalOriginalPrice = 0.0;
    totalDiscountedPrice = 0.0;
    totalReservedPrice = 0.0;

    for (var x in accounts) {
      totalImage = x['page']['account_image']['url'];
      totalOriginalPrice += x['fullPrice'];
      totalDiscountedPrice += x['discount'];
      totalReservedPrice += x['priceAfterDiscount'];
      totalCollateral += 1;
    }

    var f = NumberFormat('###,###,###.00', 'en_Us');
    dataCompile.add({
      'totalImage': totalImage,
      'totalCollateral': totalCollateral,
      'totalOriginalPrice': f.format(totalOriginalPrice),
      'totalDiscountedPrice': f.format(totalDiscountedPrice),
      'totalReservedPrice': f.format(totalReservedPrice),
      '_totalReservedPrice': totalReservedPrice,
    });

    return accounts;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkSession();
  }

  void checkSession() async {
    final res = await AuthController().session();
    if (res) {
      setState(() {
        statusLogin = true;
      });

      getBiddings();
      var data = await AuthController().getUserProfile();
      setState(() {
        profile = data;
      });
    } else {
      setState(() {
        statusLogin = false;
      });

      // Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(builder: (context) => NavigationPage()),
      //     (route) => false);
      // return;
    }
  }

  Future getBiddings() async {
    final response = await AuthController().getUserBidding();
    var jsonData = jsonDecode(response);

    //  variables
    final List accounts = [];

    // fetch account number
    for (var i in widget.collections) {
      if (i['page']['branch']['title'] == widget.branch) {
        if (i['page']['acc_num'] == widget.account) {
          accounts.add(i);
        }
      }
    }

    for (var account in accounts) {
      for (var u in jsonData) {
        if (u['product'].toString() == account['page']['id'].toString()) {
          uBiddings.add(u);
        }
      }
    }

    return uBiddings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account, style: textHeaderStyle),
      ),
      body: Column(
        children: [
          FutureBuilder(
              future: futureAccountDetails(),
              builder: (context, snapshot) {
                List<Widget> children = [];
                if (snapshot.hasData) {
                  final data = snapshot.data;
                  children = [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GalleryPage(
                                    account: widget.account,
                                    collections: widget.collections,
                                    branch: widget.branch)));
                      },
                      child: Image.network(
                        '${Variables.baseUrl}/${dataCompile[0]['totalImage']}',
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.orange,
                                    ),
                                  ),
                        height: 350,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Original Price:'),
                            Text('Discount Price:'),
                            Text('Reserved Price:'),
                            Text('Number of Gold:'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('RM ${dataCompile[0]['totalOriginalPrice']}'),
                            Text(
                                'RM ${dataCompile[0]['totalDiscountedPrice']}'),
                            Text('RM ${dataCompile[0]['totalReservedPrice']}'),
                            Text('${dataCompile[0]['totalCollateral']}'),
                          ],
                        ),
                      ],
                    ),
                    if (statusLogin) const SizedBox(height: 16),
                    if (uBiddings.isNotEmpty && statusLogin)
                      buildTable(dataCompile),
                    const SizedBox(height: 16),
                    if (uBiddings.isEmpty && statusLogin)
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                              cursorColor: Colors.orange,
                              controller: _inputController,
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some value';
                                }

                                if (double.parse(value) <=
                                    dataCompile[0]['_totalReservedPrice']) {
                                  return 'Value must be greater than Reserved Price!';
                                }
                                return null;
                              },
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.black,
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.orange,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2)),
                                ),
                              ),
                              onPressed: () async {
                                // It returns true if the form is valid, otherwise returns false
                                if (_formKey.currentState!.validate()) {
                                  // print(dataCompile[0]['_totalReservedPrice']);
                                  // print(_inputController.text);
                                  // print(data[0]['page']['id']);
                                  var productId = data[0]['page']['id'];
                                  var originalPrice =
                                      dataCompile[0]['_totalReservedPrice'];
                                  var bidPrice =
                                      double.parse(_inputController.text);
                                  final res = await AuthController()
                                      .submitUserBid(
                                          productId, originalPrice, bidPrice);
                                  if (res) {
                                    // If the form is valid, display a Snackbar.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Successfully submit bid price.')),
                                    );
                                  } else {
                                    // If the form is valid, display a Snackbar.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Failed submit bid price.')),
                                    );
                                  }
                                }
                              },
                              child: const Text('Submit'),
                            )
                          ],
                        ),
                      ),
                  ];
                } else if (snapshot.hasError) {
                  children = [
                    const Center(child: Text('Not Found Data')),
                  ];
                } else {
                  children = [
                    const CircularProgressIndicator(),
                  ];
                }
                return Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        children: children,
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget buildImage(String url) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.fitWidth,
          ),
          color: Colors.grey,
        ),
      );

  Widget buildTable(List data) => Center(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Table(
            border: TableBorder.all(color: Colors.white30),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                  ),
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Date', textAlign: TextAlign.center),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child:
                            Text('Bid Price (RM)', textAlign: TextAlign.center),
                      ),
                    ),
                  ]),
              for (var u in uBiddings)
                buildRow([
                  DateFormat('dd/MM/yyyy hh:mm a')
                      .format(DateTime.parse(u['created_at']).toLocal()),
                  u['bid_offer'].toString(),
                ]),
            ],
          ),
        ),
      );

  TableRow buildRow(List<String> cells) => TableRow(
        children: cells.map((cell) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Center(child: Text(cell)),
          );
        }).toList(),
      );
}

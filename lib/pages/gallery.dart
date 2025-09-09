import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import '../constant/variables.dart';

class GalleryPage extends StatelessWidget {
  final List collections;
  final String branch;
  final String account;
  const GalleryPage(
      {super.key,
      required this.collections,
      required this.branch,
      required this.account});

  @override
  Widget build(BuildContext context) {
    // Controller
    final controller = CarouselSliderController();

    // Style
    const textHeaderStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    Future fetchCollections() async {
      //  variables
      final List accounts = [];

      // fetch account number
      for (var i in collections) {
        if (i['page']['branch']['title'] == branch) {
          if (i['page']['acc_num'] == account) {
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
      }

      return accounts;
    }

    Widget buildImage(String url) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.cover,
            ),
            color: Colors.grey,
          ),
          height: 350,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(account, style: textHeaderStyle),
      ),
      body: FutureBuilder(
          future: fetchCollections(),
          builder: (context, snapshot) {
            List<Widget> children = [];

            if (snapshot.hasData) {
              final data = snapshot.data;
              children = [
                Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // buildImage(item['images_path'][index]),
                            CarouselSlider.builder(
                              carouselController: controller,
                              options: CarouselOptions(
                                // initialPage: 0,
                                // autoPlayCurve: Curves.fastOutSlowIn,
                                // aspectRatio: 2.0,
                                enlargeCenterPage: true,
                                // enableInfiniteScroll: false,
                              ),
                              itemCount: item['images_path'].length,
                              itemBuilder: ((context, index, realIndex) {
                                final image = item['images_path'][index];
                                return buildImage(image);
                              }),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Gold Weight: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Gold Type: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Gold Standard: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${item['gold_weight']}/g'),
                                    Text('${item['gold_type']['title']}'),
                                    Text('${item['gold_standard']['title']}'),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(height: 2);
                    },
                    itemCount: data.length,
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

            return Column(
              children: children,
            );
          }),
    );
  }
}

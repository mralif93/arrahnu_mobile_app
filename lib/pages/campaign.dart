import "package:flutter/material.dart";
import "package:carousel_slider/carousel_slider.dart";
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../components/QCard.dart';
import '../constant/variables.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({super.key});

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  // Variables
  final _controller = CarouselSliderController();
  int _activeIndex = 0;
  List items = [
    {
      "id": 8,
      "title": "Ar-Rahnu, Islamic Pawn Broking (Tawarruq)",
      "description":
          "Benefits of Ar-Rahnu:\r\n\r\n1) Fully-Shariah compliant product\r\n2) Free from Riba’ (usury) and Gharar (uncertainty)\r\n3) Fixed Profit Rate on the financing amount\r\n4) No early redemption charges\r\n5) High margin of advance\r\n6) Fast, easy and secure\r\n7) Gold cleaning service\r\n8) Improve customer experience by providing convenient online Ar-Rahnu revaluation transaction without present at BMMB premise.\r\n9) Accept gold bullion (bar/coins/dinar) for pawning without opening the seal (15 selected branches only).",
      "image":
          "https://arrahnuauction.muamalat.com.my/media/announcement/Ar_Rahnu_Promotion_Deal_8.99-01.jpg",
      "datetime_created": "2023-12-05T17:23:00.258276+08:00",
      "datetime_modified": "2023-12-05T22:53:03.033911+08:00",
      "is_active": true,
      "is_default": true,
      "staff": 1981,
      "created_by": 1981,
      "updated_by": 1981
    },
    {
      "id": 9,
      "title": "Ar-Rahnu, Islamic Pawn Broking (Tawarruq)",
      "description":
          "Benefits of Ar-Rahnu:\r\n\r\n1) Fully-Shariah compliant product\r\n2) Free from Riba’ (usury) and Gharar (uncertainty)\r\n3) Fixed Profit Rate on the financing amount\r\n4) No early redemption charges\r\n5) High margin of advance\r\n6) Fast, easy and secure\r\n7) Gold cleaning service\r\n8) Improve customer experience by providing convenient online Ar-Rahnu revaluation transaction without present at BMMB premise.\r\n9) Accept gold bullion (bar/coins/dinar) for pawning without opening the seal (15 selected branches only).",
      "image":
          "https://arrahnuauction.muamalat.com.my/media/announcement/Ar_Rahnu_Promotion_Deal_0.75-03.jpg",
      "datetime_created": "2023-12-05T17:23:34.395019+08:00",
      "datetime_modified": "2023-12-05T17:33:48.750587+08:00",
      "is_active": true,
      "is_default": false,
      "staff": 1981,
      "created_by": 1981,
      "updated_by": 1981
    }
  ];

  @override
  void initState() {
    super.initState();
    fetchPoster();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Card components
            QCard(
              title: Variables.text1,
              subtitle: Variables.text2,
            ),
            
            // space
            const SizedBox(height: 20),

            // slider components
            Padding(
              padding:
                  const EdgeInsets.only(top: 10),
              child: Center(
                  child: Column(
                children: [
                  CarouselSlider.builder(
                    carouselController: _controller,
                    options: CarouselOptions(
                      height: 500,
                      initialPage: 0,
                      autoPlay: true,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      aspectRatio: 2.0,
                      // enlargeFactor: 0.3,
                      enlargeCenterPage: true,
                      // enlargeStrategy: CenterPageEnlargeStrategy.height,
                      autoPlayInterval: const Duration(seconds: 2),
                      onPageChanged: (index, reason) => {
                        setState(() => _activeIndex = index),
                      },
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index, realIndex) {
                      return buildImage(items[index]['image'], index);
                    },
                  ),
                  const SizedBox(height: 20),
                  buildIndicator(),
                  // buildButtons(),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchPoster() async {
    try {
      final response =
          await http.get(Uri.parse('${Variables.baseUrl}/api/announcement/'));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          items = jsonData['results'];
        });
      } else {
        throw Exception('Failed to load Poster Info');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Widget buildImage(String url, int index) => Container(
        // margin: const EdgeInsets.symmetric(horizontal: 12),
        // color: Colors.grey,
        // child: Image.network(url, fit: BoxFit.fitWidth),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.fitWidth,
          ),
          color: Colors.grey,
        ),
      );

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: _activeIndex,
        count: items.length,
        onDotClicked: animateToSlide,
        effect: const JumpingDotEffect(
          dotWidth: 10,
          dotHeight: 10,
          activeDotColor: Colors.orange,
          dotColor: Colors.black12,
        ),
      );

  Widget buildButtons({bool stretch = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: previous,
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          stretch ? const Spacer() : const SizedBox(width: 25),
          ElevatedButton(
            onPressed: next,
            child: const Icon(Icons.arrow_forward, size: 20),
          ),
        ],
      );

  void animateToSlide(int index) => _controller.animateToPage(index);
  void next() =>
      _controller.nextPage(duration: const Duration(microseconds: 500));
  void previous() =>
      _controller.previousPage(duration: const Duration(microseconds: 500));
}

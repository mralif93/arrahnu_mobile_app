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
      "title": Variables.campaignTitle1,
      "description": Variables.campaignDescription1,
      "image": Variables.promotionImage1,
      "datetime_created": Variables.campaignDatetimeCreated1,
      "datetime_modified": Variables.campaignDatetimeModified1,
      "is_active": true,
      "is_default": true,
      "staff": Variables.campaignStaffId,
      "created_by": Variables.campaignCreatedBy,
      "updated_by": Variables.campaignUpdatedBy
    },
    {
      "id": 9,
      "title": Variables.campaignTitle1,
      "description": Variables.campaignDescription1,
      "image": Variables.promotionImage2,
      "datetime_created": Variables.campaignDatetimeCreated2,
      "datetime_modified": Variables.campaignDatetimeModified2,
      "is_active": true,
      "is_default": false,
      "staff": Variables.campaignStaffId,
      "created_by": Variables.campaignCreatedBy,
      "updated_by": Variables.campaignUpdatedBy
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

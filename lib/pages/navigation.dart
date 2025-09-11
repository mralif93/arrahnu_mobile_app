import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/style.dart';
import '../pages/campaign.dart';
import '../pages/home.dart';
import '../pages/account.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Go directly to campaign page
    return const CampaignPage();
  }
}

class NavigationPageWithAccountTab extends StatelessWidget {
  const NavigationPageWithAccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Go directly to campaign page
    return const CampaignPage();
  }
}

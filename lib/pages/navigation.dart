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
    final controller = Get.put(NavigationController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BMMB Pajak Gadai-i',
          style: StyleConstants.textHeaderStyle,
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.class_outlined),
              label: 'Campaigns',
            ),
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined),
              label: 'Account',
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

class NavigationPageWithAccountTab extends StatelessWidget {
  const NavigationPageWithAccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    // Set the selected index to Account tab (index 2)
    controller.selectedIndex.value = 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BMMB Pajak Gadai-i',
          style: StyleConstants.textHeaderStyle,
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.class_outlined),
              label: 'Campaigns',
            ),
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined),
              label: 'Account',
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const CampaignPage(),
    const HomePage(),
    const AccountPage(),
  ];
}

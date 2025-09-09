import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import '../pages/navigation.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BMMB Pajak Gadai-i",
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const NavigationPage(),
      builder: EasyLoading.init(),
    );
  }
}

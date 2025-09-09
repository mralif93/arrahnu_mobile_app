import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../constant/variables.dart';

// Declare variables
const url = "ar-rahnu-calculator";

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // WebView
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(onProgress: (int progress) {
        print("URL Progress $progress!");
      }, onPageStarted: (String url) {
        EasyLoading.instance
          ..indicatorType = EasyLoadingIndicatorType.fadingCircle
          ..loadingStyle = EasyLoadingStyle.dark;
        EasyLoading.show(status: 'Please wait');
      }, onPageFinished: (String url) {
        EasyLoading.dismiss();
      }))
      ..loadRequest(Uri.parse('${Variables.baseUrl}/$url/'));
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ArRahnu Calculator'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

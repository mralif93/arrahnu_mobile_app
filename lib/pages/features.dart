import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../constant/variables.dart';

class FeaturesPage extends StatefulWidget {
  const FeaturesPage({super.key});

  @override
  State<FeaturesPage> createState() => _FeaturesPageState();
}

class _FeaturesPageState extends State<FeaturesPage> {
  // Declare variables
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
      ..loadRequest(Uri.parse('${Variables.mainUrl}/${Variables.url}/'));
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Features'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

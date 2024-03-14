import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings =
      InAppWebViewSettings(isInspectable: kDebugMode);
  PullToRefreshController? pullToRefreshController;
  PullToRefreshSettings pullToRefreshSettings = PullToRefreshSettings(
    color: Colors.blue,
  );
  bool pullToRefreshEnabled = true;

  @override
  void initState() {
    super.initState();
//for onesignal
    initOnesignal();
//ok good1
    // Pulltorefresh
    initwebview();
  }

  initOnesignal() {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize('2a65a5a8-84f4-4c9a-9417-8e5fe30542d2');
    OneSignal.Notifications.requestPermission(true).then((value) {
      print('signal value: $value');
    });
    // OneSignal.initialize('bc582a37-96c6-4fcc-8c80-d0e5d5724c62');
  }

  initwebview() {
    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: pullToRefreshSettings,
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        body: Column(children: <Widget>[
          Expanded(
              child: InAppWebView(
            key: webViewKey,
            initialUrlRequest:
                URLRequest(url: WebUri("https://readings.com.pk/")),
            initialSettings: settings,
            pullToRefreshController: pullToRefreshController,
            onWebViewCreated: (InAppWebViewController controller) {
              webViewController = controller;
            },
            onLoadStop: (controller, url) {
              pullToRefreshController?.endRefreshing();
            },
            onReceivedError: (controller, request, error) {
              pullToRefreshController?.endRefreshing();
            },
            onProgressChanged: (controller, progress) {
              if (progress == 100) {
                pullToRefreshController?.endRefreshing();
              }
            },
          )),
        ]));
  }
}

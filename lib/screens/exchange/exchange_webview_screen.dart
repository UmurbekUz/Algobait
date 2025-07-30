import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ExchangeWebViewScreen extends StatefulWidget {
  final String initialUrl;

  const ExchangeWebViewScreen({Key? key, required this.initialUrl}) : super(key: key);

  @override
  _ExchangeWebViewScreenState createState() => _ExchangeWebViewScreenState();
}

class _ExchangeWebViewScreenState extends State<ExchangeWebViewScreen> {
  InAppWebViewController? _webViewController;
  double _progress = 0;
  final String _redirectUri = 'https://algobait.com/oauth/callback';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подключение к бирже'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_progress > 0.0 ? 6.0 : 0.0),
          child: _progress > 0.0 && _progress < 1.0
              ? LinearProgressIndicator(value: _progress)
              : const SizedBox.shrink(),
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
            javaScriptEnabled: true,
          ),
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true,
          ),
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onLoadStart: (controller, url) {
          if (url != null && url.toString().startsWith(_redirectUri)) {
            final code = url.queryParameters['code'];
            if (code != null && code.isNotEmpty) {
              print('Successfully captured auth code: $code');
              Navigator.of(context).pop(code);
            } else {
              print('Redirected with no code or an error: ${url.queryParameters['error']}');
              Navigator.of(context).pop();
            }
            _webViewController?.stopLoading();
          }
        },
        onProgressChanged: (controller, progress) {
          setState(() {
            _progress = progress / 100;
          });
        },
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
        },
        onLoadError: (controller, url, code, message) {
            print("WebView onLoadError: $message (code: $code)");
        },
        onLoadHttpError: (controller, url, statusCode, description) {
            print("HTTP error: $statusCode - $description");
        },
      ),
    );
  }
}

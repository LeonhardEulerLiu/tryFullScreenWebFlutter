import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class browser extends StatefulWidget {
  const browser({this.url});
  final String url;

  @override
  _browserState createState() => _browserState();
}

class _browserState extends State<browser> {
  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    print(widget.url);
    return Scaffold(
      body: SafeArea(
        child: WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          NavigationControls(_controller.future),
          const SizedBox(height: 30),
          FloatingActionButton(
            heroTag: '2',
            onPressed: ()=>Navigator.pop(context),
            child: Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return FloatingActionButton(
          onPressed: !webViewReady
              ? null
              : () => navigate(context, controller, goBack: true),
          child: Icon(Icons.arrow_back),
        );
      },
    );
  }

  navigate(BuildContext context, WebViewController controller,
      {bool goBack: false}) async {
    bool canNavigate =
    goBack ? await controller.canGoBack() : await controller.canGoForward();
    if (canNavigate) {
      goBack ? controller.goBack() : controller.goForward();
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
            content: Text("已至首页")),
      );
    }
  }
}
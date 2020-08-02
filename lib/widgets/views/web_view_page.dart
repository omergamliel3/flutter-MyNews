import 'package:flutter/material.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();

  // Class Attributes
  final String url;
  final String title;

  // Constuctor
  WebViewPage({@required this.url, @required this.title});
}

class _WebViewPageState extends State<WebViewPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WebviewScaffold(
        bottomNavigationBar: BottomAppBar(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: [Colors.white, Colors.grey])),
              height: MediaQuery.of(context).size.height * 0.07,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'BACK TO',
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.black),
                  ),
                  SizedBox(width: 8.0),
                  Image.asset(
                    'Assets/images/splash-logo.png',
                    width: 30,
                    height: 30,
                  )
                ],
              ),
            ),
          ),
        ),
        url: widget.url,
        displayZoomControls: true,
        geolocationEnabled: true,
        withZoom: true,
      ),
    );
  }
}

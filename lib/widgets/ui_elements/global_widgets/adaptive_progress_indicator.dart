import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveProgressIndicator extends StatefulWidget {
  @override
  _AdaptiveProgressIndicatorState createState() =>
      _AdaptiveProgressIndicatorState();
}

  // adjust the Widget Indicator to the system platform
class _AdaptiveProgressIndicatorState extends State<AdaptiveProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? CupertinoActivityIndicator()
        : CircularProgressIndicator();
  }
}

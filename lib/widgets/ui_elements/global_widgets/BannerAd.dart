import 'package:flutter/material.dart';

import 'package:admob_flutter/admob_flutter.dart';

import 'package:MyNews/shared/keys.dart';

// create smart banner ad

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({
    Key key,
  }) : super(key: key);

  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AdmobBanner(
        adUnitId: bannerAdID, adSize: AdmobBannerSize.MEDIUM_RECTANGLE);
  }
}

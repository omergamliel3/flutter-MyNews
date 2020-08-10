import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:share/share.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:MyNews/widgets/views/web_view_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:MyNews/models/news.dart';
import 'package:MyNews/models/article.dart';

import 'package:MyNews/scoped-models/main.dart';
import 'package:MyNews/helpers/custom_extentions.dart';

import 'package:MyNews/services/custom_services.dart';
import 'package:MyNews/services/db_service.dart';
//import 'package:MyNews/services/admob_service.dart';
import 'package:MyNews/services/mail_service.dart';
import 'package:MyNews/services/prefs_service.dart';

import 'package:MyNews/shared/global_values.dart';

import 'package:MyNews/widgets/ui_elements/news_widgets/cloudOverlay.dart';
import 'package:MyNews/widgets/ui_elements/news_widgets/save_button.dart';

// NewsCard Widget Class //

class NewsCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewsCardState();

  // Class Attributes
  final News news;
  final MainModel model;
  final int pageIndex;

  // Constructor
  NewsCard(this.news, this.model, this.pageIndex);
}

class _NewsCardState extends State<NewsCard>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // StreamController
  final StreamController<void> _doubleTapImageEvents =
      StreamController.broadcast();

  TextDirection _textDirection;
  Alignment _alignment;
  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    if (widget.news.textDir == 'ltr') {
      _textDirection = TextDirection.ltr;
      _alignment = Alignment.topLeft;
    } else {
      _textDirection = TextDirection.rtl;
      _alignment = Alignment.topRight;
    }

    super.initState();
  }

  // Called when this object is removed from the tree permanently.
  @override
  void dispose() {
    // dispose controllers
    _doubleTapImageEvents.close();
    super.dispose();
  }

  // build Source text widget
  Widget _buildAutorSource() {
    String published = widget.news.publishedAt.getTimeAgo();
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(left: 15),
      child: Text(
        '${widget.news.source} \u{2022} $published',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
            fontSize: 11),
      ),
    );
  }

  // title container widget
  Widget _buildTitle() {
    return Container(
      alignment: _alignment,
      child: Directionality(
        textDirection: _textDirection,
        child: Text(widget.news.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
      ),
      margin: EdgeInsets.only(left: 15, right: 15),
    );
  }

  // save, share, more options buttons row widget
  Widget _buildButtonsRow() {
    String shareTitle = 'Check this article:\n\n';
    return Row(
      children: <Widget>[
        SaveButton(
          widget.model,
          widget.news,
          triggerAnimationStream: _doubleTapImageEvents.stream,
        ),
        SizedBox(
          width: 10,
        ),
        // Share button
        IconButton(
          tooltip: 'Share',
          icon: Icon(
            Icons.share,
            color: Theme.of(context).accentColor,
          ),
          onPressed: () => Share.share(shareTitle + widget.news.url),
        ),
        Spacer(),
        _buildPopupMenuButton()
      ],
    );
  }

  // build fade in image (asset to network)
  Widget _buildFadeInImage(
      {double targetHeightFactor, double targetWidthFactor}) {
    // Media query height, width calculations
    Size size = MediaQuery.of(context).size;
    double deviceHeight = size.height;
    double deviceWidth = size.width;
    double targetHeight = deviceHeight * targetHeightFactor;
    double targetWidth = deviceWidth * targetWidthFactor;

    return Container(
        padding: EdgeInsets.zero,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: FadeInImage.assetNetwork(
              height: targetHeight,
              width: targetWidth,
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 500),
              placeholder: loadingImageAsset,
              image: widget.news.urlToImage,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  placeHolderAsset,
                  height: targetHeight,
                  width: targetWidth,
                  fit: BoxFit.cover,
                );
              },
            )));
  }

  // build PopupMenuButton widget method
  PopupMenuButton _buildPopupMenuButton() {
    return PopupMenuButton(
      tooltip: 'More',
      icon: Icon(Icons.more_vert),
      padding: EdgeInsets.zero,
      elevation: 4.0,
      itemBuilder: (context) => <PopupMenuEntry>[
        PopupMenuItem(
            value: 0,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Row(
                children: <Widget>[
                  Icon(Icons.web),
                  SizedBox(width: 10.0),
                  Text('Full article')
                ],
              ),
            )),
        PopupMenuItem(
            value: 1,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Row(
                children: <Widget>[
                  Icon(Icons.launch),
                  SizedBox(width: 10.0),
                  Text('Go to ${widget.news.source}')
                ],
              ),
            )),
        PopupMenuItem(
            value: 2,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Row(
                children: <Widget>[
                  Icon(Icons.remove_circle),
                  SizedBox(width: 10.0),
                  Text('Hide articles from ${widget.news.source}')
                ],
              ),
            )),
        PopupMenuDivider(),
        PopupMenuItem(
            value: 3,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Row(
                children: <Widget>[
                  Icon(Icons.report_problem),
                  SizedBox(width: 10.0),
                  Text('Report an issue')
                ],
              ),
            )),
      ],
      onSelected: (index) {
        if (index == 0) {
          // launch news url in WebView
          _openInWebView(widget.news.url, widget.news.title);
        } else if (index == 1) {
          String sourceUrl =
              widget.news.url.substring(0, widget.news.url.indexOf('/', 10));
          _openInWebView(sourceUrl, widget.news.source);
        } else if (index == 2) {
          // add hideen source to prefs
          Prefs.addHiddenSource(widget.news.source, widget.model);
          // show snackbar
          _showSnackBar();
        } else if (index == 3) {
          // convert widget to image and share via email
          convertWidgetToImage();
        }
      },
    );
  }

  // press favorites method
  void _pressFavorite() async {
    bool isFavorite = DBservice.isSaved(widget.news.url);
    bool complete;

    if (!isFavorite) {
      complete = await DBservice.addArticle(Article(
          url: widget.news.url,
          urlToImage: widget.news.urlToImage,
          date: widget.news.publishedAt,
          source: widget.news.source,
          textDirection: widget.news.textDir,
          title: widget.news.title));

      if (!complete) {
        Fluttertoast.showToast(
            msg: 'Can\'t save article',
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT);
        return;
      }

      // notify UI update
      widget.model.callNotifyListeners();
    }

    // show overlay animation on the stack
    _doubleTapImageEvents.sink.add(null);
  }

  // open url in WebViewPage
  Future<Null> _openInWebView(String url, String title) async {
    // if canLaunch url
    if (!await Connectivity.internetConnectivity()) {
      Fluttertoast.showToast(
        msg: 'There is no internet connection',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );

      return;
    }
    if (await canLaunch(url)) {
      //AdMobHelper.showRandomInterstitialAd();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => WebViewPage(
                title: title,
                url: url,
              )));
      // failed to launch url, showSnackBar
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to launch url',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  // convert wiget to image.
  // save image file in device directory
  void convertWidgetToImage() async {
    // find key render object
    RenderRepaintBoundary renderRepaintBoundary =
        _globalKey.currentContext.findRenderObject();
    // convert RenderRepaintBoundary to image
    ui.Image image = await renderRepaintBoundary.toImage(pixelRatio: 1);
    // convert image to byteData with png imageByteFormat
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    // get application documents directory path
    final directory = (await getExternalStorageDirectory()).path;

    if (directory == null) {
      MailHelper.sentIssue();
    }
    // set the image file
    File imgFile = new File(
        '$directory/screenshot${DateTime.now().millisecondsSinceEpoch}.png');
    // save pngBytes to image file path

    try {
      await imgFile.writeAsBytes(pngBytes);
      Fluttertoast.showToast(
        msg: 'Screenshot saved to storage directory',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      MailHelper.sentIssue(screenshotPath: imgFile.path);
    } catch (e) {
      print(e);
    }
  }

  // show snack bar method
  void _showSnackBar() {
    var snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 3000),
        content: Text(
          'Restore hidden sources in Settings',
        ),
        action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              // remove hidden source from prefs
              Prefs.removeLastHiddenSource(widget.model);
            }));

    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(
      key: _globalKey,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onDoubleTap: () => _pressFavorite(),
                    onTap: () =>
                        _openInWebView(widget.news.url, widget.news.title),
                    child: Column(
                      children: <Widget>[
                        _buildFadeInImage(
                          targetHeightFactor: 0.25,
                          targetWidthFactor: 0.95,
                        ),
                        SizedBox(height: 10.0),
                        _buildAutorSource(),
                        SizedBox(height: 10.0),
                        _buildTitle(),
                        SizedBox(height: 10.0)
                      ],
                    ),
                  ),
                  _buildButtonsRow(),
                ],
              )),
          // Save Overlay Animator widget
          CloudOverlayAnimator(
            triggerAnimationStream: _doubleTapImageEvents.stream,
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:MyNews/shared/global_values.dart';

class ImageBuilder extends StatefulWidget {
  // Class Attributes
  final String imageUrl;
  final BorderRadius borderRadius;
  final double targetHeightFactor;
  final double targetWidthFactor;
  final bool mini;

  // Constructor
  ImageBuilder(
    this.imageUrl,
    this.borderRadius, {
    this.targetHeightFactor = 0.3,
    this.targetWidthFactor = 0.8,
    this.mini = false,
  });

  @override
  _ImageBuilderState createState() => _ImageBuilderState();
}

class _ImageBuilderState extends State<ImageBuilder>
    with AutomaticKeepAliveClientMixin {
  double targetWidth;
  double targetHeight;
  Uint8List imageBytesData;
  Widget displayWidget;
  bool showFirstChild = true;

  // Called when this object is inserted into the tree.
  @override
  void initState() {
    if (widget.imageUrl != placeHolderAsset) {
      fetchImageHandler();
    }
    super.initState();
  }

  // This method is also called immediately after [initState].
  @override
  void didChangeDependencies() {
    setTargetWidthAndHeight();
    displayWidget = _buildLoadingImage();
    super.didChangeDependencies();
  }

  void dispose() {
    super.dispose();
  }

  // handle display image widgets change
  fetchImageHandler() async {
    http.Response response;
    Widget newWidget;
    try {
      response = await http.get(widget.imageUrl);
      if (mounted && context != null) {
        if (response.statusCode != 200 && response.statusCode != 201 ||
            response.bodyBytes == null) {
          newWidget = _buildPlaceHolderImage();
        } else {
          imageBytesData = response.bodyBytes;
          newWidget = _buildImageMemory();
        }
      }
    } catch (e) {
      print(e);
      newWidget = _buildPlaceHolderImage();
    }

    setState(() {
      displayWidget = newWidget;
    });
  }

  // set target width and height parameters
  void setTargetWidthAndHeight() {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    if (widget.mini) {
      targetHeight = 100;
      targetWidth = 100;
    } else {
      // MediaQuery portrait / landscape mode adjustments
      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        targetHeight = deviceHeight * widget.targetHeightFactor;
      } else {
        targetHeight = deviceHeight * (widget.targetHeightFactor + 0.15);
      }

      targetWidth = deviceWidth * widget.targetWidthFactor;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedSwitcher(
        child: displayWidget, duration: Duration(milliseconds: 500));
  }

  Widget _buildImageMemory() {
    return Container(
        key: ValueKey(0),
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: Image.memory(
            imageBytesData,
            fit: BoxFit.cover,
            height: targetHeight,
            width: targetWidth,
            errorBuilder: (context, object, error) {
              return _buildPlaceHolderImage();
            },
          ),
        ));
  }

  Widget _buildPlaceHolderImage() {
    return Container(
        key: ValueKey(1),
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: Image.asset(
            'Assets/images/placeHolder.jpg',
            fit: BoxFit.cover,
            height: targetHeight,
            width: targetWidth,
          ),
        ));
  }

  Widget _buildLoadingImage() {
    return Container(
      key: ValueKey(2),
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: Image.asset(
          'Assets/images/loading.jpg',
          fit: BoxFit.cover,
          height: targetHeight,
          width: targetWidth,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

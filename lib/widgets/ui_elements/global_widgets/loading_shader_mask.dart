import 'package:flutter/material.dart';

class LoadingShaderMask extends StatefulWidget {
  @override
  _LoadingShaderMaskState createState() => _LoadingShaderMaskState();

  // Class Attributes
  final double targetWidth;
  final double targetHeight;

  // Constructor
  LoadingShaderMask({this.targetWidth, @required this.targetHeight});
}

class _LoadingShaderMaskState extends State<LoadingShaderMask>
    with SingleTickerProviderStateMixin {
  // Animation attributes
  AnimationController _controller;
  Animation<Color> animationOne;
  Animation<Color> animationTwo;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    animationOne = ColorTween(begin: Colors.grey, end: Colors.grey[900])
        .animate(_controller);
    animationTwo = ColorTween(begin: Colors.grey, end: Colors.grey[900])
        .animate(_controller);
    _controller.forward();
    _controller.addListener(() {
      if (_controller.status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (_controller.status == AnimationStatus.dismissed) {
        _controller.forward();
      }
      this.setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.circular(8.0);
    return ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
                  colors: [animationOne.value, animationTwo.value])
              .createShader(rect);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  borderRadius: borderRadius, color: Colors.white),
              width: double.infinity,
              height: widget.targetHeight * 0.6,
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  borderRadius: borderRadius, color: Colors.white),
              width: 50,
              height: 10,
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  borderRadius: borderRadius, color: Colors.white),
              width: double.infinity,
              height: 10,
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  borderRadius: borderRadius, color: Colors.white),
              width: double.infinity,
              height: 10,
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  borderRadius: borderRadius, color: Colors.white),
              width: double.infinity,
              height: 10,
            ),
          ],
        ));
  }
}

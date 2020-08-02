import 'package:flutter/material.dart';

class CloudOverlayAnimator extends StatefulWidget {
  final Stream<void> triggerAnimationStream;

  CloudOverlayAnimator({@required this.triggerAnimationStream});

  @override
  _CloudOverlayAnimatorState createState() => _CloudOverlayAnimatorState();
}

class _CloudOverlayAnimatorState extends State<CloudOverlayAnimator>
    with SingleTickerProviderStateMixin {
  AnimationController _cloudController;
  Animation<double> _cloudAnimation;

  @override
  void initState() {
    super.initState();
    final quick = const Duration(milliseconds: 500);
    final scaleTween = Tween(begin: 0.0, end: 1.0);
    _cloudController = AnimationController(duration: quick, vsync: this);
    _cloudAnimation = scaleTween.animate(
      CurvedAnimation(
        parent: _cloudController,
        curve: Curves.elasticOut,
      ),
    );
    _cloudController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _cloudController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.decelerate,
        );
      }
    });

    widget.triggerAnimationStream.listen((_) {
      _cloudController
        ..reset()
        ..forward();
    });
  }

  @override
  void dispose() {
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _cloudAnimation,
      child: Icon(Icons.bookmark, size: 80.0, color: Colors.grey[100]),
    );
  }
}

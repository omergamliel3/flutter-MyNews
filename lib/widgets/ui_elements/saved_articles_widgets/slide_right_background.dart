import 'package:MyNews/scoped-models/main.dart';
import 'package:flutter/material.dart';

class SlideRightBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: MainModel.of(context).isDark
              ? Colors.grey[900]
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(0.0)),
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Text(
              "Share ",
              style: TextStyle(
                  //color: Colors.white,
                  ),
              textAlign: TextAlign.left,
            ),
            Icon(
              Icons.share,
              //  color: Colors.white,
            )
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}

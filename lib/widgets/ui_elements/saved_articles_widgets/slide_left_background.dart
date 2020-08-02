import 'package:MyNews/scoped-models/main.dart';
import 'package:flutter/material.dart';

class SlideLeftBackground extends StatelessWidget {
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              //color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                  // color: Colors.white,
                  ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }
}

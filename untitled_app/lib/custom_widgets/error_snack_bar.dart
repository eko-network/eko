import 'package:flutter/material.dart';
import '../utilities/constants.dart' as c;

showSnackBar(
    {String text = "", int time = 1500, required BuildContext context}) {
  final width = c.widthGetter(context);
  //final height = MediaQuery.sizeOf(context).height;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      width: width *0.5,
      backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      content: Text(
        text,
        style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface),
      ),
      duration: Duration(milliseconds: time),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 8,
      ),
      behavior: SnackBarBehavior.floating,
      // margin: EdgeInsets.only(
      //     bottom: height * 0.1, left: width * 0.3, right: width * 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
  );
}

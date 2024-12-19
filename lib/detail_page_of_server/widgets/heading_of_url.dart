import 'package:flutter/material.dart';

Padding headingOfUrL() {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Align(
      alignment: Alignment.topLeft,
      child: Text(
        'URL:',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
      ),
    ),
  );
}

import 'package:flutter/material.dart';

Container glowOfCard({required Widget cardFunction}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.blueAccent.withOpacity(0.2),
          blurRadius: 6,
          spreadRadius: 1,
        ),
      ],
    ),
    child: cardFunction,
  );
}

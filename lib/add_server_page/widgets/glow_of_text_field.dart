//  color: const Color(0xFF2B313D),

import 'package:flutter/material.dart';

Container glowOfTextField({required Widget cardFunction}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF2B313D),
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

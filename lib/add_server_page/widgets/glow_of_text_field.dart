//  color: const Color(0xFF2B313D),

import 'package:flutter/material.dart';

Container glowOfTextField(BuildContext context,
    {required Widget cardFunction}) {
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2B313D)
          : const Color(0xFFF5F5F5),
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

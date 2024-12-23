import 'package:flutter/material.dart';
import '../detail_page_vm.dart';

Padding paddingOfCards(
    {required DetailPageVM viewModel, required Container glowOfCard}) {
  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: glowOfCard);
}

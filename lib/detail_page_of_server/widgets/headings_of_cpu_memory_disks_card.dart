import 'package:flutter/material.dart';
import '../detail_page_vm.dart';

Padding headingOfCpuMemoryAndDisksCards( {
    required DetailPageVM viewModel, required String textOfHeading}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Align(
      alignment: Alignment.topLeft,
      child: Row(
        children: [
          Text(
            textOfHeading,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const Spacer(),
          viewModel.serverModel == null
              ? const Text(
                  '-',
                )
              : Text(
                  '${viewModel.serverModel!.cpu.loadPercentage}%',
                  style: const TextStyle(fontSize: 16),
                )
        ],
      ),
    ),
  );
}

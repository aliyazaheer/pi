import 'package:flutter/material.dart';

import '../detail_page_vm.dart';

Card memoryCard(BuildContext context, DetailPageVM viewModel) {
  return Card(
    elevation: 10,
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2B313D)
        : const Color(0xFFF5F5F5),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Container(
            height: 35,
            width: double.infinity,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 61, 65, 74),
                borderRadius: BorderRadius.circular(6)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: viewModel.getMemoryUsage(),
              child: Container(
                decoration: BoxDecoration(
                    color: viewModel.getMemoryUsage() > 0.8
                        ? Colors.red
                        : const Color(0xFF41A3FF),
                    borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Row(
              children: [
                RichText(
                    text: TextSpan(
                  children: [
                    const TextSpan(
                        text: 'Used: ',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    viewModel.serverModel == null
                        ? const TextSpan(
                            text: '-',
                          )
                        : TextSpan(
                            text:
                                '${((viewModel.serverModel!.memory.total) / 103741824).round()} GB',
                          )
                  ],
                )),
                const Spacer(),
                RichText(
                    text: TextSpan(
                  children: [
                    const TextSpan(
                        text: 'Total: ',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    viewModel.serverModel == null
                        ? const TextSpan(
                            text: '-',
                          )
                        : TextSpan(
                            text:
                                '${((viewModel.serverModel!.memory.used) / 103741824).round()} GB',
                          )
                  ],
                )),
              ],
            ),
          )
        ],
      ),
    ),
  );
}

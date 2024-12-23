import 'package:flutter/material.dart';
import '../detail_page_vm.dart';

Card disksCard(BuildContext context, DetailPageVM viewModel) {
  viewModel.index = 0;
  return Card(
    elevation: 10,
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF222832)
        : const Color(0xFFF5F5F5),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Column(
            children: viewModel.serverModel == null
                ? [const Text('-')]
                : viewModel.serverModel!.disk.map((disk) {
                    double diskUsage =
                        viewModel.getDiskUsage(disk.used, disk.total);
                    viewModel.index++;
                    debugPrint("+++++++++++disk usage $diskUsage");
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 2),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Text('Disk ${viewModel.index}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                disk.disk,
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Container(
                                  height: 35,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color.fromARGB(
                                              255, 61, 65, 74)
                                          : const Color.fromARGB(
                                              255, 172, 177, 187),
                                      borderRadius: BorderRadius.circular(6)),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: diskUsage,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color:
                                              viewModel.getMemoryUsage() > 0.8
                                                  ? Colors.red
                                                  : const Color(0xFF41A3FF),
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    RichText(
                                        text: TextSpan(
                                      children: [
                                        TextSpan(
                                            text: 'Used: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? const Color(0xFFF5F5F5)
                                                    : const Color(0xFF222832))),
                                        viewModel.serverModel == null
                                            ? const TextSpan(
                                                text: '-',
                                              )
                                            : TextSpan(
                                                text:
                                                    '${((disk.used) / 103741824).round()} GB',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? const Color(
                                                            0xFFF5F5F5)
                                                        : const Color(
                                                            0xFF222832)))
                                      ],
                                    )),
                                    const Spacer(),
                                    RichText(
                                        text: TextSpan(
                                      children: [
                                        TextSpan(
                                            text: 'Total: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? const Color(0xFFF5F5F5)
                                                    : const Color(0xFF222832))),
                                        viewModel.isLoading ||
                                                viewModel.serverModel == null
                                            ? const TextSpan(
                                                text: '-',
                                              )
                                            : TextSpan(
                                                text:
                                                    '${((disk.total) / 103741824).round()} GB',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? const Color(
                                                            0xFFF5F5F5)
                                                        : const Color(
                                                            0xFF222832)))
                                      ],
                                    )),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
          ),
        ],
      ),
    ),
  );
}

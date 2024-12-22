import 'package:flutter/material.dart';
import '../detail_page_vm.dart';
import 'bar_chart_of_cpu.dart';

Widget cpuCard(BuildContext context, DetailPageVM viewModel) {
  return Card(
    elevation: 10,
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2B313D)
        : const Color(0xFFF5F5F5),
    child: Column(
      children: [
        Row(
          children: [
            Flexible(
              flex: 1,
              child: SizedBox(
                height: 300,
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: viewModel.serverModel == null
                        ? const Center(
                            child: Text(
                            'Loading...',
                            style: TextStyle(color: Color(0xFF41A3FF)),
                          ))
                        : barChartOfCpu(context,viewModel)),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 14),
          child: Row(
            children: [
              RichText(
                  text: TextSpan(
                children: [
                  const TextSpan(
                      text: 'Usage: ',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  viewModel.serverModel == null
                      ? const TextSpan(
                          text: '-',
                        )
                      : TextSpan(
                          text: viewModel.serverModel!.cpu.currentLoad,
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
                          text: viewModel.serverModel!.cpu.totalLoad.toString(),
                        )
                ],
              ))
            ],
          ),
        )
      ],
    ),
  );
}

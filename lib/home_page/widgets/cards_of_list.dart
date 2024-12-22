import 'package:flutter/material.dart';
import '../../common_widgets/average_of_disks_percentage.dart';
import '../home_vm.dart';
import 'popup_menu_button.dart';

Card cardsOfList(HomeVM viewModel, int index, BuildContext context) {
  return Card(
    elevation: 10,
    color:  Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF222832)
        : const Color(0xFFF5F5F5),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  height: 14,
                  width: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: viewModel.isLoading
                        ? Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFF5F5F5)
                            : const Color(0xFF2B313D)
                        : viewModel.serverModel == null
                            ? Colors.red
                            : Colors.green,
                  )),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  viewModel.serverDetails[index].serverName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              popUpMenuButtonFunction(context, viewModel, index)
            ],
          ),
          Row(
            children: [
              const Icon(Icons.link),
              const SizedBox(width: 10),
              Text(viewModel.serverDetails[index].serverUrl),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    viewModel.serverModel?.cpu.loadPercentage ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const Text("CPU"),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  Text(viewModel.serverModel?.memory.percentage ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  const Text("Memory"),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  if (viewModel.serverModel != null)
                    Text(
                        '${findingAverageOfDisksPercentages(viewModel.serverModel!)}%',
                        style: const TextStyle(fontWeight: FontWeight.w900))
                  else
                    const Text(
                      '-',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  const Text("Disk"),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  Text(viewModel.serverModel?.uptime ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  const Text("Up Since"),
                ],
              ),
            ],
          )
        ],
      ),
    ),
  );
}

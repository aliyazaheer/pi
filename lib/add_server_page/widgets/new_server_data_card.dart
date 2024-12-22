import 'package:flutter/material.dart';

import '../../common_widgets/average_of_disks_percentage.dart';
import '../add_server_vm.dart';

Widget newServerDataCard(BuildContext context, AddServerVM viewModel) {
  return Card(
    elevation: 10,
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF222832)
        : const Color(0xFFF5F5F5),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              viewModel.isUp
                  ? Container(
                      height: 14,
                      width: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green,
                      ))
                  : Container(
                      height: 14,
                      width: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.red,
                      )),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  viewModel.serverName.isNotEmpty ? viewModel.serverName : "-",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.link),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  viewModel.serverUrl.isNotEmpty ? viewModel.serverUrl : "-",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Column(
                children: [
                  if (viewModel.isLoading)
                    const Center(
                      child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          )),
                    )
                  else if (viewModel.serverModel != null)
                    Text(
                      viewModel.serverModel?.cpu.loadPercentage ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    )
                  else
                    const Text(
                      '-',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  const Text("CPU"),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  if (viewModel.isLoading)
                    const Center(
                      child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          )),
                    )
                  else if (viewModel.serverModel != null)
                    Text(viewModel.serverModel?.memory.percentage ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w900))
                  else
                    const Text(
                      '-',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  const Text("Memory"),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  if (viewModel.isLoading)
                    const Center(
                      child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          )),
                    )
                  else if (viewModel.serverModel != null)
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
                  if (viewModel.isLoading)
                    const Center(
                      child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          )),
                    )
                  else if (viewModel.serverModel != null)
                    Text(viewModel.serverModel?.uptime ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w900))
                  else
                    const Text(
                      '-',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
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

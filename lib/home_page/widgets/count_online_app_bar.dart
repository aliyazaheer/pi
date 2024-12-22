import 'package:flutter/material.dart';
import '../home_vm.dart';

Row countOnlineOfAppBar(BuildContext context, HomeVM viewModel) {
  return Row(
    children: [
      Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: viewModel.isLoading
                ? Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF222832)
                    : const Color(0xFFF5F5F5)
                : viewModel.isRed
                    ? Colors.red
                    : Colors.green,
          )),
      const SizedBox(
        width: 5,
      ),
      Text(
          '${viewModel.onlineServers} of ${viewModel.totalServers} Online - ${viewModel.counter == 0 ? viewModel.isLoading == false && viewModel.serverModel != null ? viewModel.justNow : '' : viewModel.countSec}',
          style: const TextStyle(fontSize: 10))
    ],
  );
}

import 'package:flutter/material.dart';
import '../home_vm.dart';

Row countOnlineOfAppBar(HomeVM viewModel) {
  return Row(
    children: [
      Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: viewModel.isLoading
                ? Colors.white
                : viewModel.isRed
                    ? Colors.red
                    : Colors.green,
          )),
      const SizedBox(
        width: 5,
      ),
      Text(
          '${viewModel.countOnline} of ${viewModel.serverDetails.length} Online - 5 secs ago',
          style: const TextStyle(fontSize: 10))
    ],
  );
}

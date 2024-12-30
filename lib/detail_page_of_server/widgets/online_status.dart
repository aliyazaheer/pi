import 'package:flutter/material.dart';
import '../detail_page_vm.dart';

Row onlineStatus(DetailPageVM viewModel, BuildContext context) {
  return Row(
    children: [
      Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: viewModel.isLoading
                ? Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFF5F5F5)
                    : const Color(0xFF222832)
                : viewModel.serverModel == null
                    ? Colors.red
                    : Colors.green,
          )),
      const SizedBox(
        width: 5,
      ),
      Text(viewModel.serverModel == null ? 'Offline' : 'Online',
          style: const TextStyle(fontSize: 10))
    ],
  );
}

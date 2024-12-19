import 'package:flutter/material.dart';

import '../../models/server_details.dart';
import '../add_server_vm.dart';

FloatingActionButton floatingGetServerButton(
    AddServerVM viewModel, BuildContext context) {
  return FloatingActionButton(
    backgroundColor: const Color(0xFF41A3FF),
    shape: const CircleBorder(eccentricity: 0.0),
    onPressed: () {
      if (viewModel.serverModel == null) {
        // Fluttertoast.showToast(
        //   msg: "No server details to add",
        // );
        return;
      }
      Navigator.pop(
          context,
          ServerDetails(
              serverName: viewModel.serverName,
              serverUrl: viewModel.serverUrl));
    },
    child: const Icon(
      Icons.done,
      size: 36,
    ),
  );
}

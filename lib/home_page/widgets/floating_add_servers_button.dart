import 'package:flutter/material.dart';
import '../../add_server_page/add_server_vu.dart';
import '../../shared_pref/shared_pref.dart';
import '../../models/server_details.dart';
import '../home_vm.dart';

FloatingActionButton floatingAddServerButton(
    BuildContext context, HomeVM viewModel) {
  return FloatingActionButton(
    backgroundColor: const Color(0xFF41A3FF),
    foregroundColor: const Color(0xFFF5F5F5),
    shape: const CircleBorder(eccentricity: 0.0),
    onPressed: () async {
      final result = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => const AddServerVU()));
      if (result != null && result is ServerDetails) {
        await viewModel.addServerDetails(result);
        await SharedPref.saveServerDetailsList(viewModel.serverDetails);
        await viewModel.addUrlsInList(result.serverUrl);
        viewModel.notifyListeners();
      }
    },
    child: const Icon(
      Icons.add,
      size: 36,
    ),
  );
}

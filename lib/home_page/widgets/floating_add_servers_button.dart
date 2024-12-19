import 'package:flutter/material.dart';
import '../../add_server_page/add_server_vu.dart';
import '../../shared_pref/shared_pref.dart';
import '../../models/server_details.dart';
import '../home_vm.dart';

FloatingActionButton floatingAddServerButton(
    BuildContext context, HomeVM viewModel) {
  return FloatingActionButton(
    backgroundColor: const Color(0xFF41A3FF),
    shape: const CircleBorder(eccentricity: 0.0),
    onPressed: () async {
      final result = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => const AddServerVU()));
      if (result != null && result is ServerDetails) {
        await viewModel.addServerDetails(result);
        await SharedPref.saveServerDetailsList(viewModel.serverDetails);
        await viewModel.addUrlsInList(result.serverUrl);
        // await viewModel.fetchServerModel(result.serverUrl);
        viewModel.notifyListeners();
      }
    },
    child: const Icon(
      Icons.add,
      size: 36,
    ),
  );
}

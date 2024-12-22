import 'package:flutter/material.dart';
import '../../add_server_page/add_server_vu.dart';
import '../../shared_pref/shared_pref.dart';
import '../../models/server_details.dart';
import '../home_vm.dart';

PopupMenuButton<String> popUpMenuButtonFunction(
    BuildContext context, HomeVM viewModel, int index) {
  return PopupMenuButton<String>(
    color: const Color(0xFF2B313D),
    icon: const Icon(Icons.more_vert),
    onSelected: (String value) async {
      if (value == 'Edit') {
        final updatedServer = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddServerVU(
                    serverDetails: viewModel.serverDetails[index])));
        if (updatedServer != null && updatedServer is ServerDetails) {
          viewModel.serverDetails[index] = updatedServer;
          await SharedPref.saveServerDetailsList(viewModel.serverDetails);
          await viewModel.updateAndroidAboutUrls(index);
          viewModel.notifyListeners();
        }
      } else if (value == 'Delete') {
        viewModel.serverDetails.removeAt(index);
        await SharedPref.saveServerDetailsList(viewModel.serverDetails);
        await viewModel.updateAndroidAboutUrls(index);
        viewModel.notifyListeners();
      }
    },
    itemBuilder: (BuildContext context) {
      return <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'Edit', child: Text('Edit')),
        const PopupMenuItem<String>(value: 'Delete', child: Text('Delete'))
      ];
    },
  );
}

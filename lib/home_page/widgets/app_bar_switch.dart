import 'package:flutter/material.dart';
import '../home_vm.dart';

Column appBarSwitch(BuildContext context, HomeVM viewModel) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Theme(
        data: Theme.of(context).copyWith(
            switchTheme: const SwitchThemeData(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)),
        child: Transform.scale(
          scale: 0.8,
          child: Switch(
            value: viewModel.isServiceRunning,
            onChanged: (bool value) {
              viewModel.toggleSwitch();
              if (viewModel.isServiceRunning == true) {
                viewModel.fetchDataAndStartService();
              } else {
                // viewModel.stopTimer();
              }
            },
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.only(right: 12),
        child: Text(
          'Auto Refresh',
          style: TextStyle(fontSize: 10),
        ),
      )
    ],
  );
}

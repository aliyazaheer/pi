import 'package:flutter/material.dart';
import '../../shared_pref/shared_pref.dart';
import '../home_vm.dart';

PopupMenuButton<String> popUpMenuOfAppBar(
    BuildContext context, HomeVM viewModel) {
  String selectedValue = viewModel.selectedValue ?? 'Off';
  return PopupMenuButton<String>(
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF222832)
        : const Color(0xFFF5F5F5),
    icon: const Icon(Icons.more_vert),
    onSelected: (String value) async {
      // Save selected value in ViewModel and SharedPref
      viewModel.setSelectedValue(value);
      await SharedPref.setDelayTimeOfResponse('selectedInterval', value);
      if (value == 'Off') {
        viewModel.off(); // Stop service
      } else if (value == '60000') {
        viewModel.restartServiceWithInterval(value);
        viewModel.oneMin();
      } else if (value == '180000') {
        viewModel.restartServiceWithInterval(value);
        viewModel.threeMin();
      } else if (value == '300000') {
        viewModel.restartServiceWithInterval(value);
        viewModel.fiveMin();
      } else if (value == '420000') {
        viewModel.restartServiceWithInterval(value);
        viewModel.sevenMin();
      } else if (value == '6000000') {
        viewModel.restartServiceWithInterval(value);
        viewModel.tenMin();
      }
    },
    itemBuilder: (BuildContext context) {
      return <PopupMenuEntry<String>>[
        buildPopupMenuItem(context, 'Off', selectedValue),
        buildPopupMenuItem(context, '10000', selectedValue,
            displayText: '1 min'),
        buildPopupMenuItem(context, '30000', selectedValue,
            displayText: '3 min'),
        buildPopupMenuItem(context, '50000', selectedValue,
            displayText: '5 min'),
        buildPopupMenuItem(context, '70000', selectedValue,
            displayText: '7 min'),
        buildPopupMenuItem(context, '100000', selectedValue,
            displayText: '10 min'),
      ];
    },
  );
}

// Function to build a popup menu item and highlight the selected one
PopupMenuItem<String> buildPopupMenuItem(
    BuildContext context, String value, String selectedValue,
    {String? displayText}) {
  return PopupMenuItem<String>(
    value: value,
    child: Text(
      displayText ?? value,
      style: TextStyle(
        fontWeight:
            selectedValue == value ? FontWeight.bold : FontWeight.normal,
        color: selectedValue == value
            ? Theme.of(context).primaryColor
            : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
      ),
    ),
  );
}

// Function to show the confirmation dialog
Future<bool?> showConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF333744)
            : const Color(0xFFFFFFFF),
        content: const Text(
          'Do you want to restart the service?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Dismiss dialog with 'false'
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirm dialog with 'true'
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Primary blue color
            ),
            child: const Text('Restart Service'),
          ),
        ],
      );
    },
  );
}

import 'package:flutter/material.dart';
import '../../shared_pref/shared_pref.dart';
import '../home_vm.dart';

// PopupMenuButton<String> popUpMenuOfAppBar(
//     BuildContext context, HomeVM viewModel) {
//   String selectedValue = viewModel.selectedValue ?? 'Off';
//   return PopupMenuButton<String>(
//     color: Theme.of(context).brightness == Brightness.dark
//         ? const Color(0xFF222832)
//         : const Color(0xFFF5F5F5),
//     icon: const Icon(Icons.more_vert),
//     onSelected: (String value) async {
//       // Save selected value in ViewModel and SharedPref
//       viewModel.setSelectedValue(value);
//       await SharedPref.setDelayTimeOfResponse('selectedInterval', value);
//       if (value == 'Off') {
//         viewModel.off(); // Stop service
//       } else if (value == '60000') {
//         viewModel.restartServiceWithInterval('60000');
//         // viewModel.oneMin();
//       } else if (value == '180000') {
//         viewModel.restartServiceWithInterval('180000');
//         // viewModel.threeMin();
//       } else if (value == '300000') {
//         viewModel.restartServiceWithInterval('300000');
//         // viewModel.fiveMin();
//       } else if (value == '420000') {
//         viewModel.restartServiceWithInterval('420000');
//         // viewModel.sevenMin();
//       } else if (value == '600000') {
//         viewModel.restartServiceWithInterval('600000');
//         // viewModel.tenMin();
//       }
//     },
//     itemBuilder: (BuildContext context) {
//       return <PopupMenuEntry<String>>[
//         buildPopupMenuItem(context, 'Off', selectedValue),
//         buildPopupMenuItem(context, '60000', selectedValue,
//             displayText: '1 min'),
//         buildPopupMenuItem(context, '180000', selectedValue,
//             displayText: '3 min'),
//         buildPopupMenuItem(context, '300000', selectedValue,
//             displayText: '5 min'),
//         buildPopupMenuItem(context, '420000', selectedValue,
//             displayText: '7 min'),
//         buildPopupMenuItem(context, '600000', selectedValue,
//             displayText: '10 min'),
//       ];
//     },
//   );
// }
PopupMenuButton<String> popUpMenuOfAppBar(
    BuildContext context, HomeVM viewModel) {
  return PopupMenuButton<String>(
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF222832)
        : const Color(0xFFF5F5F5),
    icon: const Icon(Icons.more_vert),
    onSelected: (String value) async {
      viewModel.setSelectedValue(value);
      await SharedPref.setDelayTimeOfResponse('selectedInterval');

      if (value == 'Off') {
        await viewModel.off();
        showConfirmationDialog(context);
      } else {
        await viewModel.restartServiceWithInterval(value);
      }
    },
    itemBuilder: (BuildContext context) => [
      buildPopupMenuItem(context, 'Off', viewModel.selectedValue ?? 'Off'),
      // buildPopupMenuItem(context, '5000', viewModel.selectedValue ?? 'Off',
      //     displayText: '5 sec'),
      buildPopupMenuItem(context, '60000', viewModel.selectedValue ?? 'Off',
          displayText: '1 min'),
      buildPopupMenuItem(context, '180000', viewModel.selectedValue ?? 'Off',
          displayText: '3 min'),
      buildPopupMenuItem(context, '300000', viewModel.selectedValue ?? 'Off',
          displayText: '5 min'),
      buildPopupMenuItem(context, '420000', viewModel.selectedValue ?? 'Off',
          displayText: '7 min'),
      buildPopupMenuItem(context, '600000', viewModel.selectedValue ?? 'Off',
          displayText: '10 min'),
    ],
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
          'You need to restart the service by selecting a time from the popup menu.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm dialog with 'true'
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Primary blue color
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      );
    },
  );
}

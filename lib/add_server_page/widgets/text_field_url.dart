import 'package:flutter/material.dart';
import '../add_server_vm.dart';

TextFormField textFieldUrl(
    {required AddServerVM viewModel,
    required String hintTextOfField,
    // required String valueName,
    required TextEditingController controllerName}) {
  return TextFormField(
    controller: controllerName,
    decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        hintText: hintTextOfField),
    onChanged: (value) {
      viewModel.serverUrl = value;
      viewModel.notifyListeners();
    },
    onTap: () {
      viewModel.serverModel != null ? viewModel.serverModel = null : null;
    },
  );
}

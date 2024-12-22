import 'package:flutter/material.dart';
import '../add_server_vm.dart';

TextFormField textField(
    {required AddServerVM viewModel,
    required String hintTextOfField,
    required TextEditingController controllerName,
    required Function(String) onValueChanged}) {
  return TextFormField(
    controller: controllerName,
    decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        hintText: hintTextOfField),
    onChanged: (value) {
      onValueChanged(value);
      viewModel.notifyListeners();
    },
    onTap: () {
      viewModel.serverModel != null ? viewModel.serverModel = null : null;
    },
  );
}

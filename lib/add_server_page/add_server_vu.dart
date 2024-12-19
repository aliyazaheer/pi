
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

import '../common_widgets/glow_of_cards.dart';
import '../common_widgets/space.dart';
import '../models/server_details.dart';
import 'add_server_vm.dart';
import 'widgets/floating_get_server_button.dart';
import 'widgets/glow_of_text_field.dart';
import 'widgets/new_server_data_card.dart';
import 'widgets/text_field.dart';

class AddServerVU extends StackedView<AddServerVM> {
  final ServerDetails? serverDetails;
  const AddServerVU({super.key, this.serverDetails});

  @override
  void onViewModelReady(AddServerVM viewModel) {
    super.onViewModelReady(viewModel);
    if (serverDetails != null) {
      viewModel.serverNameController.text = serverDetails!.serverName;
      viewModel.serverUrlController.text = serverDetails!.serverUrl;
    }
  }

  @override
  Widget builder(BuildContext context, AddServerVM viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serverDetails != null
            ? 'Editing ${serverDetails!.serverName}'
            : 'Add New Server'),
        backgroundColor: const Color(0xFF2B313D),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                glowOfCard(cardFunction: newServerDataCard(viewModel)),
                spaceY(heightValue: 30),
                glowOfTextField(
                  cardFunction: textField(
                    viewModel: viewModel,
                    hintTextOfField: 'Enter Server Name',
                    controllerName: viewModel.serverNameController,
                    onValueChanged: (value) {
                      viewModel.serverName = value;
                    },
                  ),
                ),
                spaceY(heightValue: 30),
                glowOfTextField(
                  cardFunction: textField(
                    viewModel: viewModel,
                    hintTextOfField: 'Enter URL e.g. dev.chitech.com',
                    controllerName: viewModel.serverUrlController,
                    onValueChanged: (value) {
                      viewModel.serverUrl = value;
                    },
                  ),
                ),
                spaceY(heightValue: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      onPressed: () async {
                        viewModel.onPressingTestServer(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF41A3FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text("Test Server")),
                )
              ],
            ),
          )),
      floatingActionButton: floatingGetServerButton(viewModel, context),
    );
  }

  @override
  AddServerVM viewModelBuilder(BuildContext context) {
    return AddServerVM();
  }
}

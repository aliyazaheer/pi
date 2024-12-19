import 'package:flutter/material.dart';
import 'package:flutter_platform_integration/shared_pref/shared_pref.dart';
import 'package:stacked/stacked.dart';

import '../models/server_details.dart';
import 'home_vm.dart';
import 'widgets/app_bar_switch.dart';
import 'widgets/count_online_app_bar.dart';
import 'widgets/floating_add_servers_button.dart';
import 'widgets/list_of_servers.dart';

class HomeVU extends StackedView<HomeVM> {
  final ServerDetails? serverDetails;
  HomeVU({super.key, this.serverDetails});
  @override
  Future<void> onViewModelReady(HomeVM viewModel) async {
    super.onViewModelReady(viewModel);
    await viewModel.initializeSwitchState();
    await SharedPref.getSavedServerDetailsList();

    if (viewModel.isOn == true) {
      // viewModel.fetchData();
    } else {
      // viewModel.fetchData();
    }
  }

  @override
  Widget builder(BuildContext context, HomeVM viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset('assets/images/companylogo.png'),
        ),
        backgroundColor: const Color(0xFF2B313D),
        actions: [appBarSwitch(context, viewModel)],
        title: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CHI SERVERS',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              countOnlineOfAppBar(viewModel)
            ],
          ),
        ),
      ),
      body: viewModel.serverDetails.isEmpty
          ? const Center(
              child: Text(
              'No servers details available. Please add a server',
              style: TextStyle(fontSize: 12),
            ))
          :
          // RefreshIndicator(
          // onRefresh: viewModel.fetchData(),
          // child:
          listOfServers(viewModel),
      // ),
      floatingActionButton: floatingAddServerButton(context, viewModel),
    );
  }

  @override
  HomeVM viewModelBuilder(BuildContext context) {
    return HomeVM();
  }
}

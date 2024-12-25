import 'package:flutter/material.dart';
import 'package:flutter_platform_integration/shared_pref/shared_pref.dart';
import 'package:stacked/stacked.dart';
import '../models/server_details.dart';
import 'home_vm.dart';
import 'widgets/app_bar_switch.dart';
import 'widgets/count_online_app_bar.dart';
import 'widgets/floating_add_servers_button.dart';
import 'widgets/list_of_servers.dart';
import 'widgets/popup_menu_of_appbar.dart';

class HomeVU extends StackedView<HomeVM> {
  final VoidCallback onThemeToggle;
  final ServerDetails? serverDetails;

  const HomeVU({super.key, this.serverDetails, required this.onThemeToggle});
  @override
  Future<void> onViewModelReady(HomeVM viewModel) async {
    super.onViewModelReady(viewModel);
    await viewModel.initializeSwitchState();
    await viewModel.initializeTheme();
    await viewModel.initializeSelectedValueOfDelayTime();
    await SharedPref.getSavedServerDetailsList();
    if (viewModel.isServiceRunning == true) {
      await viewModel.fetchDataAndStartService();
    } else {
      // await viewModel.fetchDataAndStopService();
    }
  }

  @override
  Widget builder(BuildContext context, HomeVM viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Theme.of(context).brightness == Brightness.dark
                ? Image.asset('assets/images/companylogo.png')
                : Image.asset('assets/images/companylogodark.png')),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
              onPressed: onThemeToggle,
              icon: Icon(Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode)),
          popUpMenuOfAppBar(context, viewModel)
          // appBarSwitch(context, viewModel)
        ],
        title: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CHI SERVERS',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              countOnlineOfAppBar(context, viewModel)
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
          // onRefresh: viewModel.onRefreshFetchData(),
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

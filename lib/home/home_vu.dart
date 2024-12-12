import 'package:flutter/material.dart';
import 'package:flutter_platform_integration/home/home_vm.dart';
import 'package:stacked/stacked.dart';

class HomeVU extends StackedView<HomeVM> {
  @override
  void onViewModelReady(HomeVM viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.initialize();
  }

  @override
  Widget builder(BuildContext context, HomeVM viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foreground Service Example')),
      body: viewModel.serverModels.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show a loader if the data is still loading
          : ListView.builder(
              itemCount: viewModel.urls.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SERVER ${index + 1}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        'CPU LOAD %AGE',
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        viewModel.serverModels.isNotEmpty
                            ? viewModel.serverModels[index].toString()
                            : 'Loading...',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
    );
  }

  @override
  HomeVM viewModelBuilder(BuildContext context) {
    return HomeVM();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_platform_integration/home_page/home_vm.dart';
import 'package:flutter_platform_integration/prac/prac_vm.dart';
import 'package:stacked/stacked.dart';

class PracVU extends StackedView<PracVM> {
  const PracVU({super.key});

  @override
  void onViewModelReady(PracVM viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.initialize();
  }

  @override
  Widget builder(BuildContext context, PracVM viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foreground Service Example')),
      body: ListView.builder(
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
                const Text(
                  'MEMORY %AGE',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  viewModel.serverModels.isNotEmpty &&
                          index < viewModel.serverModels.length
                      ? viewModel.serverModels[index].memory.percentage
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
  PracVM viewModelBuilder(BuildContext context) {
    return PracVM();
  }
}

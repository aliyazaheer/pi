import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../common_widgets/glow_of_cards.dart';
import '../models/server_details.dart';
import 'detail_page_vm.dart';
import 'widgets/cpu_card.dart';
import 'widgets/disks_card.dart';
import 'widgets/heading_of_url.dart';
import 'widgets/headings_of_cpu_memory_disks_card.dart';
import 'widgets/memory_card.dart';
import '../common_widgets/space.dart';
import 'widgets/padding_of_cards.dart';
import 'widgets/url_card.dart';
import 'widgets/webview_card.dart';

class DetailPageVU extends StackedView<DetailPageVM> {
  final ServerDetails? serverDetails;

  const DetailPageVU({super.key, this.serverDetails});

  @override
  void onViewModelReady(DetailPageVM viewModel) {
    super.onViewModelReady(viewModel);
    Future<void> fetchData() async {
      try {
        if (serverDetails != null) {
          await viewModel.fetchServerModel(serverDetails!.serverUrl);
          viewModel.notifyListeners();
        }
      } catch (e) {
        debugPrint('Error fetching server details: $e');
      }
    }

    fetchData();
    viewModel.startTimer(fetchData);
    viewModel.notifyListeners();
  }

  @override
  Widget builder(BuildContext context, DetailPageVM viewModel, Widget? child) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${serverDetails?.serverName}'),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2B313D)
              : const Color(0xFFF5F5F5),
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          if (viewModel.serverModel == null) ...[
            paddingOfCards(
                viewModel: viewModel,
                glowOfCard: glowOfCard(
                    cardFunction: WebViewCardWidget(
                        viewModel: viewModel,
                        url:
                            'https://umair-stable.smartclinicpk.com/rms/v1/swagger')))
          ] else ...[
            headingOfUrL(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: glowOfCard(
                cardFunction: UrlCard(serverDetails: serverDetails),
              ),
            ),
            spaceY(heightValue: 10),
            headingOfCpuMemoryAndDisksCards(
                viewModel: viewModel, textOfHeading: 'CPUs'),
            paddingOfCards(
                viewModel: viewModel,
                glowOfCard: glowOfCard(
                  cardFunction: cpuCard(context, viewModel),
                )),
            spaceY(heightValue: 10),
            headingOfCpuMemoryAndDisksCards(
                viewModel: viewModel, textOfHeading: 'Memory:'),
            paddingOfCards(
                viewModel: viewModel,
                glowOfCard: glowOfCard(
                  cardFunction: memoryCard(context, viewModel),
                )),
            spaceY(heightValue: 10),
            headingOfCpuMemoryAndDisksCards(
                viewModel: viewModel, textOfHeading: 'Disks:'),
            paddingOfCards(
                viewModel: viewModel,
                glowOfCard: glowOfCard(
                  cardFunction: disksCard(context, viewModel),
                )),
            spaceY(heightValue: 10),
            paddingOfCards(
                viewModel: viewModel,
                glowOfCard: glowOfCard(
                  cardFunction: WebViewCardWidget(
                      viewModel: viewModel,
                      url: 'https://umair-stable.smartclinicpk.com'),
                )),
            spaceY(heightValue: 10),
            paddingOfCards(
                viewModel: viewModel,
                glowOfCard: glowOfCard(
                  cardFunction: WebViewCardWidget(
                      viewModel: viewModel,
                      url:
                          'https://umair-stable.smartclinicpk.com/rms/v1/swagger'),
                )),
            // paddingOfCards(
            //     viewModel: viewModel,
            //     glowOfCard: glowOfCard(
            //       cardFunction: webViewCard(context, viewModel,
            //           'https://umair-stable.smartclinicpk.com/rms/v1/swagger'),
            //     )),
          ]
        ])));
  }

  @override
  DetailPageVM viewModelBuilder(BuildContext context) {
    return DetailPageVM();
  }
}

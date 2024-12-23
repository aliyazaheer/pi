import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../common_widgets/glow_of_cards.dart';
import '../../detail_page_of_server/detail_page_vu.dart';
import '../home_vm.dart';
import 'cards_of_list.dart';

ListView listOfServers(HomeVM viewModel) {
  return ListView.builder(
      itemCount: viewModel.serverDetails.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: InkWell(
            child: glowOfCard(
                cardFunction: cardsOfList(viewModel, index, context)),
            onTap: () {
              // if (viewModel.serverModel == null) {
              //   Fluttertoast.showToast(
              //     msg: "No server details to open",
              //   );
              //   return;
              // }
              final selectedServerDetails = viewModel.serverDetails[index];
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailPageVU(
                            serverDetails: selectedServerDetails,
                          )));
            },
          ),
        );
      });
}

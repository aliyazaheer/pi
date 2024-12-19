import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;

import '../models/server_details.dart';
import '../models/server_model.dart';
import '../shared_pref/shared_pref.dart';

class HomeVM extends BaseViewModel {
  ServerModel? serverModel;
  List<ServerDetails> serverDetails = [];
  List<ServerModel> serverModels = [];
  bool isOn = true;
  bool isLoading = false;
  String? errorInFetchingData;
  bool isUp = false;
  int countOnline = 0;

  bool isRed = false;
  Timer? refreshTime;
  countOnlineUpdate() {
    countOnline == serverDetails.length ? countOnline = 0 : countOnline;
    serverModel != null ? countOnline++ : countOnline = countOnline;
    debugPrint(
        '+++++++++++ Count online = ${countOnline} +++++ ${serverDetails.length}');
    countOnline < serverDetails.length ? isRed = true : isRed = false;
    print('================= $isRed');
  }

  void startTimer() {
    refreshTime = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    try {
      final servers = await SharedPref.getSavedServerDetailsList();
      if (servers.isNotEmpty) {
        for (var server in servers) {
          addServerDetailsList(server);
          fetchServerModel(server.serverUrl);
        }
        // countOnlineUpdate();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching server details: $e');
    }
  }

  void stopTimer() {
    refreshTime?.cancel();
    refreshTime = null;
  }

  void dispose() {
    stopTimer();
    super.dispose();
  }

  toggleSwitch() async {
    isOn = !isOn;
    await SharedPref.saveSwitchState(isOn);
    notifyListeners();
  }

  initializeSwitchState() async {
    isOn = (await SharedPref.getSwitchState())??true;
    // isOn ??= true;
    debugPrint('+++isOn =   $isOn +++');
    notifyListeners();
  }

  Future<void> addServerDetailsList(ServerDetails newServerDetail) async {
    isLoading = true;
    serverDetails = await SharedPref.getSavedServerDetailsList();
    await SharedPref.saveServerDetailsList(serverDetails);
    notifyListeners();
  }

  Future<void> addServerDetails(ServerDetails newServerDetail) async {
    serverDetails = await SharedPref.getSavedServerDetailsList();
    serverDetails.insert(0, newServerDetail);
    await SharedPref.saveServerDetailsList(serverDetails);
    notifyListeners();
  }

  fetchServerModel(String serverUrl) async {
    isLoading = true;
    errorInFetchingData = null;
    notifyListeners();
    try {
      if (!serverUrl.startsWith('https://')) {
        serverUrl = 'https://$serverUrl';
      }
      serverUrl = '$serverUrl/rms/v1/serverHealth';
      final response = await http.get(Uri.parse(serverUrl));
      debugPrint(serverUrl);

      if (response.statusCode == 200) {
        serverModel = serverModelFromJson(response.body);
        notifyListeners();
        return serverModel;
      }
    } catch (e) {
      errorInFetchingData = "Failed to fetch server data";
      debugPrint("Failed to fetch server data");
      // Fluttertoast.showToast(msg: errorInFetchingData!);
      serverModel = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleRefresh() async {
    if (isLoading) return;
    isLoading = true;
    final servers = await SharedPref.getSavedServerDetailsList();
    try {
      if (servers.isNotEmpty) {
        for (var server in servers) {
          await SharedPref.saveServerDetailsList(servers);
          await fetchServerModel(server.serverUrl);
          notifyListeners();
        }
      } else {
        // Fluttertoast.showToast(msg: "No server to refresh");
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: "Failed to refresh server data");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

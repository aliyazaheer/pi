import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;

import '../models/server_details.dart';
import '../models/server_model.dart';

class DetailPageVM extends BaseViewModel {
  ServerModel? serverModel;
  List<ServerDetails> serverDetail = [];
  bool isLoading = false;
  String? errorInFetchingData;
  Timer? refreshTime;
  Timer? time;
  int index = 0;

  // double animationValue = 0.0;
  // startDataFetchAnimation() {
  // for (double i = 0.0; i <= 1.0; i = i + 0.1) {
  // animationValue = 1;
  // Future.delayed(Duration(milliseconds: (i * 1500).toInt()), () {
  //   animationValue = i;
  //   notifyListeners();
  // });
  // }
  // }

  void startTimer(Function fetchData) {
    refreshTime = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchData();
    });
  }

  fetchServerModel(String serverUrl) async {
    isLoading = true;
    errorInFetchingData = null;
    // notifyListeners();
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

  double getHeightOfBars() {
    double maxY = 0.0;
    if (serverModel == null || isLoading) {
      debugPrint('fetching............................');
    } else {
      double maxValue =
          serverModel!.cpu.cpusArray.reduce((a, b) => a > b ? a : b).toDouble();
      double interval = 5.0;

      maxY = (maxValue % interval == 0)
          ? maxValue + interval
          : (maxValue + (interval - (maxValue % interval)));
    }
    return maxY;
  }

  double getMemoryUsage() {
    double memoryUsage = 0.0;
    if (serverModel == null || isLoading) {
      debugPrint('fetching............................');
    } else {
      memoryUsage = (((serverModel!.memory.used) / 103741824)) /
          (((serverModel!.memory.total) / 103741824));

      debugPrint("+++++++++++memory usage $memoryUsage");
    }
    return memoryUsage;
  }

  double getDiskUsage(int used, int total) {
    return used / total;
  }
}

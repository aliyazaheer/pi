import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // bool isOn = true;
  bool isLoading = false;
  String? errorInFetchingData;
  bool isUp = false;
  int countOnline = 0;

  bool isRed = false;
  Timer? refreshTime;

  bool isServiceRunning = false;

  static const methodChannel =
      MethodChannel('com.aliya.servicespractice/foreground');
  static const eventChannel =
      EventChannel('com.aliya.servicespractice/counterStream');

  List<String> urls = [];

  Map<String, dynamic> data = {};

  Map<String, dynamic> get getData {
    return data;
  }

  void updateData(Map<String, dynamic> apiData) {
    data = apiData;
    notifyListeners();
  }

  addUrlsInList(String serverUrl) async {
    if (!serverUrl.startsWith('https://')) {
      serverUrl = 'https://$serverUrl';
    }
    serverUrl = '$serverUrl/rms/v1/serverHealth';
    print(serverUrl);
    debugPrint(serverUrl);
    urls.add(serverUrl);
    await initialize();
  }

  Future<void> initialize() async {
    isLoading = true;
    await _startService();
    await _sendUrlToAndroid();
    _startListeningToApiStream();
  }

  Future<void> _sendUrlToAndroid() async {
    try {
      await methodChannel
          .invokeMethod('startForegroundService', {'urls': urls});
      print("Sent URL: $urls");
    } catch (e) {
      print("Failed to send URL: $e");
    }
  }

  Future<void> _startService() async {
    try {
      final apisData =
          await methodChannel.invokeMethod('startForegroundService');
      if (apisData != null && apisData.isNotEmpty) {
        // serverModels.clear();
        for (String apiData in apisData) {
          serverModel = serverModelFromJson(apiData);
          serverModels.add(serverModel!);
          isLoading = false;
        }
        notifyListeners();
        print("Received all responses from servers first time");
      } else {
        print("No data received from the service.");
      }
    } catch (e) {
      print("Failed to get data: $e");
    }
  }

  void _startListeningToApiStream() {
    eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is List) {
          try {
            serverModels.clear();
            for (var apiResponse in event) {
              if (apiResponse is String) {
                var jsonMap = jsonDecode(apiResponse);
                serverModel = ServerModel.fromJson(jsonMap);
                serverModels.add(serverModel!);
                isLoading = false;
              }
            }
            notifyListeners();
          } catch (e) {
            print("Error parsing API response: $e");
          }
        } else {
          print("Invalid event type: ${event.runtimeType}");
        }
      },
      onError: (error) {
        print("Stream error: $error");
        isLoading = false;
      },
    );
  }

  countOnlineUpdate() {
    countOnline == serverDetails.length ? countOnline = 0 : countOnline;
    serverModel != null ? countOnline++ : countOnline = countOnline;
    debugPrint(
        '+++++++++++ Count online = ${countOnline} +++++ ${serverDetails.length}');
    countOnline < serverDetails.length ? isRed = true : isRed = false;
    print('================= $isRed');
  }

  // void startTimer() {
  //   refreshTime = Timer.periodic(Duration(seconds: 5), (timer) {
  //     fetchData();
  //   });
  // }

  Future<void> fetchDataAndStartService() async {
    try {
      final servers = await SharedPref.getSavedServerDetailsList();
      if (servers.isNotEmpty) {
        urls.clear();
        for (var server in servers) {
          await addServerDetailsList(server);
          addUrlsInList(server.serverUrl);
          // fetchServerModel(server.serverUrl);
        }
        // countOnlineUpdate();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching server details: $e');
    }
  }

  Future<void> fetchDataAndStopService() async {
    try {
      final servers = await SharedPref.getSavedServerDetailsList();
      if (servers.isNotEmpty) {
        urls.clear();
        for (var server in servers) {
          await addServerDetailsList(server);
          // addUrlsInList(server.serverUrl);

          fetchServerModel(server.serverUrl);
        }
        // countOnlineUpdate();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching server details: $e');
    }
  }

  // void stopTimer() {
  //   refreshTime?.cancel();
  //   refreshTime = null;
  // }

  // void dispose() {
  //   stopTimer();
  //   super.dispose();
  // }

  toggleSwitch() async {
    try {
      if (isServiceRunning) {
        await methodChannel.invokeMethod('stopForegroundService');
        urls.clear();
        // isLoading = false;
        isServiceRunning = false;
        print("Service Stopped");
      } else {
        isServiceRunning = true;
        // isLoading = true;
        await _startService();
        await _sendUrlToAndroid();
        _startListeningToApiStream();
        // await fetchDataAndStartService();
        notifyListeners();
        print("Service Started");
      }
      // isServiceRunning = !isServiceRunning;
      await SharedPref.saveSwitchState(isServiceRunning);
      notifyListeners();
    } on PlatformException catch (e) {
      print("Failed to toggle service: ${e.message}");
    }
  }

  initializeSwitchState() async {
    isServiceRunning = (await SharedPref.getSwitchState()) ?? true;
    // isOn ??= true;
    debugPrint('+++isServerRunning =   $isServiceRunning +++');
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

  onRefreshFetchData() async {
    try {
      final servers = await SharedPref.getSavedServerDetailsList();
      if (servers.isNotEmpty) {
        urls.clear();
        for (var server in servers) {
          await addServerDetailsList(server);
          fetchServerModel(server.serverUrl);
          // fetchServerModel(server.serverUrl);
        }
        // countOnlineUpdate();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching server details: $e');
    }
  }
}

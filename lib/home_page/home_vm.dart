import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import '../models/server_details.dart';
import '../models/server_model.dart';
import '../shared_pref/shared_pref.dart';

class HomeVM extends BaseViewModel {
  ServerModel? serverModel;
  List<ServerDetails> serverDetails = [];
  List<ServerModel> serverModels = [];
  bool isLoading = false;
  String? errorInFetchingData;
  bool isUp = false;
  int countOnline = 0;

  bool isRed = false;
  Timer? refreshTime;
  Timer? lastResponseTime;
  int counter = 0;
  String justNow = 'Just Now';
  String countSec = '';

  int totalServers = 0;
  int onlineServers = 0;
  List<String> apiResponses = [];

  bool isServiceRunning = false;
  ThemeMode theme = ThemeMode.dark;
  String? selectedValue;

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

  addUrlsInList(String serverUrl) async {
    if (!serverUrl.startsWith('https://')) {
      serverUrl = 'https://$serverUrl';
    }
    if (serverUrl.endsWith('.com') &&
        !serverUrl.endsWith('/rms/v1/serverHealth')) {
      serverUrl = '$serverUrl/rms/v1/serverHealth';
    }
    debugPrint(serverUrl);
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
    if (urls.isEmpty) {
      debugPrint("No URLs to send.");
      return;
    }
    try {
      await methodChannel
          .invokeMethod('startForegroundService', {'urls': urls});
      debugPrint("Sent URL: $urls");
    } catch (e) {
      debugPrint("Failed to send URL: $e");
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
        debugPrint("Received all responses from servers first time");
      } else {
        debugPrint("No data received from the service.");
      }
    } catch (e) {
      debugPrint("Failed to get data: $e");
    }
  }

  void _startListeningToApiStream() {
    eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          try {
            totalServers = event['totalServers'] as int;
            onlineServers = event['onlineServers'] as int;
            serverModels.clear();
            apiResponses = List<String>.from(event['apisResponse']);
            for (var apiResponse in apiResponses) {
              var jsonMap = jsonDecode(apiResponse);
              serverModel = ServerModel.fromJson(jsonMap);
              serverModels.add(serverModel!);
            }
            isLoading = false;
            notifyListeners();
            debugPrint("Total Servers: $totalServers");
            debugPrint("Online Servers: $onlineServers");
            startTimer();
          } catch (e) {
            debugPrint("Error parsing API response: $e");
          }
        } else {
          debugPrint("Invalid event type: ${event.runtimeType}");
        }
      },
      onError: (error) {
        debugPrint("Stream error: $error");
        isLoading = false;
      },
    );
  }

  void startTimer() {
    counter = 0;
    lastResponseTime?.cancel();
    lastResponseTime = Timer.periodic(const Duration(seconds: 1), (timer) {
      counter++;
      int hours = counter ~/ 3600; // 1 hour = 3600 seconds
      int minutes = (counter % 3600) ~/ 60; // Get remaining minutes after hours
      int seconds = counter % 60; // Remaining seconds after minutes

      if (hours > 0) {
        countSec = '$hours hr ${minutes} min ${seconds} sec ago';
      } else if (minutes > 0) {
        countSec = '$minutes min ${seconds} sec ago';
      } else {
        countSec = '$seconds sec ago';
      }

      // countSec = '$counter sec ago';
      notifyListeners();
      debugPrint("Timer: $counter seconds");
    });
  }

  void stopTimer() {
    lastResponseTime?.cancel();
  }

  updateAndroidAboutUrls(int index) async {
    final servers = await SharedPref.getSavedServerDetailsList();
    if (servers.isNotEmpty) {
      urls.clear();
      serverModels.clear();
      for (var server in servers) {
        await addServerDetailsList(server);
        addUrlsInList(server.serverUrl);
      }
      notifyListeners();
      if (isServiceRunning) {
        await methodChannel.invokeMethod('updateServiceUrls', {'urls': urls});
        _startListeningToApiStream();
      }
      notifyListeners();
    }
  }

  Future<void> fetchDataAndStartService() async {
    try {
      final servers = await SharedPref.getSavedServerDetailsList();
      if (servers.isNotEmpty) {
        urls.clear();
        for (var server in servers) {
          await addServerDetailsList(server);
          addUrlsInList(server.serverUrl);
        }
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
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching server details: $e');
    }
  }

  off() async {
    if (isServiceRunning) {
      await methodChannel.invokeMethod('stopForegroundService');
      serverModels.clear();
      urls.clear();
      isLoading = false;
      debugPrint("Service Stopped");
    }
  }

  void restartServiceWithInterval(String interval) async {
    if (!isServiceRunning) {
      debugPrint("Restarting Service...");
      try {
        final servers = await SharedPref.getSavedServerDetailsList();
        if (servers.isNotEmpty) {
          List<String> urls = [];
          for (var server in servers) {
            urls.add(server.serverUrl);
          }
          await methodChannel.invokeMethod('restartForegroundService', {
            'urls': urls,
            'interval': interval,
          });
          debugPrint("Service Restarted with Interval: $interval");
        }
      } catch (e) {
        debugPrint('Error restarting service: $e');
      }
      isServiceRunning = true;
    }
  }

  Future<void> initializeSelectedValueOfDelayTime() async {
    selectedValue =
        await SharedPref.getDelayTimeOfResponse('selectedInterval') ?? 'Off';
  }

  /// Update the selected value and persist it in SharedPref
  void setSelectedValue(String value) {
    selectedValue = value;
  }

  oneMin() async {
    await methodChannel.invokeMethod('delayTime', {'delayTime': 60000});
    debugPrint("1 minute send");
  }

  threeMin() async {
    await methodChannel.invokeMethod('delayTime', {'delayTime': 180000});
    debugPrint("3 minutes send");
  }

  fiveMin() async {
    await methodChannel.invokeMethod('delayTime', {'delayTime': 300000});
    debugPrint("5 minutes send");
  }

  sevenMin() async {
    await methodChannel.invokeMethod('delayTime', {'delayTime': 420000});
    debugPrint("7 minutes send");
  }

  tenMin() async {
    await methodChannel.invokeMethod('delayTime', {'delayTime': 600000});
    debugPrint("10 minutes send");
  }

  toggleSwitch() async {
    try {
      if (isServiceRunning) {
        await methodChannel.invokeMethod('stopForegroundService');
        serverModels.clear();
        urls.clear();
        isLoading = false;
        debugPrint("Service Stopped");
      } else {
        isLoading = true;
        try {
          final servers = await SharedPref.getSavedServerDetailsList();
          if (servers.isNotEmpty) {
            urls.clear();
            serverModels.clear();
            for (var server in servers) {
              await addServerDetailsList(server);
              addUrlsInList(server.serverUrl);
            }
            await methodChannel
                .invokeMethod('restartForegroundService', {'urls': urls});
            _startListeningToApiStream();
          }
        } catch (e) {
          debugPrint('Error fetching server details: $e');
          isLoading = false;
        }
        debugPrint("Service Started");
      }
      isServiceRunning = !isServiceRunning;
      await SharedPref.saveSwitchState(isServiceRunning);
      notifyListeners();
    } on PlatformException catch (e) {
      debugPrint("Failed to toggle service: ${e.message}");
      isLoading = false;
      notifyListeners();
    }
  }

  initializeSwitchState() async {
    isServiceRunning = (await SharedPref.getSwitchState()) ?? true;
    debugPrint('+++isServerRunning =   $isServiceRunning +++');
    notifyListeners();
  }

  initializeTheme() async {
    theme = (await SharedPref.getTheme());
    debugPrint('+++isDark =   $theme +++');
    notifyListeners();
  }

  // fetchServerModel(String serverUrl) async {
  //   isLoading = true;
  //   errorInFetchingData = null;
  //   notifyListeners();
  //   try {
  //     if (!serverUrl.startsWith('https://')) {
  //       serverUrl = 'https://$serverUrl';
  //     }
  //      if (!serverUrl.endsWith('/rms/v1/serverHealth')) {
  //       serverUrl = '$serverUrl/rms/v1/serverHealth';
  //      }
  //     final response = await http.get(Uri.parse(serverUrl));
  //     debugPrint(serverUrl);

  //     if (response.statusCode == 200) {
  //       serverModel = serverModelFromJson(response.body);
  //       notifyListeners();
  //       return serverModel;
  //     }
  //   } catch (e) {
  //     errorInFetchingData = "Failed to fetch server data";
  //     debugPrint("Failed to fetch server data");
  //      Fluttertoast.showToast(msg: errorInFetchingData!);
  //     serverModel = null;
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Future<void> handleRefresh() async {
  //   if (isLoading) return;
  //   isLoading = true;
  //   final servers = await SharedPref.getSavedServerDetailsList();
  //   try {
  //     if (servers.isNotEmpty) {
  //       for (var server in servers) {
  //         await SharedPref.saveServerDetailsList(servers);
  //         await fetchServerModel(server.serverUrl);
  //         notifyListeners();
  //       }
  //     } else {
  //        Fluttertoast.showToast(msg: "No server to refresh");
  //     }
  //   } catch (e) {
  //      Fluttertoast.showToast(msg: "Failed to refresh server data");
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // onRefreshFetchData() async {
  //   try {
  //     final servers = await SharedPref.getSavedServerDetailsList();
  //     if (servers.isNotEmpty) {
  //       urls.clear();
  //       for (var server in servers) {
  //         await addServerDetailsList(server);
  //         fetchServerModel(server.serverUrl);
  //         // fetchServerModel(server.serverUrl);
  //       }
  //       // countOnlineUpdate();
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     debugPrint('Error fetching server details: $e');
  //   }
  // }
}

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
    if (urls.isEmpty) {
      print("No URLs to send.");
      return;
    }
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

  // void _startListeningToApiStream() {
  //   eventChannel.receiveBroadcastStream().listen(
  //     (event) {
  //       if (event is List) {
  //         try {
  //           serverModels.clear();
  //           for (var apiResponse in event) {
  //             if (apiResponse is String) {
  //               var jsonMap = jsonDecode(apiResponse);
  //               serverModel = ServerModel.fromJson(jsonMap);
  //               serverModels.add(serverModel!);
  //               isLoading = false;
  //             }
  //           }
  //           notifyListeners();
  //           startTimer();
  //         } catch (e) {
  //           print("Error parsing API response: $e");
  //         }
  //       } else {
  //         print("Invalid event type: ${event.runtimeType}");
  //       }
  //     },
  //     onError: (error) {
  //       print("Stream error: $error");
  //       isLoading = false;
  //     },
  //   );
  // }
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
            debugPrint("hhhhhhhhhhhhhhh== Online Servers: $onlineServers");
            startTimer();
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

  void startTimer() {
    counter = 0;
    lastResponseTime?.cancel();
    lastResponseTime = Timer.periodic(Duration(seconds: 1), (timer) {
      counter++;
      countSec = '${counter} Sec';
      notifyListeners();
      print("Timer: $counter seconds");
    });
  }

  void stopTimer() {
    lastResponseTime?.cancel();
  }

  updateAndroidAboutUrls(int index) async {
    // urls.clear();
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

  // countOnlineUpdate() {
  //   countOnline >= serverDetails.length ? countOnline = 0 : countOnline;
  //   serverModel != null ? countOnline++ : countOnline = countOnline;
  //   debugPrint(
  //       '+++++++++++ Count online = $countOnline +++++ ${serverDetails.length}');
  //   countOnline < serverDetails.length ? isRed = true : isRed = false;
  //   print('========isRed========= $isRed');
  // }

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
          // fetchServerModel(server.serverUrl);
        }
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

  // toggleSwitch() async {
  //   try {
  //     if (isServiceRunning) {
  //       await methodChannel.invokeMethod('stopForegroundService');
  //       urls.clear();
  //       isLoading = false;
  //       print("Service Stopped");
  //     } else {
  //       isLoading = true;
  //       try {
  //         final servers = await SharedPref.getSavedServerDetailsList();
  //         if (servers.isNotEmpty) {
  //           urls.clear();
  //           for (var server in servers) {
  //             addUrlsInList(server.serverUrl);
  //           }
  //           notifyListeners();
  //         }
  //       } catch (e) {
  //         debugPrint('Error fetching server details: $e');
  //       }
  //       notifyListeners();
  //       print("Service Started");
  //     }
  //     isServiceRunning = !isServiceRunning;
  //     await SharedPref.saveSwitchState(isServiceRunning);
  //     notifyListeners();
  //   } on PlatformException catch (e) {
  //     print("Failed to toggle service: ${e.message}");
  //   }
  // }
  toggleSwitch() async {
    try {
      if (isServiceRunning) {
        // Stop the service
        await methodChannel.invokeMethod('stopForegroundService');
        serverModels.clear(); // Clear existing data
        urls.clear();
        isLoading = false;
        print("Service Stopped");
      } else {
        isLoading = true;
        try {
          final servers = await SharedPref.getSavedServerDetailsList();
          if (servers.isNotEmpty) {
            urls.clear();
            serverModels.clear(); // Clear any stale data
            for (var server in servers) {
              await addServerDetailsList(server);
              addUrlsInList(server.serverUrl);
            }
            // Explicitly request service restart
            await methodChannel
                .invokeMethod('restartForegroundService', {'urls': urls});
            _startListeningToApiStream(); // Reconnect to event stream
          }
        } catch (e) {
          debugPrint('Error fetching server details: $e');
          isLoading = false;
        }
        print("Service Started");
      }
      isServiceRunning = !isServiceRunning;
      await SharedPref.saveSwitchState(isServiceRunning);
      notifyListeners();
    } on PlatformException catch (e) {
      print("Failed to toggle service: ${e.message}");
      isLoading = false;
      notifyListeners();
    }
  }

  initializeSwitchState() async {
    isServiceRunning = (await SharedPref.getSwitchState()) ?? true;
    // isOn ??= true;
    debugPrint('+++isServerRunning =   $isServiceRunning +++');
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
  //     serverUrl = '$serverUrl/rms/v1/serverHealth';
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
  //     // Fluttertoast.showToast(msg: errorInFetchingData!);
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
  //       // Fluttertoast.showToast(msg: "No server to refresh");
  //     }
  //   } catch (e) {
  //     // Fluttertoast.showToast(msg: "Failed to refresh server data");
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

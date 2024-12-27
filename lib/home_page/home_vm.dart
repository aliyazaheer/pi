import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  late String interval;
  late bool isOnline = true;

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
    interval = await SharedPref.getDelayTimeOfResponse() ?? '60000';
    // if (interval == 'Off') {
    //   interval = '180000';
    //   isInitializeWithOneMin = true;
    // }
    urls.add(serverUrl);
    await initialize();
  }

  addUrlsInListDuringStopService(String serverUrl) async {
    if (!serverUrl.startsWith('https://')) {
      serverUrl = 'https://$serverUrl';
    }
    if (serverUrl.endsWith('.com') &&
        !serverUrl.endsWith('/rms/v1/serverHealth')) {
      serverUrl = '$serverUrl/rms/v1/serverHealth';
    }
    debugPrint(serverUrl);
    interval = await SharedPref.getDelayTimeOfResponse() ?? '60000';
    // if (interval == 'Off') {
    //   interval = '180000';
    //   isInitializeWithOneMin = true;
    // }
    urls.add(serverUrl);
    // await initialize();
  }

  Future<void> initialize() async {
    isLoading = true;
    await startBackgroundService();
    _startListeningToApiStream();
  }

  Future<void> startBackgroundService() async {
    if (urls.isEmpty) {
      debugPrint("No URLs to send.");
      return;
    }

    try {
      interval = (await SharedPref.getDelayTimeOfResponse()) ?? '60000';
      debugPrint("Starting service with delay: $interval and URLs: $urls");

      // Only call startForegroundService once with all necessary parameters
      final result = await methodChannel.invokeMethod('startForegroundService',
          {'urls': urls, 'delayTime': int.parse(interval)});

      debugPrint("Service start result: $result");

      // Handle initial data if any
      if (result != null && result is List) {
        serverModels.clear();
        for (String apiData in result) {
          serverModel = serverModelFromJson(apiData);
          serverModels.add(serverModel!);
        }
        notifyListeners();
        debugPrint("Processed initial server responses");
      }
    } catch (e) {
      debugPrint("Failed to start service: $e");
      Fluttertoast.showToast(
        msg: "Failed to start service",
      );
    } finally {
      isLoading = false;
    }
  }

  void _startListeningToApiStream() {
    eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          try {
            totalServers = event['totalServers'] as int;
            onlineServers = event['onlineServers'] as int;
            isOnline = event['isOnline'] as bool;
            serverModels.clear();
            apiResponses = List<String>.from(event['apisResponse']);

            for (var apiResponse in apiResponses) {
              var jsonMap = jsonDecode(apiResponse);
              serverModel = ServerModel.fromJson(jsonMap);
              serverModels.add(serverModel!);
            }

            isLoading = false;
            notifyListeners();
            debugPrint(
                "Updated - Total: $totalServers, Online: $onlineServers");
            startTimer();
          } catch (e) {
            debugPrint("Error parsing API response: $e");
          }
        } else {
          debugPrint("Received invalid event type: ${event.runtimeType}");
        }
      },
      onError: (error) {
        debugPrint("Stream error: $error");
        isLoading = false;
        Fluttertoast.showToast(
          msg: "Unable to fetch response.",
        );
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
    try {
      if (isServiceRunning) {
        await methodChannel.invokeMethod('stopForegroundService');
        serverModel = null;
        isServiceRunning = false;
        notifyListeners();

        final servers = await SharedPref.getSavedServerDetailsList();
        if (servers.isEmpty) {
          debugPrint('No servers found in SharedPreferences');
          return;
        }

        urls.clear();
        for (var server in servers) {
          await addServerDetailsList(server);
          String serverUrl = server.serverUrl;

          // URL formatting
          if (!serverUrl.startsWith('https://')) {
            serverUrl = 'https://$serverUrl';
          }
          if (serverUrl.endsWith('.com') &&
              !serverUrl.endsWith('/rms/v1/serverHealth')) {
            serverUrl = '$serverUrl/rms/v1/serverHealth';
          }
          urls.add(serverUrl);
        }
        interval = (await SharedPref.getDelayTimeOfResponse()) ?? '60000';

        debugPrint('Updating service with URLs: $urls');
        debugPrint('Using delay time: $interval milliseconds');

        // Call native method to update service
        final result = await methodChannel.invokeMethod('updateServiceUrls', {
          'urls': urls,
          'delayTime': int.parse(interval),
        });

        debugPrint('Service update result: $result');
        isServiceRunning = true;
      }
      _startListeningToApiStream();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating service: $e');
      // Handle error appropriately
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
          // addUrlsInListDuringStopService(server.serverUrl);
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

  Future<void> off() async {
    try {
      if (isServiceRunning) {
        await methodChannel.invokeMethod('stopForegroundService');
        serverModel = null;
        isServiceRunning = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to stop service: $e");
    }
  }

  Future<void> restartServiceWithInterval(String interval) async {
    try {
      if (!isServiceRunning) {
        final servers = await SharedPref.getSavedServerDetailsList();
        if (servers.isEmpty) return;

        urls.clear();
        for (var server in servers) {
          await addServerDetailsList(server);
          String serverUrl = server.serverUrl;
          if (!serverUrl.startsWith('https://')) {
            serverUrl = 'https://$serverUrl';
          }
          if (serverUrl.endsWith('.com') &&
              !serverUrl.endsWith('/rms/v1/serverHealth')) {
            serverUrl = '$serverUrl/rms/v1/serverHealth';
          }
          urls.add(serverUrl);

          debugPrint('Restarting service with URLs: $urls');
        }
        // Restart service
        await methodChannel.invokeMethod('restartForegroundService', {
          'urls': urls,
          'delayTime': int.parse(interval),
        });
        debugPrint(
            "++++++++++++++++++++++++++++++++++9999 $urls  +++++++++++++++++++++++999");
        isServiceRunning = true;
      } else if (isServiceRunning) {
        await methodChannel.invokeMethod('stopForegroundService');
        serverModel = null;
        isServiceRunning = false;
        notifyListeners();

        final servers = await SharedPref.getSavedServerDetailsList();
        if (servers.isEmpty) return;

        urls.clear();
        for (var server in servers) {
          await addServerDetailsList(server);
          String serverUrl = server.serverUrl;
          if (!serverUrl.startsWith('https://')) {
            serverUrl = 'https://$serverUrl';
          }
          if (serverUrl.endsWith('.com') &&
              !serverUrl.endsWith('/rms/v1/serverHealth')) {
            serverUrl = '$serverUrl/rms/v1/serverHealth';
          }
          urls.add(serverUrl);

          debugPrint('Restarting service with URLs: $urls');
        }
        // Restart service
        await methodChannel.invokeMethod('restartForegroundService', {
          'urls': urls,
          'delayTime': int.parse(interval),
        });
        debugPrint(
            "++++++++++++++++++++++++++++++++++9999 $urls  +++++++++++++++++++++++999");
        isServiceRunning = true;
        // Update delay time
        // await methodChannel
        //     .invokeMethod('delayTime', {'delayTime': int.parse(interval)});
      }

      _startListeningToApiStream();
      notifyListeners();
    } catch (e) {
      debugPrint('Error managing service: $e');
    }
  }

  Future<void> initializeSelectedValueOfDelayTime() async {
    selectedValue = await SharedPref.getDelayTimeOfResponse() ?? '60000';
  }

  void setSelectedValue(String value) {
    selectedValue = value;
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

  // toggleSwitch() async {
  //   try {
  //     if (isServiceRunning) {
  //       await methodChannel.invokeMethod('stopForegroundService');
  //       serverModels.clear();
  //       urls.clear();
  //       isLoading = false;
  //       debugPrint("Service Stopped");
  //     } else {
  //       isLoading = true;
  //       try {
  //         final servers = await SharedPref.getSavedServerDetailsList();
  //         if (servers.isNotEmpty) {
  //           urls.clear();
  //           serverModels.clear();
  //           for (var server in servers) {
  //             await addServerDetailsList(server);
  //             addUrlsInList(server.serverUrl);
  //           }
  //           await methodChannel
  //               .invokeMethod('restartForegroundService', {'urls': urls});
  //           _startListeningToApiStream();
  //         }
  //       } catch (e) {
  //         debugPrint('Error fetching server details: $e');
  //         isLoading = false;
  //       }
  //       debugPrint("Service Started");
  //     }
  //     isServiceRunning = !isServiceRunning;
  //     await SharedPref.saveSwitchState(isServiceRunning);
  //     notifyListeners();
  //   } on PlatformException catch (e) {
  //     debugPrint("Failed to toggle service: ${e.message}");
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

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

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_platform_integration/model/model.dart';
import 'package:stacked/stacked.dart';

class HomeVM extends BaseViewModel {
  static const methodChannel =
      MethodChannel('com.aliya.servicespractice/foreground');
  static const eventChannel =
      EventChannel('com.aliya.servicespractice/counterStream');

  List<String> urls = [
    "https://umair-stable.smartclinicpk.com/rms/v1/serverHealth",
    "https://umair-stable.smartclinicpk.com/rms/v1/serverHealth",
    "https://umair-stable.smartclinicpk.com/rms/v1/serverHealth"
  ];

  ServerModel? serverModel;
  List<ServerModel> serverModels = [];
  Map<String, dynamic> data = {};

  Map<String, dynamic> get getData {
    return data;
  }

  void updateData(Map<String, dynamic> apiData) {
    data = apiData;
    notifyListeners();
  }

  Future<void> initialize() async {
    await _startService();
    await _sendUrlToAndroid();
    _startListeningToApiStream();
  }

  Future<void> _sendUrlToAndroid() async {
    try {
      await methodChannel.invokeMethod('sendUrls', {'urls': urls});
      print("Sent URL: $urls");
    } catch (e) {
      print("Failed to send URL: $e");
    }
  }

  Future<void> _startService() async {
    try {
      final apisData = await methodChannel.invokeMethod('getData');
      if (apisData != null && apisData.isNotEmpty) {
        // serverModels.clear();
        for (String apiData in apisData) {
          serverModel = serverModelFromJson(apiData);
          serverModels.add(serverModel!);
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
  //       // if (event != null) {
  //       // final apisResponse = event['apisResponse'];
  //       if (event is List) {
  //         try {
  //           serverModels.clear();
  //           for (var apiResponse in event) {
  //             if (apiResponse is String) {
  //               serverModel = serverModelFromJson(apiResponse);
  //               serverModels.add(serverModel!);
  //             }
  //           }
  //           notifyListeners();
  //           print("Receiveing all responses froms servers");
  //         } catch (e) {
  //           print("Error parsing API response: $e");
  //         }
  //       } else {
  //         print("Invalid response type");
  //       }
  //       // }
  //       // else {
  //       //   print("Received null or invalid event");
  //       // }
  //     },
  //     onError: (error) {
  //       print("Stream error: $error");
  //     },
  //   );
  // }

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
      },
    );
  }
}

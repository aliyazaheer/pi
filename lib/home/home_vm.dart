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

  // List<String> cpuLoadPercentages = [];

  int counter = 0;
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
      for (String url in urls) {
        await methodChannel.invokeMethod('sendUrl', {'url': url});
        print("Sent URL: $url"); // Log each URL sent
      }
    } catch (e) {
      print("Failed to send URL: $e");
    }
  }

  Future<void> _startService() async {
    try {
      for (String url in urls) {
        final apiData =
            await methodChannel.invokeMethod('getData', {'url': url});
        if (apiData is String) {
          // Assuming serverModelFromJson parses the response and gives CPU load
          serverModel = serverModelFromJson(apiData);
          // cpuLoadPercentages.add(serverModel?.cpu.loadPercentage ?? '');
        } else {
          print("API data is not a string");
        }
      }
    } catch (e) {
      print("Failed to get data: $e");
    }
  }

  void _startListeningToApiStream() {
    eventChannel.receiveBroadcastStream().listen(
      (event) {
        print("received event::: $event");
        if (event != null) {
          counter = event['counterValue'] ?? counter;

          final apiResponse = event['apiResponse'];
          print("API Response: $apiResponse");
          if (apiResponse is String) {
            try {
              serverModel = serverModelFromJson(apiResponse);
            } catch (e) {
              print("Error parsing API response: $e");
            }
          } else {
            print("API response is not a string");
          }

          notifyListeners();
        } else {
          print("Received null event from stream");
        }
      },
      onError: (error) {
        print("Error listening to stream: $error");
      },
    );
  }

//   void _startListeningToApiStream() {
//     eventChannel.receiveBroadcastStream().listen(
//       (event) {
//         print("received event::: $event");
//         if (event != null) {
//           counter = event['counterValue'] ?? counter;

//           final apiResponse = event['apiResponse'];
//           if (apiResponse is String) {
//             print("API Response: $apiResponse"); // Log the raw response

//             // Check if the response is a valid JSON
//             if (isJson(apiResponse)) {
//               try {
//                 serverModel = serverModelFromJson(
//                     apiResponse); // Attempt to parse as JSON
//               } catch (e) {
//                 print("Error parsing API response: $e");
//               }
//             } else {
//               // Handle case where the response is not valid JSON (e.g., error response)
//               print("Received non-JSON response: $apiResponse");
//               // Optionally, set a fallback value for the server model or log the error
//               serverModel =
//                   null; // You can set a default value or leave it as null
//             }
//           } else {
//             print("API response is not a string");
//           }

//           notifyListeners();
//         } else {
//           print("Received null event from stream");
//         }
//       },
//       onError: (error) {
//         print("Error listening to stream: $error");
//       },
//     );
//   }

// // Helper function to check if a string is valid JSON
//   bool isJson(String response) {
//     try {
//       jsonDecode(response); // Try to parse the response as JSON
//       return true; // Return true if valid JSON
//     } catch (e) {
//       return false; // Return false if it's not valid JSON
//     }
//   }
}








































// import 'package:flutter/services.dart';
// import 'package:flutter_platform_integration/model/model.dart';
// import 'package:stacked/stacked.dart';

// class HomeVM extends BaseViewModel {
//   static const methodChannel =
//       MethodChannel('com.aliya.servicespractice/foreground');
//   static const eventChannel =
//       EventChannel('com.aliya.servicespractice/counterStream');
//   String url = "https://umair-stable.smartclinicpk.com/rms/v1/serverHealth";

//   int counter = 0;
//   String model = "";
//   ServerModel? serverModel;

//   Map<String, dynamic> data = {};

//   Map<String, dynamic> get getData {
//     return data;
//   }

//   void updateData(Map<String, dynamic> apiData) {
//     data = apiData;
//     notifyListeners();
//   }

//   Future<void> initialize() async {
//     await getInitialCounterValue();
//     await sendUrlToAndroid(url); 
//     startListeningToCounterStream();
//   }

//   Future<void> sendUrlToAndroid(String url) async {
//     try {
//       await methodChannel.invokeMethod('sendUrl', {'url': url});
//     } on PlatformException catch (e) {
//       print("Failed to send URL: ${e.message}");
//     }
//   }

//   Future<void> getInitialCounterValue() async {
//     try {
//       final apiData = await methodChannel
//           .invokeMethod('getData', {'url': url}); // Pass URL here
//       if (apiData != null) {
//         if (apiData is String) {
//           serverModel = serverModelFromJson(apiData);
//         } else {
//           print("Data model is not a string");
//         }
//       }
//     } on PlatformException catch (e) {
//       print("Failed to get data: ${e.message}");
//     }
//   }

//   void startListeningToCounterStream() {
//     eventChannel.receiveBroadcastStream().listen((event) {
//       if (event != null) {
//         // Ensure the event has the correct keys
//         if (event['counterValue'] != null) {
//           counter = event['counterValue'];
//         }
//         if (event['apiResponse'] != null) {
//           try {
//             final apiResponse = event['apiResponse'];
//             if (apiResponse is String) {
//               serverModel = serverModelFromJson(apiResponse);
//               print('data model found');
//             } else {
//               print("data model is not string");
//             }
//           } catch (e) {
//             print("Error parsing API response: $e");
//           }
//         }
//         notifyListeners();
//       } else {
//         print("Received null event from stream");
//       }
//     });
//   }
// }

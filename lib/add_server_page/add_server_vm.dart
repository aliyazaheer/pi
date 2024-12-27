import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';

import '../models/server_model.dart';

class AddServerVM extends BaseViewModel {
  TextEditingController serverNameController = TextEditingController();
  TextEditingController serverUrlController = TextEditingController();
  String serverName = '';
  String serverUrl = '';
  ServerModel? serverModel;
  bool isLoading = false;
  String? errorInFetchingData;
  bool isUp = false;
  bool isValidServerUrl(String serverUrl) {
    return serverUrl.isNotEmpty &&
        !serverUrl.contains(' ') &&
        serverUrl.contains('.com');
  }

  fetchServerModel(serverUrl) async {
    isLoading = true;
    errorInFetchingData = null;
    notifyListeners();
    try {
      if (!serverUrl.startsWith('https://')) {
        serverUrl = 'https://$serverUrl';
      }
      if (!serverUrl.endsWith('/rms/v1/serverHealth')) {
        serverUrl = '$serverUrl/rms/v1/serverHealth';
      }
      final response = await http.get(Uri.parse(serverUrl));
      debugPrint(serverUrl);

      if (response.statusCode == 200) {
        serverModel = serverModelFromJson(response.body);
        print("Fetched succesfully------------------------------------------");
        return serverModel;
      }
    } catch (e) {
      errorInFetchingData = "Failed to fetch server data";
      print("Failed to fetch server data");
      Fluttertoast.showToast(msg: errorInFetchingData!);
      serverModel = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  onPressingTestServer(BuildContext context) async {
    debugPrint('Button pressed....................');
    debugPrint(serverNameController.text);
    debugPrint(serverUrlController.text);

    serverName = serverNameController.text.trim();

    serverUrl = serverUrlController.text.trim();
    if (isValidServerUrl(serverUrl)) {
      if (serverName.isEmpty || serverUrl.isEmpty) {
        debugPrint('field is empty....................');
        Fluttertoast.showToast(
          msg: "Please fill all fields",
        );
        return;
      }

      await fetchServerModel(serverUrl);
      if (serverModel != null) {
        debugPrint('server data fetched...................');
        Fluttertoast.showToast(
          msg: "Server data fetched successfully",
        );
        isUp = true;
      } else {
        debugPrint('no server data available...................');
        // Fluttertoast.showToast(
        //   msg: "No server data available for this URL",
        // );
      }

      notifyListeners();
    } else {
      debugPrint('Invalid URL');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Please enter valid URL',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF41A3FF),
      ));
    }
  }
}

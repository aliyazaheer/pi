import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/server_details.dart';

class SharedPref {
  static SharedPreferences? prefs;
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveServerDetailsList(
      List<ServerDetails> serverDetails) async {
    String jsonList =
        jsonEncode(serverDetails.map((sd) => sd.toJson()).toList());
    bool? isSaved = await prefs?.setString('serverDetails', jsonList);
    if (isSaved == true) {
      debugPrint('Successfully saved :$jsonList');
    } else {
      debugPrint('Failed to save data');
    }
  }

  static Future<List<ServerDetails>> getSavedServerDetailsList() async {
    final String? serverDetailJson = prefs?.getString('serverDetails');
    if (serverDetailJson != null) {
      try {
        //  return  ServerDetails.fromJson(serverDetailJson);
        List<dynamic> jsonList = jsonDecode(serverDetailJson);
        return jsonList.map((sd) => ServerDetails.fromJson(sd)).toList();
      } catch (e) {
        debugPrint('Error parsing server details.');
      }
    } else {
      debugPrint('No server details found in Shared Pref');
    }
    return [];
  }

  static Future<void> saveSwitchState(bool isOn) async {
    await prefs?.setBool('switchState', isOn);
  }

  static Future<bool?> getSwitchState() async {
    bool? switchState = prefs?.getBool('switchState');
    debugPrint('+++++++++++++ $switchState++++++++++++++++++++');
    return switchState;
  }
}

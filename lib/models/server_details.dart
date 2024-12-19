import 'dart:convert';


class ServerDetails{
  String serverName;
  String serverUrl;
  ServerDetails({required this.serverName, required this.serverUrl});

  String toJson() {
    return jsonEncode({'serverName': serverName, 'serverUrl': serverUrl});
  }

  factory ServerDetails.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    return ServerDetails(
        serverName: json['serverName'], serverUrl: json['serverUrl']);
  }
}

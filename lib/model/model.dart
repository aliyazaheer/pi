// To parse this JSON data, do
//
//     final serverModel = serverModelFromJson(jsonString);

import 'dart:convert';

ServerModel serverModelFromJson(String str) =>
    ServerModel.fromJson(json.decode(str));

String serverModelToJson(ServerModel data) => json.encode(data.toJson());

class ServerModel {
  Memory memory;
  Cpu cpu;
  String uptime;
  List<Disk> disk;

  ServerModel({
    required this.memory,
    required this.cpu,
    required this.uptime,
    required this.disk,
  });

  factory ServerModel.fromJson(Map<String, dynamic> json) => ServerModel(
        memory: Memory.fromJson(json["memory"]),
        cpu: Cpu.fromJson(json["cpu"]),
        uptime: json["uptime"],
        disk: List<Disk>.from(json["disk"].map((x) => Disk.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "memory": memory.toJson(),
        "cpu": cpu.toJson(),
        "uptime": uptime,
        "disk": List<dynamic>.from(disk.map((x) => x.toJson())),
      };
}

class Cpu {
  String loadPercentage;
  List<double> cpusArray;
  String currentLoad;
  int totalLoad;

  Cpu({
    required this.loadPercentage,
    required this.cpusArray,
    required this.currentLoad,
    required this.totalLoad,
  });

  factory Cpu.fromJson(Map<String, dynamic> json) => Cpu(
        loadPercentage: json["loadPercentage"],
        cpusArray:
            List<double>.from(json["cpusArray"].map((x) => x?.toDouble())),
        currentLoad: json["currentLoad"],
        totalLoad: json["totalLoad"],
      );

  Map<String, dynamic> toJson() => {
        "loadPercentage": loadPercentage,
        "cpusArray": List<dynamic>.from(cpusArray.map((x) => x)),
        "currentLoad": currentLoad,
        "totalLoad": totalLoad,
      };
}

class Disk {
  String disk;
  int total;
  int used;
  String perUsed;

  Disk({
    required this.disk,
    required this.total,
    required this.used,
    required this.perUsed,
  });

  factory Disk.fromJson(Map<String, dynamic> json) => Disk(
        disk: json["disk"],
        total: json["total"],
        used: json["used"],
        perUsed: json["per_used"],
      );

  Map<String, dynamic> toJson() => {
        "disk": disk,
        "total": total,
        "used": used,
        "per_used": perUsed,
      };
}

class Memory {
  int total;
  int used;
  int free;
  String percentage;
  String bar;

  Memory({
    required this.total,
    required this.used,
    required this.free,
    required this.percentage,
    required this.bar,
  });

  factory Memory.fromJson(Map<String, dynamic> json) => Memory(
        total: json["total"],
        used: json["used"],
        free: json["free"],
        percentage: json["percentage"],
        bar: json["bar"],
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "used": used,
        "free": free,
        "percentage": percentage,
        "bar": bar,
      };
}

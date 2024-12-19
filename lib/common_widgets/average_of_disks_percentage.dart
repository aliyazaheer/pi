import '../models/server_model.dart';

int findingAverageOfDisksPercentages(ServerModel model) {
  if (model.disk.isEmpty) return 0;
  double diskPercentageSum;
  double sum = 0;
  for (var disk in model.disk) {
    diskPercentageSum = double.parse(disk.perUsed.replaceAll('%', ''));
    sum += diskPercentageSum;
  }
  int averageDiskPercentage = (sum / model.disk.length).round();
  return averageDiskPercentage;
}

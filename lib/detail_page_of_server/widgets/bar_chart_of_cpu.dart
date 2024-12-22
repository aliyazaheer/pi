import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../detail_page_vm.dart';

BarChart barChartOfCpu(BuildContext context, DetailPageVM viewModel) {
  return BarChart(BarChartData(
    maxY: viewModel.getHeightOfBars(),
    titlesData: FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
          sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          final title = "CPU ${index + 1}";
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 10,
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 5,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFF5F5F5)
                      : const Color(0xFF222832),
                  fontWeight: FontWeight.w900),
            ),
          );
        },
      )),
      leftTitles: AxisTitles(
          sideTitles: SideTitles(
        showTitles: true,
        interval: 5,
        reservedSize: 25,
        getTitlesWidget: (value, meta) {
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 10,
            child: Text(
              value.toInt().toString(),
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFF5F5F5)
                      : const Color(0xFF222832),
                  fontWeight: FontWeight.w900),
            ),
          );
        },
      )),
    ),
    borderData: FlBorderData(
        border: Border(
            top: BorderSide.none,
            right: BorderSide.none,
            bottom: BorderSide(
              width: 1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFFF5F5F5)
                  : const Color(0xFF222832),
            ),
            left: BorderSide(
                width: 1,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFF5F5F5)
                    : const Color(0xFF222832)))),
    // gridData: const FlGridData(show: false),
    barGroups: List.generate(
        viewModel.serverModel!.cpu.cpusArray.length,
        (index) => BarChartGroupData(x: index, barRods: [
              BarChartRodData(
                  toY: viewModel.serverModel!.cpu.cpusArray[index].toDouble(),
                  // fromY: 30,
                  width: 10,
                  color: const Color(0xFF41A3FF),
                  borderRadius: BorderRadius.zero)
            ])),
  ));
}

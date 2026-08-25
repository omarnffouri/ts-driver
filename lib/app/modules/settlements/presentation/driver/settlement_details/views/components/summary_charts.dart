import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

import '../../controllers/settlement_details_controller.dart';

class RevenueChart extends GetView<SettlementDetailsController> {
  // final List<MonthlyRevenue> data;

  const RevenueChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = controller.revenueData;
    return SizedBox(
        height: 300,
        width: double.infinity,
        child: SfCartesianChart(
          title: const ChartTitle(text: 'Revenue for the Last 6 Months'),
          primaryXAxis: const CategoryAxis(
            rangePadding: ChartRangePadding.none,
            labelPlacement: LabelPlacement.onTicks,
          ),
          primaryYAxis: const NumericAxis(
            labelFormat: '{value} USD',
          ),
          plotAreaBorderWidth: 0,
          margin: EdgeInsets.zero,
          series: [
            SplineAreaSeries<MonthlyRevenue, String>(
              dataSource: data,
              xValueMapper: (MonthlyRevenue revenue, _) => revenue.month,
              yValueMapper: (MonthlyRevenue revenue, _) => revenue.revenue,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                alignment: ChartAlignment.near,
                margin: EdgeInsets.all(10),
                labelAlignment: ChartDataLabelAlignment.top,
              ),
              dataLabelMapper: (MonthlyRevenue revenue, _) =>
                  '\$${revenue.revenue.toString().decimalPattern()}',
              name: 'Product A',
              color: Colors.lightGreen,
              borderColor: Colors.green,
              borderWidth: 2,
              splineType: SplineType.cardinal,
              markerSettings: const MarkerSettings(
                isVisible: true,
              ),
            ),
            SplineAreaSeries<MonthlyRevenue, String>(
              dataSource: data,
              xValueMapper: (MonthlyRevenue revenue, _) => revenue.month,
              yValueMapper: (MonthlyRevenue revenue, _) =>
                  revenue.reimbursement,
              name: 'Product C',
              color: Colors.blue.applyOpacity(0.7),
              borderColor: Colors.blue,
              borderWidth: 2,
              splineType: SplineType.cardinal,
              markerSettings: const MarkerSettings(
                isVisible: true,
                height: 6,
                width: 6,
              ),
            ),
            SplineAreaSeries<MonthlyRevenue, String>(
              dataSource: data,
              xValueMapper: (MonthlyRevenue revenue, _) => revenue.month,
              yValueMapper: (MonthlyRevenue revenue, _) => revenue.deduction,
              name: 'Product B',
              color: Colors.red.applyOpacity(0.9),
              borderColor: Colors.red,
              borderWidth: 2,
              splineType: SplineType.cardinal,
              markerSettings: const MarkerSettings(
                isVisible: true,
                height: 6,
                width: 6,
              ),
            ),
          ],
        ));
  }
}

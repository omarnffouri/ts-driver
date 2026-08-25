import 'package:intl/intl.dart';

class SettlementParams {
  final DateTime startDate;
  final DateTime endDate;

  SettlementParams({
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
        "start_date": DateFormat("yyyy-MM-dd").format(startDate),
        "end_date": DateFormat("yyyy-MM-dd").format(endDate),
      };
}

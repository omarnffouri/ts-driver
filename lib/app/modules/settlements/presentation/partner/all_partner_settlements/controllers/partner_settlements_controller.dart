import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/utils/date_utils.dart';
import 'package:ts_driver/app/modules/settlements/domain/params/settlments_params.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';

import '../../../../domain/entities/partner_settlement_data_entity.dart';
import '../../../../domain/usecases/get_all_partner_settlements_usecase.dart';
import '../views/components/year_month_week_picker_bottom_sheet.dart';

class PartnerSettlementsController extends GetxController {
  final authController = Get.put<AuthController>(AuthController());
  final getAllPartnerSettlmentsUsecase = sl<GetAllPartnerSettlmentsUsecase>();
  final pageController = PageController(initialPage: 0);

  final yearsList = [
    2018,
    2019,
    2020,
    2021,
    2022,
    2023,
    2024,
    2025,
    2026,
    2027,
    2028,
    2029
  ];
  final monthsList = [
    'All',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  final weeksList = ['All', 'Week 1', 'Week 2', 'Week 3', 'Week 4'];

  //  states
  final selectedYear = 0.obs;
  final selectedMonth = 0.obs;
  final selectedWeek = 0.obs;

  final currentYear = 0.obs;
  final currentMonth = 0.obs;
  final currentWeek = 0.obs;

  // var settlementsDataList = RxList<SettlementsPresentableEntity>();
  var settlementsData = Rxn<SettlementsPresentableEntity>();
  var partnerSettlements = RxList<PartnerSettlementEntity>();
  // api calling loading state
  final _isLoadingSettlements = false.obs;
  bool get isLoadingSettlements => _isLoadingSettlements.value;

  //
  final _isLoadingSettlementsFailed = false.obs;
  bool get isLoadingSettlementsFailed => _isLoadingSettlementsFailed.value;

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  final RxInt expandedIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    _init();
    applyDateFilter();
  }

  _init() {
    final now = DateTime.now();
    final cuurentYearIndex = yearsList.indexWhere(
      (element) => element == now.year,
    );
    currentYear.value = cuurentYearIndex;
    selectedYear.value = cuurentYearIndex;
  }

  applyDateFilter() {
    selectedYear.value = currentYear.value;
    selectedMonth.value = currentMonth.value;
    if (selectedMonth.value == 0) {
      selectedWeek.value = 0;
    } else {
      selectedWeek.value = currentWeek.value;
    }

    int year = yearsList[selectedYear.value];
    int month = selectedMonth.value;
    int week = selectedWeek.value;

    DateTimeRange dateRange = _calculateDateRange(year, month, week);
    _getAllSettlements(dateRange.start, dateRange.end);
  }

  Future<void> _getAllSettlements(DateTime startDate, DateTime endDate) async {
    partnerSettlements.clear();
    settlementsData.value = null;
    try {
      _isLoadingSettlements(true);
      _isLoadingSettlementsFailed(false);
      final result = await getAllPartnerSettlmentsUsecase
          .call(SettlementParams(startDate: startDate, endDate: endDate));
      result.fold((List<PartnerSettlementEntity> response) {
        response.sort((b, a) => a.batchDateTo!.compareTo(b.batchDateTo!));
        partnerSettlements.addAll(response);
        debugPrint('Settlements length: ${response.length}');
        filterAndLoadData(response);

        //
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
        _isLoadingSettlementsFailed(true);
      });
      _isLoadingSettlements(false);
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isLoadingSettlements(false);
      _isLoadingSettlementsFailed(true);
    }
  }

  SettlementsPresentableEntity? filterAndLoadData(
      List<PartnerSettlementEntity> parentSettlements) {
    if (parentSettlements.isEmpty == true) {
      return null;
    }

    final data = _transformToPresentable(parentSettlements);
    if (data.isNotEmpty) {
      // Merge all year groups into a single presentable entity
      final allMonths = data.expand((e) => e.months).toList();
      settlementsData.value = SettlementsPresentableEntity(
        year: data.map((e) => e.year).join(', '),
        months: allMonths,
      );
    }

    return settlementsData.value;
  }

  List<SettlementsPresentableEntity> _transformToPresentable(
      List<PartnerSettlementEntity>? settlements) {
    if (settlements == null || settlements.isEmpty) {
      return [];
    }
    // Group settlements by year
    Map<String, List<PartnerSettlementEntity>> settlementsByYear = {};
    for (var settlement in settlements) {
      String year = settlement.createAt!.year.toString();
      settlementsByYear.putIfAbsent(year, () => []).add(settlement);
    }

    // Transform settlements into presentable model
    List<SettlementsPresentableEntity> presentableModels = [];
    settlementsByYear.forEach((year, yearSettlements) {
      List<SettlementsMonthEntity> monthModels =
          _transformToMonthModels(yearSettlements);
      presentableModels
          .add(SettlementsPresentableEntity(year: year, months: monthModels));
    });

    return presentableModels;
  }

  List<SettlementsMonthEntity> _transformToMonthModels(
      List<PartnerSettlementEntity> settlements) {
    // Group settlements by month
    Map<String, List<PartnerSettlementEntity>> settlementsByMonth = {};
    for (var settlement in settlements) {
      String month = DateTimeUtils.getMonthName(settlement.createAt!.month);
      settlementsByMonth.putIfAbsent(month, () => []).add(settlement);
    }

    // Transform settlements into month model
    List<SettlementsMonthEntity> monthModels = [];
    settlementsByMonth.forEach((month, monthSettlements) {
      List<SettlementsWeekEntity> weekModels =
          _transformToWeekModels(monthSettlements);
      monthModels.add(SettlementsMonthEntity(month: month, weeks: weekModels));
    });

    return monthModels;
  }

  List<SettlementsWeekEntity> _transformToWeekModels(
      List<PartnerSettlementEntity> settlements) {
    // Group settlements by week (starting from Saturday)
    Map<String, List<PartnerSettlementEntity>> settlementsByWeek = {};
    for (var settlement in settlements) {
      String week = DateTimeUtils.getWeekName(settlement.createAt!);
      settlementsByWeek.putIfAbsent(week, () => []).add(settlement);
    }

    // Transform settlements into week model
    List<SettlementsWeekEntity> weekModels = [];
    settlementsByWeek.forEach((week, weekSettlements) {
      final weekRange =
          DateTimeUtils.getWeekDateRangeofDate(weekSettlements[0].createAt!);
      weekModels.add(SettlementsWeekEntity(
          week: week,
          start: weekRange.start,
          end: weekRange.end,
          settlements: weekSettlements));
    });

    return weekModels;
  }

  String formatDate(DateTime dateTime) {
    final formatter = DateFormat('MMM - d - y');
    return formatter.format(dateTime);
  }

  List<PartnerSettlementEntity> flattenListOfSettlemetsOfMonth(
      SettlementsMonthEntity settlementsMonthEntity) {
    //
    //
    Map<String, int> duplicateWeeks = {};
    List<PartnerSettlementEntity> flattenedList = [];
    for (var week in settlementsMonthEntity.weeks) {
      //
      // if week settelments are more then one then add a numbring with week names
      if (week.settlements.length > 1) {
        for (int i = 0; i < week.settlements.length; i++) {
          final weekNumber = getWeekNumber(week.settlements[i].batchDateFrom!);

          if (week.settlements[i].type == "owner_operator") {
            week.settlements[i].weekName = 'Week $weekNumber';
          } else if (duplicateWeeks[weekNumber.toString()] != null) {
            duplicateWeeks[weekNumber.toString()] =
                (duplicateWeeks[weekNumber.toString()]! + 1);
            week.settlements[i].weekName =
                'Week $weekNumber (${duplicateWeeks[weekNumber.toString()]})';
          } else {
            duplicateWeeks[weekNumber.toString()] = 1;
            week.settlements[i].weekName = 'Week $weekNumber';
          }
        }
      }
      flattenedList.addAll(week.settlements);
    }
    return flattenedList;
  }

  yearMonthWeekDropdownClicked() {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return const SafeArea(child: YearMonthWeekPickerBottomSheet());
      },
    );
  }

  int getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = numOfWeeks(date.year - 1);
    } else if (woy > numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
  }

  // get week number from date
  int numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  DateTimeRange _calculateDateRange(
      int selectedYear, int selectedMonth, int selectedWeek) {
    DateTime firstDay;
    DateTime lastDay;

    // If selectedMonth is 0, consider the whole year else take start and end date of month
    if (selectedMonth == 0) {
      firstDay = DateTime(selectedYear, 1, 1);
      lastDay = DateTime(selectedYear, 12, 31, 23, 59, 59, 999, 999);
    } else {
      firstDay = DateTime(selectedYear, selectedMonth, 1);
      lastDay =
          DateTime(selectedYear, selectedMonth + 1, 0, 23, 59, 59, 999, 999);
    }

    // If selectedWeek is 0, consider the whole month as it is
    if ((selectedMonth != 0) && selectedWeek != 0) {
      // Calculate the first day of the desired week (Saturday)
      firstDay = firstDay.add(Duration(days: (selectedWeek - 1) * 7));

      // Adjust to Saturday
      while (firstDay.weekday != DateTime.saturday) {
        firstDay = firstDay.add(const Duration(days: 1));
      }

      // Calculate the last day of the week (Friday)
      lastDay = firstDay.add(const Duration(days: 6));

      // Adjust to Friday
      while (lastDay.weekday != DateTime.friday) {
        lastDay = lastDay.subtract(const Duration(days: 1));
      }

      // Adjust the time to the end of the day
      lastDay = DateTime(
          lastDay.year, lastDay.month, lastDay.day, 23, 59, 59, 999, 999);
    }

    return DateTimeRange(start: firstDay, end: lastDay);
  }
}

class SettlementsPresentableEntity {
  final String year;
  final List<SettlementsMonthEntity> months;

  SettlementsPresentableEntity({required this.year, required this.months});
}

class SettlementsMonthEntity {
  final String month;
  final List<SettlementsWeekEntity> weeks;
  final ExpansibleController tileController = ExpansibleController();

  SettlementsMonthEntity({required this.month, required this.weeks});
}

class SettlementsWeekEntity {
  final String week;
  final DateTime start;
  final DateTime end;
  final List<PartnerSettlementEntity> settlements;

  SettlementsWeekEntity({
    required this.week,
    required this.start,
    required this.end,
    required this.settlements,
  });
}

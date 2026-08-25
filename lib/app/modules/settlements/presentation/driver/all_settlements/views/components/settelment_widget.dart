import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/settlements/domain/entities/settlement_data_entiity.dart';
import 'package:ts_driver/app/modules/settlements/presentation/driver/all_settlements/controllers/settlements_controller.dart';
// import 'package:ts_driver/app/core/widgets/file_viewer.dart';
import 'package:ts_driver/app/routes/app_pages.dart';

class SettelementWidget extends GetView<SettlementsController> {
  final SettlementDataEntity settelment;
  const SettelementWidget({required this.settelment, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //! go to details screen
        Get.toNamed(Routes.SETTLEMENT_DETAILS, arguments: settelment);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: context.tileColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // week number
            Text(
              // "Week ${controller.getWeekNumber(settelment.toDate!).toString()}",
              "${settelment.weekName ?? "Week ${controller.getWeekNumber(settelment.toDate!).toString()}"} ${settelment.type == "owner_operator" ? " - Truck ${settelment.truckId ?? ""}" : ""}",
              style: const TextStyle(
                color: kMainColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            Row(
              children: [
                // from date
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        "From: ",
                        style: TextStyle(fontSize: 12),
                      ),
                      Expanded(
                        child: Text(
                          DateFormat('MMM-dd-yyyy')
                              .format(settelment.fromDate!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: context.primaryTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

                //
                // to date
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        "To: ",
                        style: TextStyle(fontSize: 12),
                      ),
                      Expanded(
                        child: Text(
                          DateFormat('MMM-dd-yyyy').format(settelment.toDate!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: context.primaryTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

            // file icon and name
            Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 25,
                  color: kMainColor,
                ),

                //
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        settelment.name ?? "",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: context.primaryTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ).marginOnly(left: 5),
                      Text(
                        settelment.settlementNumber ?? "15",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: context.primaryTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ).marginOnly(left: 10)
                    ],
                  ),
                ),
              ],
            ).marginOnly(top: 5),
          ],
        ),
      ),
    ).marginSymmetric(vertical: 5);
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/modules/forms/domain/entities/form_entity.dart';
import 'package:ts_driver/app/modules/forms/presintation/controllers/forms_controller.dart';

class FormAttachmentItemView extends GetView<FormsController> {
  final FormAttachmentEntity attachment;
  final int index;
  final String attachmentType;
  const FormAttachmentItemView({
    super.key,
    required this.attachment,
    required this.index,
    required this.attachmentType,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: [
        //
        //
        // icon

        Image.asset(
          controller.getAttachmentIcon(attachment.url),
          width: 25,
          height: 25,
        ).marginOnly(right: 5),

        //
        // video name
        Expanded(
          child: Text(
            attachment.title ?? "",
            style: theme.textTheme.titleMedium?.copyWith(
              color: attachment.seenAt == null
                  ? AppColorsLight.mainColor
                  : Colors.green,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        (controller.isUpdatingAttachmentStatus &&
                (controller.updatingAttachmentStatusAtIndex.value == index) &&
                (controller.updatingAttachmentStatusType.value ==
                    attachmentType))
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColorsLight.mainColor,
                  strokeCap: StrokeCap.round,
                ),
              ).marginOnly(left: 5)
            : attachment.seenAt == null
                ? Container(
                    margin: const EdgeInsets.only(left: 5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: AppColorsLight.mainColor,
                        borderRadius: BorderRadius.circular(999)),
                    child: const Text(
                      "Read me",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  )
                : Icon(
                    Icons.remove_red_eye_rounded,
                    size: 24,
                    color:
                        attachment.seenAt == null ? Colors.red : Colors.green,
                  ).marginOnly(left: 5)
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../domain/entities/form_entity.dart';
import '../../controllers/forms_controller.dart';
import 'form_field_row.dart';

class FormBody extends GetView<FormsController> {
  const FormBody({
    super.key,
    required this.formModel,
  });

  final FormEntity formModel;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formModel.formGlobalKey,
      child: ScrollablePositionedList.builder(
        itemScrollController: controller.scrollController,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: formModel.formFields?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          final FormFieldEntity formField = formModel.formFields![index];

          if (formModel.formFields![index].formFieldsValue?.value.isNotEmpty ??
              false) {
            formField.textEditingController.text =
                formModel.formFields![index].formFieldsValue!.value;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FormFieldRow(
              formId: formModel.formId!,
              formField: formField,
              fieldType: formField.type!,
              onSubmit: () {
                controller.onSubmitTextField(index);
              },
            ),
          );
        },
      ),
    ).marginSymmetric(horizontal: 10);
  }
}

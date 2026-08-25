import 'package:flutter/material.dart';

class AccidentReviewFormData {
  final TextEditingController dateController;
  final TextEditingController descriptionController;
  final TextEditingController fatalitiesController;
  final TextEditingController injuriesController;
  String vehicleType;

  AccidentReviewFormData({
    TextEditingController? dateController,
    TextEditingController? descriptionController,
    TextEditingController? fatalitiesController,
    TextEditingController? injuriesController,
    this.vehicleType = '',
  })  : dateController = dateController ?? TextEditingController(),
        descriptionController =
            descriptionController ?? TextEditingController(),
        fatalitiesController = fatalitiesController ?? TextEditingController(),
        injuriesController = injuriesController ?? TextEditingController();

  void dispose() {
    dateController.dispose();
    descriptionController.dispose();
    fatalitiesController.dispose();
    injuriesController.dispose();
  }

  Map<String, dynamic> toJson() {
    return {
      "accident_date": dateController.text,
      "accident_description": descriptionController.text,
      "accident_fatalities": fatalitiesController.text,
      "accident_injuries": injuriesController.text,
      "accident_vehicle_type": vehicleType,
    };
  }
}

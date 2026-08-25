import 'package:flutter/material.dart';

class TrafficConvictionFormData {
  final TextEditingController dateController;
  final TextEditingController descriptionController;
  final TextEditingController fatalitiesController;
  final TextEditingController injuriesController;
  String vehicleType;

  TrafficConvictionFormData({
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
      "traffic_conviction_date": dateController.text,
      "traffic_conviction_description": descriptionController.text,
      "traffic_conviction_fatalities": fatalitiesController.text,
      "traffic_conviction_injuries": injuriesController.text,
      "traffic_conviction_vehicle_type": vehicleType,
    };
  }
}

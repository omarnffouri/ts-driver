import 'package:get/get.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';

import '../../auth/domain/entities/user_entity.dart';

class PartnerFormsViewController extends GetxController {
  final Rx<UserEntity> _user = Get.find<AuthController>().user;
  UserEntity get user => _user.value;
}

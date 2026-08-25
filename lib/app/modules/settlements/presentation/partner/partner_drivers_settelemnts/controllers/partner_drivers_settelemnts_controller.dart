import 'package:get/get.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';
import 'package:ts_driver/app/modules/settlements/domain/entities/partner_driver_entity.dart';
import 'package:ts_driver/app/modules/settlements/domain/params/update_partner_driver_permission_params.dart';
import 'package:ts_driver/app/modules/settlements/domain/usecases/get_partner_drivers_usecase.dart';
import 'package:ts_driver/app/modules/settlements/domain/usecases/update_parnter_driver_value_usecase.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';

class PartnerDriversSettelemntsController extends GetxController {
  final getPartnerDriversUseCase = sl<GetPartnerDriversUseCase>();
  final updateDriverPermissionValueUsecase =
      sl<UpdatePartnerDriverStateUsecase>();

  final partnerDrivers = RxList<PartnerDriverEntity>();
  final isLoading = false.obs;
  final updatingDriverId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    loadPartnerDrivers();
  }

  Future<void> loadPartnerDrivers() async {
    isLoading(true);
    partnerDrivers.clear();

    try {
      final result = await getPartnerDriversUseCase(const NoParams());
      result.fold(
        (list) => partnerDrivers.assignAll(list),
        (failure) => CommonWidgets.showSnackBar(
          title: 'Error',
          message: failure.message,
        ),
      );
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> toggleSwitch(int index, bool value) async {
    final driver = partnerDrivers[index];
    final oldValue = driver.canViewSettlements;

    partnerDrivers[index] = PartnerDriverEntity(
      id: driver.id,
      name: driver.name,
      canViewSettlements: value ? 1 : 0,
    );

    final result = await updateDriverPermissionValueUsecase.call(
      UpdatePartnerDriverStateParams(
        applicantId: driver.id,
        canViewSettlements: value ? 1 : 0,
      ),
    );

    result.fold(
      (_) {},
      (failure) {
        partnerDrivers[index] = PartnerDriverEntity(
          id: driver.id,
          name: driver.name,
          canViewSettlements: oldValue,
        );

        CommonWidgets.showSnackBar(
          title: 'Error',
          message: failure.message,
        );
      },
    );
  }
}

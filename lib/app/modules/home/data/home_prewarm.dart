import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';
import 'package:ts_driver/app/modules/home/domain/entities/applicant_state_entity.dart';
import 'package:ts_driver/app/modules/home/domain/usecases/get_applicant_usecase.dart';

/// Pre-fetches the home applicant state during the splash window so the
/// entrance reveal opens onto a populated home. Splash calls [warm];
/// [HomeController] consumes it once via [take] in `onInit`.
class HomePrewarm {
  HomePrewarm._();

  static ApplicantStateEntity? _applicantState;

  /// Fetches and caches the applicant state. Safe to await; never throws.
  static Future<void> warm() async {
    try {
      final result = await sl<GetApplicantUsecase>()(const NoParams());
      // Reversed Either: Left = success value, Right = Failure.
      result.fold((state) => _applicantState = state, (_) {});
    } catch (_) {/* best-effort; home falls back to its normal load */}
  }

  /// Returns the prewarmed state once, then clears it.
  static ApplicantStateEntity? take() {
    final state = _applicantState;
    _applicantState = null;
    return state;
  }
}

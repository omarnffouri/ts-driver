import 'package:get/get.dart';

import '../core/transitions/circular_reveal_transition.dart';
import '../modules/inspections/presentation/trailer_inspection/bindings/inspection_binding.dart';
import '../modules/inspections/presentation/trailer_inspection/views/inspection_view.dart';
import '../modules/annoucments/presentation/bindings/annoucments_binding.dart';
import '../modules/annoucments/presentation/views/annoucments_view.dart';
import '../modules/auth/presentation/login/bindings/login_binding.dart';
import '../modules/auth/presentation/login/views/login_view.dart';
import '../modules/auth/presentation/otp/bindings/otp_binding.dart';
import '../modules/auth/presentation/otp/views/otp_view.dart';
import '../modules/auth/presentation/register/bindings/register_binding.dart';
import '../modules/auth/presentation/register/views/register_view.dart';
import '../modules/chat/presentation/conversations/bindings/conversations_binding.dart';
import '../modules/chat/presentation/conversations/views/conversations_view.dart';
import '../modules/chat/presentation/group_conversations/bindings/group_conversations_binding.dart';
import '../modules/chat/presentation/group_conversations/views/group_conversations_view.dart';
import '../modules/chat/presentation/oto_conversations/bindings/oto_conversations_binding.dart';
import '../modules/chat/presentation/oto_conversations/views/oto_conversations_view.dart';
import '../modules/chat_detail/presentation/bindings/chat_detail_binding.dart';
import '../modules/chat_detail/presentation/views/chat_detail_view.dart';
import '../modules/documents/presentation/bindings/documents_binding.dart';
import '../modules/documents/presentation/views/documents_view.dart';
import '../modules/forms/presintation/bindings/forms_binding.dart';
import '../modules/forms/presintation/views/forms_view.dart';
import '../modules/forward_message/bindings/forward_message_binding.dart';
import '../modules/forward_message/views/forward_message_view.dart';
import '../modules/home/presentation//bindings/home_binding.dart';
import '../modules/home/presentation//views/home_view.dart';
import '../modules/main_screen/bindings/main_screen_binding.dart';
import '../modules/main_screen/views/main_screen_view.dart';
import '../modules/map/bindings/map_binding.dart';
import '../modules/map/views/map_view.dart';
import '../modules/media_picker_previewer/bindings/media_picker_previewer_binding.dart';
import '../modules/media_picker_previewer/views/media_picker_previewer_view.dart';
import '../modules/notifications/presentation/bindings/notifications_binding.dart';
import '../modules/notifications/presentation/views/notifications_view.dart';
import '../modules/settlements/presentation/partner/partner_drivers_settelemnts/bindings/partner_drivers_settelemnts_binding.dart';
import '../modules/settlements/presentation/partner/partner_drivers_settelemnts/views/partner_drivers_settelemnts_view.dart';
import '../modules/partner_forms_view/bindings/partner_forms_view_binding.dart';
import '../modules/partner_forms_view/views/partner_forms_view_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile_add_accident_history/bindings/profile_add_accident_history_binding.dart';
import '../modules/profile_add_accident_history/views/profile_add_accident_history_view.dart';
import '../modules/profile_details/bindings/profile_details_binding.dart';
import '../modules/profile_details/views/profile_details_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/settlements/presentation/driver/all_settlements/bindings/settlements_binding.dart';
import '../modules/settlements/presentation/driver/all_settlements/views/settlements_view.dart';
import '../modules/settlements/presentation/driver/settlement_details/bindings/settlement_details_binding.dart';
import '../modules/settlements/presentation/driver/settlement_details/views/settlement_details_view.dart';
import '../modules/settlements/presentation/partner/all_partner_settlements/bindings/partner_settlements_binding.dart';
import '../modules/settlements/presentation/partner/all_partner_settlements/views/partner_settlements_view.dart';
import '../modules/settlements/presentation/partner/partner_settlement_details/bindings/partner_settlement_details_binding.dart';
import '../modules/settlements/presentation/partner/partner_settlement_details/views/partner_settlement_details_view.dart';
import '../modules/shipments/presentation/bindings/shipments_binding.dart';
import '../modules/shipments/presentation/views/shipments_view.dart';
import '../modules/signed_forms/bindings/signed_forms_binding.dart';
import '../modules/signed_forms/views/signed_forms_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/inspections/presentation/truck_inspection/bindings/truck_inspection_binding.dart';
import '../modules/inspections/presentation/truck_inspection/views/truck_inspection_view.dart';
import '../modules/vehicle_documents/presentation/bindings/vehicle_documents_binding.dart';
import '../modules/vehicle_documents/presentation/views/vehicle_documents_view.dart';
import '../modules/videos/presentation/video_player/bindings/video_player_binding.dart';
import '../modules/videos/presentation/video_player/views/video_player_view.dart';
import '../modules/videos/presentation/videos/bindings/videos_binding.dart';
import '../modules/videos/presentation/videos/views/videos_view.dart';

// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.MAIN_SCREEN,
      page: () => const MainScreenView(),
      binding: MainScreenBinding(),
      // Entrance style is chosen per-navigation via route args. Leave
      // `transition` unset so GetX uses this CustomTransition.
      customTransition: const CircularRevealTransition(),
      transitionDuration: const Duration(milliseconds: 1500),
    ),
    GetPage(
      name: _Paths.SETTLEMENTS,
      page: () => const SettlementsView(),
      binding: SettlementsBinding(),
    ),
    GetPage(
      name: _Paths.SHIPMENTS,
      page: () => const ShipmentsView(),
      binding: ShipmentsBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_DETAILS,
      page: () => const ProfileDetailsView(),
      binding: ProfileDetailsBinding(),
    ),
    GetPage(
      name: _Paths.FORMS,
      page: () => const FormsView(),
      binding: FormsBinding(),
    ),
    GetPage(
      name: _Paths.DOCUMENTS,
      page: () => const DocumentsView(),
      binding: DocumentsBinding(),
    ),
    GetPage(
      name: _Paths.SIGNED_FORMS,
      page: () => const SignedFormsView(),
      binding: SignedFormsBinding(),
    ),
    GetPage(
      name: _Paths.VIDEOS,
      page: () => const VideosView(),
      binding: VideosBinding(),
    ),
    GetPage(
      name: _Paths.VIDEO_PLAYER,
      page: () => const VideoPlayerView(),
      binding: VideoPlayerBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_ADD_ACCIDENT_HISTORY,
      page: () => const ProfileAddAccidentHistoryView(),
      binding: ProfileAddAccidentHistoryBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_DETAIL,
      page: () => const ChatDetailView(),
      binding: ChatDetailBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.CONVERSATIONS,
      page: () => const ConversationsView(),
      binding: ConversationsBinding(),
    ),
    GetPage(
      name: _Paths.MAP,
      page: () => const MapView(),
      binding: MapBinding(),
    ),
    GetPage(
      name: _Paths.INSPECTION,
      page: () => const InspectionView(),
      binding: InspectionBinding(),
    ),
    GetPage(
      name: _Paths.TRUCK_INSPECTION,
      page: () => const TruckInspectionView(),
      binding: TruckInspectionBinding(),
    ),
    GetPage(
      name: _Paths.TRUCK_DOCUMENTS,
      page: () => const VehicleDocumentsView(),
      binding: VehicleDocumentsBinding(),
    ),
    GetPage(
      name: _Paths.FORWARD_MESSAGE,
      page: () => const ForwardMessageView(),
      binding: ForwardMessageBinding(),
    ),
    GetPage(
      name: _Paths.PARTNER_SETTLEMENTS,
      page: () => const PartnerSettlementsView(),
      binding: PartnerSettlementsBinding(),
    ),
    GetPage(
      name: _Paths.PARTNER_FORMS_VIEW,
      page: () => const PartnerFormsViewView(),
      binding: PartnerFormsViewBinding(),
    ),
    GetPage(
      name: _Paths.ANNOUCMENTS,
      page: () => const AnnoucmentsView(),
      binding: AnnoucmentsBinding(),
    ),
    GetPage(
      name: _Paths.OTO_CONVERSATIONS,
      page: () => const OtoConversationsView(),
      binding: OtoConversationsBinding(),
    ),
    GetPage(
      name: _Paths.GROUP_CONVERSATIONS,
      page: () => const GroupConversationsView(),
      binding: GroupConversationsBinding(),
    ),
    GetPage(
      name: _Paths.OTP,
      page: () => const OtpView(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: _Paths.SETTLEMENT_DETAILS,
      page: () => const SettlementDetailsView(),
      binding: SettlementDetailsBinding(),
    ),
    GetPage(
      name: _Paths.PARTNER_SETTLEMENT_DETAILS,
      page: () => const PartnerSettlementDetailsView(),
      binding: PartnerSettlementDetailsBinding(),
    ),
    GetPage(
      name: _Paths.MEDIA_PICKER_PREVIEWER,
      page: () => const MediaPickerPreviewerView(),
      binding: MediaPickerPreviewerBinding(),
    ),
    GetPage(
      name: _Paths.PARTNER_DRIVERS_SETTELEMNTS,
      page: () => const PartnerDriversSettelemntsView(),
      binding: PartnerDriversSettelemntsBinding(),
    ),
  ];
}

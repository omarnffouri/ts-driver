import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart'
    hide ServiceStatus;
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/enum/access_level.dart';
import 'package:ts_driver/app/core/helpers/voip_helper.dart';
import 'package:ts_driver/app/core/helpers/permission_helper.dart';
import 'package:ts_driver/app/core/widgets/location_service_dialog.dart';
import 'package:ts_driver/app/core/widgets/mic_permission_dialog.dart';
import 'package:ts_driver/app/modules/chat/presentation/conversations/views/conversations_view.dart';
import 'package:ts_driver/app/modules/chat/presentation/group_conversations/controllers/group_conversations_controller.dart';
import 'package:ts_driver/app/modules/chat/presentation/oto_conversations/controllers/oto_conversations_controller.dart';
import 'package:ts_driver/app/modules/home/domain/usecases/update_voip_token_usecase.dart';
import 'package:ts_driver/app/modules/home/presentation/views/home_view.dart';
import 'package:ts_driver/app/modules/main_screen/views/widgets/chat_nav_icon.dart';
import 'package:ts_driver/app/modules/partner_forms_view/views/partner_forms_view_view.dart';
import 'package:ts_driver/app/modules/profile/views/profile_view.dart';
import 'package:ts_driver/app/modules/settlements/presentation/driver/all_settlements/views/settlements_view.dart';
import 'package:ts_driver/app/modules/settlements/presentation/partner/all_partner_settlements/views/partner_settlements_view.dart';
import 'package:ts_driver/app/modules/shipments/presentation/views/shipments_view.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class MainScreenController extends GetxController with WidgetsBindingObserver {
  // --- UI State ---
  final tabController = PersistentTabController(initialIndex: 0).obs;
  // --- Dependency Injection ---
  final updateVoipTokenUsecase = sl<UpdateVoipTokenUsecase>();
  // --- Lifecycle State ---
  final Rx<AppLifecycleState> appState = AppLifecycleState.resumed.obs;
  // --- Auth and Access ---
  final AuthController authController = Get.find<AuthController>();
  // --- Chat Badge ---
  final unreadCounts = 0.obs;
  StreamSubscription<ServiceStatus>? _locationServiceSubscription;

  // Completes once the entrance transition finishes, so child controllers can
  // defer first-load work until after the animation. See [HomeController.onInit].
  final Completer<void> _entered = Completer<void>();
  Future<void> get entered => _entered.future;
  void markEntered() {
    if (!_entered.isCompleted) _entered.complete();
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _checkForLocationService();
    _locationServiceSubscription =
        Geolocator.getServiceStatusStream().listen((event) {
      if (event == ServiceStatus.disabled) {
        _showLocationServiceDialog();
        return;
      }
      // Only dismiss the LocationServiceDialog itself — never other dialogs
      // (e.g. the mic permission dialog).
      if (_isLocationServiceDialogOpen && (Get.isDialogOpen ?? false)) {
        Get.back();
      }
    });
    _fetchAndUpdateVoipToken();
  }

  @override
  void onReady() {
    super.onReady();
    _checkMicPermissionForCalls();
  }

  /// Shows an explainer dialog when landing on the main screen after login if
  /// the microphone permission hasn't been granted yet — without it the user
  /// cannot receive calls.
  Future<void> _checkMicPermissionForCalls() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      final status = await Permission.microphone.status;
      if (status.isGranted || status.isLimited) {
        return;
      }

      // don't stack on top of another dialog (e.g. LocationServiceDialog)
      if (Get.isDialogOpen ?? false) {
        return;
      }

      final proceed = await Get.dialog<bool>(
        const MicPermissionDialog(),
        barrierDismissible: false,
      );

      if (proceed != true) {
        return;
      }

      // haveMicPermission fires the native prompt and shows the
      // "open settings" dialog if the permission ends up denied
      await PermissionHelper.haveMicPermission(
        "You need to allow microphone access to receive and make calls.",
      );
    } catch (e) {
      debugPrint('Error checking mic permission: $e');
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationServiceSubscription?.cancel();
    super.onClose();
  }

  List<PersistentTabConfig> getTabs() {
    final accessLevel = authController.accessLevel.value;

    if (accessLevel == AccessLevel.partnerOnly) {
      return [
        PersistentTabConfig(
          screen: const PartnerSettlementsView(),
          item: _buildNavItem("Pay", Assets.svg.settlement),
        ),
        PersistentTabConfig(
          screen: const PartnerFormsViewView(),
          item: _buildNavItem("Forms", Assets.svg.forms),
        ),
      ];
    }
    final baseTabs = <PersistentTabConfig>[
      PersistentTabConfig(
        screen: const HomeView(),
        item: _buildNavItem("Home", Assets.svg.home),
      ),
      PersistentTabConfig(
        screen: const ShipmentsView(),
        item: _buildNavItem("Trips", Assets.svg.shipments),
      ),
      PersistentTabConfig(
        screen: const ConversationsView(),
        item: _buildNavItem("Chat", Assets.svg.chat, showUnreadBadge: true),
      ),
      PersistentTabConfig(
        screen: const ProfileView(),
        item: _buildNavItem("Profile", Assets.svg.profile),
      ),
    ];

    // Add settlements tab only if user can view settlements
    if (authController.user.value.canViewSettlements) {
      baseTabs.insert(
        2,
        PersistentTabConfig(
          screen: accessLevel == AccessLevel.both
              ? const PartnerSettlementsView()
              : const SettlementsView(),
          item: _buildNavItem("Pay", Assets.svg.settlement),
        ),
      );
    }

    return baseTabs;
  }

  ItemConfig _buildNavItem(
    String title,
    String icon, {
    bool showUnreadBadge = false,
  }) {
    final RxInt? unreadCount = showUnreadBadge ? unreadCounts : null;
    return ItemConfig(
      icon: BottomNavIcon(
        iconPath: icon,
        isActive: true,
        showUnreadBadge: showUnreadBadge,
        unreadCount: unreadCount,
      ),
      inactiveIcon: BottomNavIcon(
        iconPath: icon,
        isActive: false,
        showUnreadBadge: showUnreadBadge,
        unreadCount: unreadCount,
      ),
      title: title,
      textStyle: const TextStyle(fontWeight: FontWeight.w500),
      activeForegroundColor: AppColorsLight.white,
      activeColorSecondary: AppColorsLight.mainColor,
      inactiveForegroundColor: AppColorsLight.senderCallColor,
    );
  }

  Future<void> _checkForLocationService() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _showLocationServiceDialog();
    }
  }

  /// Tracks whether [LocationServiceDialog] is currently showing, so the
  /// service-status stream only dismisses that dialog and not whatever else
  /// happens to be on top (e.g. the mic permission dialog).
  bool _isLocationServiceDialogOpen = false;

  void _showLocationServiceDialog() {
    if (_isLocationServiceDialogOpen || (Get.isDialogOpen ?? false)) return;
    _isLocationServiceDialogOpen = true;
    Get.dialog(const LocationServiceDialog()).whenComplete(() {
      _isLocationServiceDialogOpen = false;
    });
  }

  Future<void> _fetchAndUpdateVoipToken() async {
    if (!Platform.isIOS) return;

    try {
      final token = await VoipHelper.fetchVoipToken();
      if (token.isEmpty) return;

      //
      // hit update voip token api
      final response = await updateVoipTokenUsecase.call(token);
      response.fold((successful) {
        debugPrint("Voip update response ====> $successful");
      }, (failure) {
        debugPrint("Failure while updating voip token ===> ${failure.message}");
      });
    } catch (e) {
      debugPrint("Error while hitting update voip token api ===> $e");
    }
  }

  void updateUnreadMessageCounts() {
    unreadCounts.value = 0;

    //
    // getting unread counts from one to one conversation
    try {
      if (Get.isRegistered<OtoConversationsController>()) {
        unreadCounts.value =
            Get.find<OtoConversationsController>().otoUnreadCounts.value;
      }
    } catch (_) {}

    //
    // getting unread counts from group conversation
    try {
      if (Get.isRegistered<GroupConversationsController>()) {
        unreadCounts.value +=
            Get.find<GroupConversationsController>().groupUnreadCounts.value;
      }
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    appState.value = state;
  }
}

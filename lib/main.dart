import 'dart:async';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'flavors.dart';
import 'app/core/data/connection/api_constants.dart';
import 'app/core/data/connection/environments.dart';
import 'app/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/core/services/firebase/default_firebase_options.dart';
import 'app/core/services/injection_service.dart' as di;
import 'app/core/services/theme_service.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    F.appFlavor = Flavor.values.byName(Environment.current.flavorName);
    if (kDebugMode) {
      debugPrint('Flavor: ${F.name} | API: ${ApiConstants.kServerURL} | '
          'Firebase: ${DefaultFirebaseOptions.currentPlatform.projectId}');
    }
    // init DI
    await di.init();
    // init FCM
    await di.initFirebase();
    // init localDB
    await di.initLocalDb();
    // load persisted theme mode (after GetStorage is ready)
    await Get.find<ThemeService>().init();

    FlutterError.onError = (errorDetails) {
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      }
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
      return true;
    };

    runApp(Application());
  }, (e, st) {
    debugPrint('Error: ${e.toString()}\nStackTrace: ${st.toString()}');
  });
}

class Application extends StatelessWidget {
  Application({super.key});
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        title: F.title,
        color: kMainColor,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: Get.find<ThemeService>().mode,
        // Tap anywhere outside a focused field to dismiss the keyboard.
        builder: (context, child) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        ),
      ),
    );
  }
}

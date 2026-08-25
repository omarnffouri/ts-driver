import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/compressed_images_manager.dart';
import '../../modules/annoucments/data/datasources/annoucements_remote_datasource.dart';
import '../../modules/annoucments/data/repositories/annoucements_repository_impl.dart';
import '../../modules/annoucments/domain/repositories/annoucements_repository.dart';
import '../../modules/annoucments/domain/usecases/get_all_annoucements_usecase.dart';
import '../../modules/annoucments/domain/usecases/update_annoucement__read_status_usecase.dart';
import '../../modules/auth/data/datasources/auth_local_datasource.dart';
import '../../modules/auth/data/datasources/auth_remote_datasource.dart';
import '../../modules/auth/domain/usecases/get_app_configration_usecase.dart';
import '../../modules/auth/domain/usecases/get_cities_by_state_usecase.dart';
import '../../modules/auth/domain/usecases/get_realtime_configuration_usecase.dart';
import '../../modules/auth/domain/usecases/verify_register_otp_usecase.dart';
import '../../modules/chat_detail/domain/usecases/call_event_usecase.dart';
import '../../modules/chat_detail/data/datasources/send_message_remote_data_source.dart';
import '../../modules/chat_detail/data/repositories/send_message_repository_impl.dart';
import '../../modules/chat_detail/domain/repositories/send_message_repository.dart';
import '../../modules/chat_detail/domain/usecases/delete_message_usecase.dart';
import '../../modules/chat_detail/domain/usecases/forward_message_usecase.dart';
import '../../modules/chat_detail/domain/usecases/get_conversation_details_usercase.dart';
import '../../modules/chat_detail/domain/usecases/get_previous_messages_usecase.dart';
import '../../modules/chat_detail/domain/usecases/message_mark_as_read_usecase.dart';
import '../../modules/chat_detail/domain/usecases/react_message_usecase.dart';
import '../../modules/chat_detail/domain/usecases/send_file_message_usecase.dart';
import '../../modules/chat_detail/domain/usecases/send_text_message_usecase.dart';
import '../../modules/chat/data/data_sources/conversation_remote_data_source.dart';
import '../../modules/chat/data/repositories/conversation_repository.dart';
import '../../modules/chat/data/repositories/conversations_db_manager.dart';
import '../../modules/chat/domain/repositories/conversation_repository.dart';
import '../../modules/chat/domain/usecases/create_new_conversation_usecase.dart';
import '../../modules/chat/domain/usecases/get_all_contacts_usecase.dart';
import '../../modules/chat/domain/usecases/get_all_conversations_usecase.dart';
import '../../modules/chat/domain/usecases/get_all_group_conversations_usecase.dart';
import '../../modules/documents/data/datasources/document_remote_data_source.dart';
import '../../modules/documents/domain/usecases/get_all_documents_usecase.dart';
import '../../modules/documents/domain/usecases/upload_documents_usecase.dart';
import '../../modules/forms/data/datasources/form_remote_datasource.dart';
import '../../modules/forms/domain/usecases/update_form_attachment_status.dart';
import '../../modules/home/data/datasources/home_local_datasource.dart';
import '../../modules/home/data/datasources/home_remote_datasource.dart';
import '../../modules/home/data/repositories/home_repository_impl.dart';
import '../../modules/home/domain/repositories/home_repository.dart';
import '../../modules/home/domain/usecases/check_clock_in_usecase.dart';
import '../../modules/home/domain/usecases/clock_in_usecase.dart';
import '../../modules/home/domain/usecases/clock_out_usecase.dart';
import '../../modules/home/domain/usecases/get_applicant_usecase.dart';
import '../../modules/home/domain/usecases/update_voip_token_usecase.dart';
import '../../modules/settlements/data/data_sources/settlements_remote_data_source.dart';
import '../../modules/settlements/data/repositories/settlments_repository.dart';
import '../../modules/settlements/domain/repositories/settlments_repository.dart';
import '../../modules/settlements/domain/usecases/get_all_partner_settlements_usecase.dart';
import '../../modules/settlements/domain/usecases/get_partner_drivers_usecase.dart';
import '../../modules/settlements/domain/usecases/get_partner_settlement_details_usecase.dart';
import '../../modules/settlements/domain/usecases/get_all_settlements_usecase.dart';
import '../../modules/settlements/domain/usecases/get_settlement_details_usecase.dart';
import '../../modules/settlements/domain/usecases/update_parnter_driver_value_usecase.dart';
import '../../modules/shipments/domain/usecases/get_all_shipments_usecase.dart';
import '../../modules/shipments/domain/usecases/get_shipment_details_usecase.dart';
import '../../modules/shipments/domain/usecases/update_shipment_usecase.dart';
import '../../modules/shipments/domain/usecases/update_stop_status_usecase.dart';
import '../../modules/shipments/domain/usecases/complete_shipment_usecase.dart';
import '../../modules/inspections/domain/usecases/create_inspection_usecase.dart';
import '../../modules/inspections/domain/usecases/get_inspection_options_usecase.dart';
import '../../modules/vehicle_documents/data/datasources/vehicle_documents_local_datasource.dart';
import '../../modules/vehicle_documents/data/datasources/vehicle_documents_remote_datasource.dart';
import '../../modules/vehicle_documents/data/repositories/vehicle_documents_repository_impl.dart';
import '../../modules/vehicle_documents/domain/repositories/vehicle_documents_repository.dart';
import '../../modules/vehicle_documents/domain/usecases/get_trailer_documents_usecase.dart';
import '../../modules/vehicle_documents/domain/usecases/get_truck_documents_usecase.dart';

import '../../modules/auth/data/datasources/firebase_remote_datasource.dart';
import '../../modules/auth/data/repositories/auth_repository_impl.dart';
import '../../modules/auth/data/repositories/firebase_repository_impl.dart';
import '../../modules/auth/domain/repositories/auth_repository.dart';
import '../../modules/auth/domain/repositories/firebase_repository.dart';
import '../../modules/auth/domain/usecases/check_email_verification_usecase.dart';
import '../../modules/auth/domain/usecases/delete_account_usecase.dart';
import '../../modules/auth/domain/usecases/fetch_existing_profile_usecase.dart';
import '../../modules/auth/domain/usecases/firebase/send_user_location_usecase.dart';
import '../../modules/auth/domain/usecases/firebase/sign_in_to_firebase_usecase.dart';
import '../../modules/auth/domain/usecases/get_profile_usecase.dart';
import '../../modules/auth/domain/usecases/login_usecase.dart';
import '../../modules/auth/domain/usecases/logout_usecase.dart';
import '../../modules/auth/domain/usecases/otp_send_usecase.dart';
import '../../modules/auth/domain/usecases/otp_verify_usecase.dart';
import '../../modules/auth/domain/usecases/register_usecase.dart';
import '../../modules/auth/domain/usecases/update_fcm_token_usecase.dart';
import '../../modules/auth/domain/usecases/update_profile_usecase.dart';
import '../../modules/chat_detail/data/datasources/conversation_details_remote_data_source.dart';
import '../../modules/chat_detail/data/repositories/conversation_details_repository_impl.dart';
import '../../modules/chat_detail/data/repositories/messages_db_manager.dart';
import '../../modules/chat_detail/domain/repositories/conversation_details_repository.dart';
import '../../modules/chat_detail/presentation/controllers/pusher_manager.dart';
import '../../modules/documents/data/repositories/document_repository_impl.dart';
import '../../modules/documents/domain/repositories/document_repository.dart';
import '../../modules/forms/data/repositories/form_repository_impl.dart';
import '../../modules/forms/domain/repositories/form_repository.dart';
import '../../modules/forms/domain/usecases/get_all_forms_usecase.dart';
import '../../modules/forms/domain/usecases/get_all_signed_forms_usecase.dart';
import '../../modules/forms/domain/usecases/sign_form_usecase.dart';
import '../../modules/notifications/data/datasources/notification_remote_datasource.dart';
import '../../modules/notifications/data/repositories/notification_repository_impl.dart';
import '../../modules/notifications/domain/repositories/notification_repository.dart';
import '../../modules/notifications/domain/usecases/get_all_notifications_usecase.dart';
import '../../modules/notifications/domain/usecases/update_notification_usecase.dart';
import '../../modules/shipments/data/datasources/shipment_remote_datasource.dart';
import '../../modules/shipments/data/repositories/shipment_repository_impl.dart';
import '../../modules/shipments/domain/repositories/shipment_repository.dart';
import '../../modules/inspections/data/datasources/inspection_remote_datasource.dart';
import '../../modules/inspections/data/repositories/inspection_repository_impl.dart';
import '../../modules/inspections/domain/repositories/inspection_repository.dart';
import '../../modules/videos/data/datasources/video_remote_datasource.dart';
import '../../modules/videos/data/repositories/video_repository_impl.dart';
import '../../modules/videos/domain/repositories/video_repository.dart';
import '../../modules/videos/domain/usecases/get_all_videos_usecase.dart';
import '../../modules/videos/domain/usecases/update_video_usecase.dart';

import '../widgets/local_notification.dart';

import '../data/connection/dio_client.dart';
import '../data/connection/network_info.dart';
import 'firebase/default_firebase_options.dart';
import 'theme_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //*  Core
  initExternal();
  //* Datasources
  initDataSources();
  //* Repository
  initRepositories();
  //* Usecases
  initUsecases();
  // Registered eagerly but connects lazily via PusherManager.start().
  sl.registerLazySingleton<PusherManager>(() => PusherManager());
}

initExternal() async {
  sl.registerLazySingleton<INetworkInfo>(
      () => NetworkInfoImpl(dataConnectionChecker: sl()));
  sl.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker());
  sl.registerLazySingleton(() => DioClient());

  // chat messages db manager
  sl.registerSingletonAsync<MessagesDatabase>(
    () async {
      final messagesDatabase = MessagesDatabase();
      await messagesDatabase.database;
      return messagesDatabase;
    },
  );

  // conversations db manager
  sl.registerSingletonAsync<ConversationsDatabase>(
    () async {
      final conversationsDatabase = ConversationsDatabase();
      await conversationsDatabase.database;
      return conversationsDatabase;
    },
  );

  // register sharter preferences
  sl.registerSingletonAsync<SharedPreferences>(
    () async {
      final sharedPreferences = await SharedPreferences.getInstance();
      return sharedPreferences;
    },
  );

  await sl.allReady();

  await FlutterDownloader.initialize(
    // optional: set to false to disable printing logs to console (default: true)
    debug: false,
    // option: set to false to disable working with http links (default: false)
    ignoreSsl: true,
  );

  Get.put<CompressedImagesManager>(CompressedImagesManager(), permanent: true);

  // theme mode service (initialized in main() after local DB is ready)
  Get.put<ThemeService>(ThemeService(), permanent: true);
}

initDataSources() {
  //! Auth
  sl.registerLazySingleton<IAuthRemoteDataSource>(
    () => AuthRemoteDatasourceImpl(client: sl()),
  );
  sl.registerLazySingleton<IAuthLocalDataSource>(
    () => AuthLocalDatasourceImpl(),
  );
  //! Home
  sl.registerLazySingleton<IHomeRemoteDatasource>(
    () => HomeRemoteDatasourceImpl(client: sl()),
  );
  sl.registerLazySingleton<IHomeLocalDatasource>(
    () => HomeLocalDatasourceImpl(),
  );
  //! Document
  sl.registerLazySingleton<IDocumentRemoteDataSource>(
    () => DocumentRemoteDataSourceImpl(client: sl()),
  );
  //! Form
  sl.registerLazySingleton<IFormRemoteDataSource>(
    () => FormRemoteDataSourceImpl(client: sl()),
  );
  //! Videos
  sl.registerLazySingleton<IVideoRemoteDataSource>(
    () => VideoRemoteDataSourceImpl(client: sl()),
  );
  //! Firebase
  sl.registerLazySingleton<IFirebaseRemoteDataSource>(
    () => FirebaseRemoteDatasourceImpl(),
  );
  //! Chat
  sl.registerLazySingleton<IConversationDetailsRemoteDataSource>(
    () => ConversationDetailsRemoteDataSourceImpl(client: sl()),
  );
  //! Notifications
  sl.registerLazySingleton<INotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(client: sl()),
  );

  //! Shipments
  sl.registerLazySingleton<IShipmentRemoteDataSource>(
    () => ShipmentRemoteDataSourceImpl(client: sl()),
  );

  //! Inspections
  sl.registerLazySingleton<IInspectionRemoteDataSource>(
    () => InspectionRemoteDataSourceImpl(client: sl()),
  );

  //! Conversations
  sl.registerLazySingleton<IConversationRemoteDataSource>(
    () => ConversationRemoteDataSourceImpl(client: sl()),
  );

  //! Send Message
  sl.registerLazySingleton<ISendMessageRemoteDataSource>(
    () => SendMessageRemoteDataSourceImpl(client: sl()),
  );

  //! truck documents
  sl.registerLazySingleton<IVehicleDocumentsRemoteDataSource>(
    () => VehicleDocumentsRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<IVehicleDocumentsLocalDataSource>(
    () => VehicleDocumentsLocalDataSourceImpl(prefs: sl()),
  );

  //! settlements
  sl.registerLazySingleton<ISettlementsDataSource>(
    () => SettlementsRemoteDataSourceImpl(client: sl()),
  );

  //! Annoucemenets
  sl.registerLazySingleton<IAnnoucementsRemoteDataSource>(
    () => AnnoucementRemoteDataSourceImpl(client: sl()),
  );
}

initRepositories() {
  //! Auth
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDatasource: sl(),
      localDataSource: sl(),
    ),
  );

  //! Home
  sl.registerLazySingleton<IHomeRepository>(
    () => HomeRepositoryImpl(remoteDatasource: sl()),
  );

  //! Document
  sl.registerLazySingleton<IDocumentRepository>(
    () => DocumentRepositoryImpl(documentDataSource: sl()),
  );
  //! Form
  sl.registerLazySingleton<IFormRepository>(
    () => FormRepositoryImpl(formDataSource: sl()),
  );
  //! Videos
  sl.registerLazySingleton<IVideoRepository>(
    () => VideoRepositoryImpl(videoRemoteDataSource: sl()),
  );
  //! Firebase
  sl.registerLazySingleton<IFirebaseRepository>(
    () => FirebaseRepositoryImpl(firebaseRemoteDataSource: sl()),
  );
  //! Conversation Details
  sl.registerLazySingleton<IConversationDetailsRepository>(
    () => ConversationDetailsRepositoryImpl(
        conversationDetailsRemoteDataSource: sl()),
  );
  //! Notifications
  sl.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(notificationRemoteDataSource: sl()),
  );

  //! Conversation
  sl.registerLazySingleton<IConversationRepository>(
      () => ConversationRepositoryImpl(conversationDataSource: sl()));

  //! Send Message
  sl.registerLazySingleton<ISendMessageRepository>(
    () => SendMessageRepositoryImpl(sendMessageRemoteDataSource: sl()),
  );

  //! Shipments
  sl.registerLazySingleton<IShipmentRepository>(
    () => ShipmentRepositoryImpl(shipmentDataSource: sl()),
  );

  //! Inspections
  sl.registerLazySingleton<IInspectionRepository>(
    () => InspectionRepositoryImpl(inspectionDataSource: sl()),
  );

  //! Truck Documents
  sl.registerLazySingleton<IVehicleDocumentsRepository>(
    () => VehicleDocumentsRepositoryImpl(
      truckRemoteDataSource: sl(),
      truckLocalDataSource: sl(),
    ),
  );

  //! Settlements
  sl.registerLazySingleton<ISettlmentsRepository>(
    () => SettlementsRepositoryImp(dataSource: sl()),
  );

  //! Annoucemenets
  sl.registerLazySingleton<IAnnoucementsRepository>(
    () => AnnoucementsRepositoryImpl(dataSource: sl()),
  );
}

initUsecases() {
  //! Auth
  sl.registerLazySingleton(() => LoginUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(authRepository: sl()));
  sl.registerLazySingleton(
    () => FetchExistingProfileUseCase(authRepository: sl()),
  );
  sl.registerLazySingleton(
    () => CheckEmailVerificationUseCase(authRepository: sl()),
  );
  sl.registerLazySingleton(() => GetProfileUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => UpdateFcmTokenUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => OtpSendUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => OtpVerifyUseCase(authRepository: sl()));
  sl.registerLazySingleton(
      () => OtpRegisterVerifyUseCase(authRepository: sl()));

  //! Configration
  sl.registerLazySingleton(
      () => GetAppConfigrationUseCase(authRepository: sl()));
  sl.registerLazySingleton(
      () => GetRealtimeConfigurationUseCase(authRepository: sl()));

  //! StateCity
  sl.registerLazySingleton(() => GetCitiesByStateUseCase(authRepository: sl()));

  //! Home
  sl.registerLazySingleton(() => GetApplicantUsecase(homeRepository: sl()));
  sl.registerLazySingleton(() => CheckClockInUsecase(homeRepository: sl()));
  sl.registerLazySingleton(() => ClockInUsecase(homeRepository: sl()));
  sl.registerLazySingleton(() => ClockOutUsecase(homeRepository: sl()));

  //! Documents
  sl.registerLazySingleton(
      () => GetAllDocumentsUseCase(documentRepository: sl()));
  sl.registerLazySingleton(
      () => UploadDocumentsUseCase(documentRepository: sl()));

  //! Forms
  sl.registerLazySingleton(() => GetAllFormsUsecase(formRepository: sl()));
  sl.registerLazySingleton(
      () => GetAllSignedFormsUsecase(formRepository: sl()));
  sl.registerLazySingleton(() => SignFormUsecase(formRepository: sl()));
  sl.registerLazySingleton(
      () => UpdateFormAttachmentUsecase(formRepository: sl()));

  //! Videos
  sl.registerLazySingleton(() => GetAllVideosUsecase(videoRepository: sl()));
  sl.registerLazySingleton(() => UpdateVideoUsecase(videoRepository: sl()));

  //! Firebase
  sl.registerLazySingleton(() => SignInToFirebaseUseCase(sl()));
  sl.registerLazySingleton(() => SendUserLocationUsecase(sl()));

  //! Conversation Details
  sl.registerLazySingleton(() => GetConversationDetailsUseCase(sl()));

  //! Notifications
  sl.registerLazySingleton(
    () => GetAllNotificationsUsecase(notificationRepository: sl()),
  );

  //! Shipments
  sl.registerLazySingleton(
    () => GetAllShipmentsUsecase(shipmentRepository: sl()),
  );

  sl.registerLazySingleton(
    () => UpdateShipmentUsecase(shipmentRepository: sl()),
  );

  sl.registerLazySingleton(
    () => CompleteShipmentUsecase(shipmentRepository: sl()),
  );

  sl.registerLazySingleton(
    () => UpdateStopStatusUsecase(shipmentRepository: sl()),
  );

  sl.registerLazySingleton(
    () => GetShipmentDetailsUsecase(shipmentRepository: sl()),
  );

  //! Notifications
  sl.registerLazySingleton(
      () => UpdateNotificationUsecase(notificationRepository: sl()));

  //! Conversations
  sl.registerLazySingleton(
      () => GetAllConversationsUseCase(conversationRepository: sl()));

  // Send Text Message
  sl.registerLazySingleton(
    () => SendTextMessageUseCase(sendMessageRepository: sl()),
  );

  // Get Contacts
  sl.registerLazySingleton(
    () => GetAllContactsUserCase(conversationRepository: sl()),
  );

  // Create New Conversation
  sl.registerLazySingleton(
    () => CreateNewConversationUserCase(conversationRepository: sl()),
  );

  // Send File Message
  sl.registerLazySingleton(
    () => SendFileMessageUseCase(sendMessageRepository: sl()),
  );

  // Message Mark As Read
  sl.registerLazySingleton(
    () => MessageMarkAsReadUseCase(sendMessageRepository: sl()),
  );

  // Load Previous Messages
  sl.registerLazySingleton(
    () => GetPreviousMessagesUseCase(sl()),
  );

  // React on Message
  sl.registerLazySingleton(() => ReactMessageUseCase(repository: sl()));

  // Delete Message
  sl.registerLazySingleton(() => DeleteMessageUseCase(repository: sl()));

  //! Inspections
  sl.registerLazySingleton(
    () => GetInspectionOptionsUseCase(inspectionRepository: sl()),
  );

  // Create Inspection
  sl.registerLazySingleton(
    () => CreateInspectionUserCase(inspectionRepository: sl()),
  );

  //! Group Conversations
  sl.registerLazySingleton(
      () => GetAllGroupConversationsUseCase(conversationRepository: sl()));

  //! Truck Documents
  sl.registerLazySingleton(
    () => GetAllTruckDocumentsUsecase(truckRepository: sl()),
  );

  sl.registerLazySingleton(
    () => GetAllTrailerDocumentsUsecase(truckRepository: sl()),
  );

  // get all settlements
  sl.registerLazySingleton(
    () => GetAllSettlmentsUsecase(repository: sl()),
  );
  sl.registerLazySingleton(
    () => GetSettlmentDetailsUsecase(repository: sl()),
  );

  // calling
  sl.registerLazySingleton(
    () => CallEventUsecase(repository: sl()),
  );

  // forward message
  sl.registerLazySingleton(
    () => ForwardMessageUseCase(repository: sl()),
  );

  // partner settlements
  sl.registerLazySingleton(
    () => GetAllPartnerSettlmentsUsecase(repository: sl()),
  );
  sl.registerLazySingleton(
    () => GetPartnerSettlmentDetailsUsecase(repository: sl()),
  );
  sl.registerLazySingleton(
    () => GetPartnerDriversUseCase(repository: sl()),
  );
  sl.registerLazySingleton(
    () => UpdatePartnerDriverStateUsecase(repository: sl()),
  );

  //! Annoucemenets
  sl.registerLazySingleton(
      () => GetAllAnnoucementsUsecase(annoucementsRepository: sl()));
  sl.registerLazySingleton(
      () => UpdateAnnoucementReadStatusUsecase(annoucementsRepository: sl()));

  //! update voip
  sl.registerLazySingleton(() => UpdateVoipTokenUsecase(repository: sl()));
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // LocalNotification.showFlutterNotification(message);
  debugPrint('Handling a background message ${message.messageId}');
}

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kIsWeb) {
    await LocalNotification.setupFlutterNotifications();
  }
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen(LocalNotification.showFlutterNotification);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint(
        'A new onMessageOpenedApp event was published! ${message.toMap()}');
    LocalNotification.handleMessage(message.data);
  });
}

Future<void> initLocalDb() async {
  await GetStorage.init();
}

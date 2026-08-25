import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';
import 'package:ts_driver/app/core/enum/agora_call_type.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/chat_documents_manager.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/chat_videos_manager.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/chat_videos_thumbnail_manager.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/file_extension_helper.dart';
import 'package:ts_driver/app/core/helpers/clipboard_helper.dart';
import 'package:ts_driver/app/core/helpers/media_picker/media_picker.dart';
import 'package:ts_driver/app/core/helpers/permission_helper.dart';
import 'package:ts_driver/app/core/widgets/rich_text_wrapper/controllers/controller.dart';
import 'package:ts_driver/app/core/widgets/rich_text_wrapper/models/match_target_item.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/conversation_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/call_event_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/params/call_event_param.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/usecases/call_event_usecase.dart';
import 'package:ts_driver/app/modules/chat/domain/params/buzz_message_params.dart';
import 'package:ts_driver/app/modules/chat/presentation/group_conversations/controllers/group_conversations_controller.dart';
import 'package:ts_driver/app/modules/chat/presentation/oto_conversations/controllers/oto_conversations_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/params/react_message_params.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/usecases/react_message_usecase.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/ios_clipboard_service.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/bottom_sheets/message_reactions_bottom_sheet.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_download_progress.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_main_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/previewers/chat_image_preview.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/reaction_components/model/reactions_menu_item.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/reaction_components/utilities/reactions_default_data.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/reaction_components/utilities/reactions_dialog_route.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/reaction_components/widgets/chat_reactions.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/bottom_sheets/participant_bottom_sheet.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/bottom_sheets/show_recording_bottom_sheet.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/tenor/tenor_service.dart';
import 'package:ts_driver/app/native_calling/channels/native_calling_method_channel.dart';
import 'package:ts_driver/app/routes/app_pages.dart';
import 'package:video_player/video_player.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/utils/location_picker.dart';
import 'package:ts_driver/app/core/utils/sound_recorder.dart';
import 'package:ts_driver/app/core/utils/sound/audio_player_manager.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/modules/chat_detail/data/enums/message_types.dart';
import 'package:ts_driver/app/modules/chat_detail/data/models/conversation_details_model.dart';
import 'package:ts_driver/app/modules/chat_detail/data/models/conversation_typing_model.dart';
import 'package:ts_driver/app/modules/chat_detail/data/models/new_message_model.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/params/send_files_message_params.dart';
import 'package:ts_driver/app/modules/chat_detail/data/repositories/messages_db_manager.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/get_previous_messages_params.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/message_sent_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/params/send_text_message_params.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/usecases/get_conversation_details_usercase.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/usecases/get_previous_messages_usecase.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/usecases/message_mark_as_read_usecase.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/usecases/send_text_message_usecase.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/pusher_manager.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';
import '../../../../core/services/injection_service.dart';
import '../../domain/usecases/delete_message_usecase.dart';
import '../../domain/usecases/send_file_message_usecase.dart';
import '../views/components/bottom_sheets/location_bottom_sheet.dart';
import '../views/components/dialogs/delete_message_confirmation_dialog.dart';

class ChatDetailController extends GetxController {
  String type = "group";
  bool iAmParticipant = true;
  String userName = "";
  String userImage = "";
  String userPhone = "";
  int conversationId = -1;
  final receiverId = 0.obs;
  bool chatable = false;
  String receiverModelType = "";
  final _count = 0.obs;
  get count => _count.value;

  final _hideSendIcon = false.obs;
  get hideSendIcon => _hideSendIcon.value;

  final _recorderEnabled = true.obs;
  get recorderEnabled => _recorderEnabled.value;

  final isEmojiPickerVisible = false.obs;

  final panelHeight = 0.0.obs; // matched to keyboardHeight; draggable taller
  final keyboardInset = 0.0.obs; // live keyboard inset (logical px)
  final keyboardHeight = 0.0.obs; // settled (max-seen) keyboard height

  final authController = Get.find<AuthController>();

  final ItemScrollController scrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsNotifier =
      ItemPositionsListener.create();

  final tenorService = TenorService(
    apiKey: 'REPLACE_WITH_GOOGLE_API_KEY',
    clientKey: 'mychatapp',
    locale: Get.locale?.toLanguageTag(),
  );

// Create an instance of Random
  final random = Random();

  final FileExtensionHelper fileExtensionHelper = FileExtensionHelper();

  final chatDocumentsManager = Get.put(ChatDocumentsManager());
  final chatVideosManager = Get.put(ChatVideosManager());
  final chatVideosThumbnailManager = Get.put(ChatVideosThumbnailManager());

  ///////////////////////// Chat Video Player ////////////////////////////////

  static const List<double> chatVideoSpeedOptions = [
    0.5,
    1.0,
    1.5,
    2.0,
    2.5,
    2.75,
  ];

  VideoPlayerController? chatVideoController;
  Timer? _chatVideoControlsTimer;
  String chatVideoUrl = "";
  String chatVideoTitle = "";
  final Rxn<File> chatVideoFile = Rxn<File>();
  final RxBool chatVideoIsError = false.obs;
  final RxBool chatVideoIsLoading = true.obs;
  final RxBool chatVideoIsDownloading = false.obs;
  final RxDouble chatVideoDownloadProgress = 0.0.obs;
  final RxBool chatVideoIsPlaying = false.obs;
  final RxBool chatVideoShowControls = true.obs;
  final RxBool chatVideoIsMuted = false.obs;
  final RxDouble chatVideoPlaybackSpeed = 1.0.obs;

  TextEditingController searchController = TextEditingController();

  //
  //
  // this holds the index of the currently scrolled message index
  // from a indexesOfSearchedMessages List
  final _currentScrolledIndexOfSearchedMessage = 0.obs;
  //
  final showScrollDownButton = false.obs;

  //
  // index of the searched message in a messages list which appears in search
  // and currenly presenting in views
  final currentSearchedIndex = (-1).obs;

  //
  //
  // this list holds the indexes of the searched messages from a messages list
  // indexes stored in this list, points towards the indexes of searched messages
  // in a messages list
  final RxList<int> indexesOfSearchedMessages = RxList();

  final RxBool isSearchEnabled = false.obs;

  final RxBool isMapLoading = false.obs;

  final RxBool haveImageInClipBoard = false.obs;

  final focusNode = FocusNode().obs;

  bool me = false;

  ///////////////////// Recording Related Things ///////////////////////////////////

  final _recordingDuration = Duration.zero.obs;
  get recordingDuration => _recordingDuration;
  final SoundRecorder recorder = SoundRecorder();

  ///////////////////////// Location Related Things ////////////////////////////////

  // final _controller = Completer<GoogleMapController>();
  MapPickerController mapPickerController = MapPickerController();

  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(41.311158, 69.279737),
    zoom: 14.4746,
  );

  final locationAddress = "".obs;

  ///////////////////////// chat realed things /////////////////////////////////////

  final pusher = sl<PusherManager>();

  final getConversationDetailsUseCase = sl<GetConversationDetailsUseCase>();

  Rxn<ConversationDetailsEntity> conversationDetails = Rxn();

  final RxBool _isLoadingChatDetails = false.obs;
  bool get isLoadingChatDetails => _isLoadingChatDetails.value;

  final RxBool _isLoadingPreviousMessages = false.obs;
  bool get isLoadingPreviousMessages => _isLoadingPreviousMessages.value;

  bool noMoreMessages = false;

  final RxBool _isLoadingFromDatabase = false.obs;
  bool get isLoadingFromDatabase => _isLoadingFromDatabase.value;

  final RxBool _isDatabaseListEmpty = false.obs;
  bool get isDatabaseListEmpty => _isDatabaseListEmpty.value;

  final RxBool _isDeletingMessage = false.obs;
  bool get isDeletingMessage => _isDeletingMessage.value;

  final RxList<AttachmentModel> selectedAttachments = RxList();

  final RxBool _isTyping = false.obs;
  bool get isTyping => _isTyping.value;

  String typingMessage = "typing...";

  final RxList<ConversationMessageEntity> _messagesList =
      <ConversationMessageEntity>[].obs;
  List<ConversationMessageEntity> get messages => _messagesList;

  final RxList<MessageMediaDownloadProgress>
      _messagesMediaDownloadProgressList = <MessageMediaDownloadProgress>[].obs;
  List<MessageMediaDownloadProgress> get messagesMediaDownloadProgressList =>
      _messagesMediaDownloadProgressList;

  final String myId = CommonVariables.settings.read(APPLICANT_ID);
  String myName = '';
  late String myImageUrl;

  // list contains the ids of those message for that mark as read api is called
  final RxList<int> _messagesMarkedAsRead = <int>[].obs;

  final sendTextMessageUseCase = sl<SendTextMessageUseCase>();
  final reactMessageUseCase = sl<ReactMessageUseCase>();
  final sendFileMessageUseCase = sl<SendFileMessageUseCase>();
  final messageMarkAsReadUseCase = sl<MessageMarkAsReadUseCase>();
  final getPreviousMessagesUseCase = sl<GetPreviousMessagesUseCase>();
  final callEventUsecase = sl<CallEventUsecase>();
  final deleteMessageUsecase = sl<DeleteMessageUseCase>();
  final messagesDatabase = sl<MessagesDatabase>();

  StreamSubscription<ChannelReadEvent>? messageReceivedSubscription;
  StreamSubscription<ChannelReadEvent>? messageReadSubscription;
  StreamSubscription<ChannelReadEvent>? typingSubscription;
  StreamSubscription<ChannelReadEvent>? messageReactionSubscription;
  StreamSubscription<ChannelReadEvent>? messageDeletionSubscription;

  final Rxn<ConversationMessageEntity> selectedMessageForReply = Rxn();

  final RxBool _isMessageSelectionEnabled = false.obs;
  bool get isMessageSelectionEnabled => _isMessageSelectionEnabled.value;

  final RxBool _messageTempHighlightEnabled = false.obs;
  bool get messageTempHighlightEnabled => _messageTempHighlightEnabled.value;

  final RxInt tempHighlightMessageId = (-1).obs;

  final RxBool _receivedBuzz = false.obs;
  bool get receivedBuzz => _receivedBuzz.value;

  final RxBool _isPlacingCall = false.obs;
  bool get isPlacingCall => _isPlacingCall.value;

  //
  // indicates the id of the message which have a buzz
  final RxnInt buzzOnMessageId = RxnInt();

  final RxList<int> selectedMessages = RxList<int>();

  // Add a controller
  late final RichTextController richTextController = RichTextController(
    targetMatches: [
      //
      //
      // bold + italic regix
      MatchTargetItem(
        regex: RegExp(r'\*_(.*?)_\*'),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
        regixCharStyle: const TextStyle(
          color: Colors.grey,
        ),
        allowInlineMatching: true,
      ),

      //
      //
      // bold regix
      MatchTargetItem(
        regex: RegExp(r'\*(.*?)\*'),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        regixCharStyle: const TextStyle(
          color: Colors.grey,
        ),
        allowInlineMatching: true,
      ),

      //
      //
      // italic regix
      MatchTargetItem(
        regex: RegExp(r'_(.*?)_'),
        style: const TextStyle(
          fontStyle: FontStyle.italic,
        ),
        regixCharStyle: const TextStyle(
          color: Colors.grey,
        ),
        allowInlineMatching: true,
      ),

      //
      //
      // strike through regix
      MatchTargetItem(
        regex: RegExp(r'~(.*?)~'),
        style: const TextStyle(
          decoration: TextDecoration.lineThrough,
        ),
        regixCharStyle: const TextStyle(
          color: Colors.grey,
        ),
        allowInlineMatching: true,
      )
    ],
    onMatch: (List<String> matches) {},
    deleteOnBack: false,
    regExpUnicode: false,
  );

  @override
  void onInit() async {
    super.onInit();
    final cached = CommonVariables.settings.read(KB_HEIGHT);
    final seed = (cached is num && cached > 120) ? cached.toDouble() : 290.0;
    keyboardHeight.value = seed;
    panelHeight.value = seed;
    if (Get.arguments != null) {
      final arguments = Get.arguments;
      receiverId.value = arguments['userId'] ?? 0;
      userName = arguments['userName'] ?? "";
      userImage = arguments['userImage'] ?? "";
      userPhone = arguments['userPhone'] ?? "";
      type = arguments['type'] ?? "group";
      chatable = arguments['chatable'] ?? false;
      receiverModelType = arguments['modelType'] ?? "";
      iAmParticipant = arguments['i_am_participant'] ?? false;
      conversationId = arguments['conversation_id'] ?? -1;
      _receivedBuzz.value = arguments['haveBuzz'] ?? false;
      buzzOnMessageId.value = arguments['buzzOnMessage'];
      if (conversationId == -1) {
        Get.back();
      }
    } else {
      Get.back();
    }

    //
    // reset buzz states
    Future.delayed(const Duration(seconds: 3), () {
      _receivedBuzz.value = false;
      buzzOnMessageId.value = null;
    });

    // generating my name from prefs
    final Map<String, dynamic> myDetails =
        CommonVariables.settings.read(USER_DATA);
    if (myDetails['personal_details'] != null) {
      final String firstName =
          myDetails['personal_details']['first_name'] ?? "";
      final String middleName =
          myDetails['personal_details']['middle_name'] ?? "";
      final String maidenName =
          myDetails['personal_details']['maiden_name'] ?? "";
      final String lastName = myDetails['personal_details']['last_name'] ?? "";
      myImageUrl = myDetails['profile'] ?? "";

      if (firstName.isNotEmpty) {
        myName = firstName;
      }
      if (middleName.isNotEmpty) {
        if (myName.isEmpty) {
          myName = middleName;
        } else {
          myName += ' $middleName';
        }
      }
      if (maidenName.isNotEmpty) {
        if (myName.isEmpty) {
          myName = maidenName;
        } else {
          myName += ' $maidenName';
        }
      }
      if (lastName.isNotEmpty) {
        if (myName.isEmpty) {
          myName = lastName;
        } else {
          myName += ' $lastName';
        }
      }
    }

    itemPositionsNotifier.itemPositions.addListener(() {
      int firstVisibleIndex =
          itemPositionsNotifier.itemPositions.value.first.index;
      if (firstVisibleIndex > 0 && (!showScrollDownButton.value)) {
        showScrollDownButton(true);
      } else if (firstVisibleIndex < 1 && showScrollDownButton.value) {
        showScrollDownButton(false);
      }
    });

    loadDataMessagesFromDatabase();

    await _configureMessageAndEmojiPickerThings();

    await _configureAudioRecorder();

    if (type == "group" && iAmParticipant) {
      await _setChatListeners();
    } else if (type == "oto") {
      await _setChatListeners();
    }
  }

  clearSearch() {
    searchController.clear();
    indexesOfSearchedMessages.clear();
    indexesOfSearchedMessages.refresh();
    currentSearchedIndex.value = -1;
    _currentScrolledIndexOfSearchedMessage.value = 0;
    scrollController.scrollTo(
        index: 0, duration: const Duration(milliseconds: 500));
  }

  findMessageAndScrollToIndex(int? messageId, {int tries = 1}) async {
    //
    if (messageId == null) {
      return;
    }
    try {
      final index =
          _messagesList.indexWhere((element) => element.id == messageId);

      if (index < 0) {
        if (tries > 5) {
          return;
        }
        await loadPreviousMessages(messages.last.id);
        await Future.delayed(const Duration(milliseconds: 500));
        return findMessageAndScrollToIndex(messageId, tries: tries + 1);
      }

      _scrollToIndex(index);

      // store temp hilghlight id and enable higlighting
      tempHighlightMessageId.value = messageId;
      _messageTempHighlightEnabled.value = true;

      // disable message highlighting and reset temp hilghlight id
      Future.delayed(const Duration(milliseconds: 1500), () {
        _messageTempHighlightEnabled.value = false;
        tempHighlightMessageId.value = (-1);
      });
    } catch (_) {}
  }

  scrollToMessageIndex(bool next) {
    if (next) {
      final nextIndex = _currentScrolledIndexOfSearchedMessage.value - 1;
      if (nextIndex < indexesOfSearchedMessages.length && nextIndex >= 0) {
        _scrollToIndex(indexesOfSearchedMessages[nextIndex]);
        currentSearchedIndex.value = indexesOfSearchedMessages[nextIndex];
        _currentScrolledIndexOfSearchedMessage.value = nextIndex;
      }
    } else {
      final previousIndex = _currentScrolledIndexOfSearchedMessage.value + 1;
      if (previousIndex < indexesOfSearchedMessages.length &&
          previousIndex >= 0) {
        _scrollToIndex(indexesOfSearchedMessages[previousIndex]);
        currentSearchedIndex.value = indexesOfSearchedMessages[previousIndex];
        _currentScrolledIndexOfSearchedMessage.value = previousIndex;
      }
    }
  }

  scrollToMessageAtIndex(int index) {
    //
    try {
      _scrollToIndex(index);
    } catch (_) {}
  }

  int getPreviousSearchCount() {
    final count = (indexesOfSearchedMessages.length -
        (_currentScrolledIndexOfSearchedMessage.value + 1));
    return count;
  }

  int getNextSearchCount() {
    final count = indexesOfSearchedMessages.length -
        (indexesOfSearchedMessages.length -
            (_currentScrolledIndexOfSearchedMessage.value));
    return count;
  }

  void _scrollToIndex(int index) {
    if (index < 0) {
      return;
    }
    scrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> loadDataMessagesFromDatabase() async {
    messages.clear();
    try {
      _isLoadingFromDatabase(true);
      messages.addAll(await messagesDatabase.getAllMessages(conversationId));
      _isLoadingFromDatabase(false);
      if (_messagesList.isEmpty) {
        _isDatabaseListEmpty(true);
      } else {
        _sortMessagesList();
      }
      await getChatDetails();
    } catch (_) {
      _isLoadingFromDatabase(false);
    }
  }

  // sort messages list on the bases of the created at
  _sortMessagesList() {
    messages.sort((a, b) {
      DateTime? aDate = a.createdAt;
      DateTime? bDate = b.createdAt;

      if (aDate == null && bDate != null) {
        return 1;
      } else if (bDate == null && aDate != null) {
        return -1;
      } else if (bDate == null && aDate == null) {
        return 0;
      } else {
        return bDate!.compareTo(aDate!);
      }
    });
  }

  _configureMessageAndEmojiPickerThings() async {
    richTextController.addListener(() {
      _count.value = richTextController.text.length;

      if (_count.value > 0) {
        pusher.emitTypingEvent({
          'user': {'id': myId, 'model_type': 'applicants', 'name': myName},
          'typing': true
        });
      }
      updateSendIcon();
      if (Platform.isIOS) {
        checkForImageInIosClipboard();
      }
    });

    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        indexesOfSearchedMessages.clear();
      } else {
        _appMessagesSearch();
      }
    });

    focusNode.value.addListener(() {
      // backstop: hide if the keyboard never fills the slot (shorter than cached)
      if (focusNode.value.hasFocus && isEmojiPickerVisible.value) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (focusNode.value.hasFocus) isEmojiPickerVisible.value = false;
        });
      }
    });
  }

  _appMessagesSearch() {
    indexesOfSearchedMessages.clear();
    final searchText = searchController.text.toLowerCase();
    for (int i = 0; i < messages.length; i++) {
      final messagesString = messages[i].message?.toLowerCase() ?? "";
      String fileName = "";

      // checking if message contains media then also search for filename
      if (messages[i].attachments?.isNotEmpty ?? false) {
        // checking if file is only document or attachmnet then search for file name else skip
        if ((messages[i].type != MessageTypes.image) &&
            (messages[i].type != MessageTypes.audio) &&
            (messages[i].type != MessageTypes.recorded)) {
          fileName = messages[i].attachments![0].fileName?.toLowerCase() ?? "";
        }
      }
      if (messagesString.contains(searchText) ||
          (fileName.contains(searchText) && fileName.isNotEmpty)) {
        indexesOfSearchedMessages.add(i);
      }
    }
    indexesOfSearchedMessages.refresh();
    if (indexesOfSearchedMessages.isNotEmpty) {
      scrollController.scrollTo(
        index: indexesOfSearchedMessages.first,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
      _currentScrolledIndexOfSearchedMessage.value = 0;
    }
  }

  _configureAudioRecorder() async {
    await recorder.init();
    recorder.addDurationChangeListener((duration) {
      _recordingDuration.value = duration;
    });
  }

  updateSendIcon() {
    if (richTextController.text.isEmpty &&
        selectedAttachments.isEmpty &&
        (!_recorderEnabled.value)) {
      setMicIcon();
    } else if (_recorderEnabled.value) {
      setSendIcon();
    }
  }

  void closeKeyboardAndPicker() {
    FocusManager.instance.primaryFocus?.unfocus();
    isEmojiPickerVisible.value = false;
  }

  Future<void> sendGifMessage(TenorGif gif) async {
    try {
      final uuid = DateTime.now().millisecondsSinceEpoch.toString();
      final url = gif.gifUrl ?? gif.tinyGifUrl ?? gif.mp4Url ?? '';

      final local = ConversationMessageModel(
        model: ConversationUserModel(id: int.parse(myId), image: myImageUrl),
        modelId: int.parse(myId),
        type: MessageTypes.gif,
        message: url,
        createdAt: DateTime.now(),
        tempId: uuid,
      )
        ..sendedNow = true
        ..replyOn = selectedMessageForReply.value;

      _messagesList.insert(0, local);
      if (_messagesList.length > 10) {
        scrollController.scrollTo(
            index: 0, duration: const Duration(milliseconds: 500));
      }

      // send to backend with gif_info
      final params = SendTextMessageParams(
        conversationId: conversationId.toString(),
        message: '',
        type: MessageTypes.gif,
        tempId: uuid,
        replyOnMessageId: selectedMessageForReply.value?.id,
        gifInfo: gif.raw,
      );
      selectedMessageForReply.value = null;

      final result = await sendTextMessageUseCase.call(params);
      result.fold((remote) async {
        if (remote.code == 200 && (remote.data?.isNotEmpty ?? false)) {
          for (var element in remote.data!) {
            for (int i = _messagesList.length - 1; i >= 0; i--) {
              if (_messagesList[i].sendedNow &&
                  _messagesList[i].tempId == uuid) {
                _messagesList[i].id = element.id;
                _messagesList[i].sentSuccessfully = true;

                Get.find<OtoConversationsController>().moveConversationOnTop(
                  conversationId,
                  ConversationLastMessageEntity(
                    id: _messagesList[i].id,
                    message: "[GIF]",
                    type: _messagesList[i].type,
                    modelId: _messagesList[i].modelId,
                    attachments: _messagesList[i].attachments,
                    createdAt: _messagesList[i].createdAt,
                  ),
                  incrementUnread: false,
                );

                _messagesList[i].model =
                    element.model ?? _messagesList[i].model;
                await messagesDatabase.insertMessage(_messagesList[i]);
                _messagesList.refresh();
                break;
              }
            }
          }
        }
      }, (r) {
        CommonWidgets.showSnackBar(title: 'Error'.tr, message: r.message);
      });
    } catch (e) {
      CommonWidgets.showSnackBar(title: 'Error'.tr, message: e.toString());
    }
  }

  deleteMessage(int? messageId) async {
    if (messageId == null || isDeletingMessage) {
      return;
    }

    // delete message api call
    try {
      _isDeletingMessage(true);

      //
      final Either<BaseResponse<bool>, Failure> result =
          await deleteMessageUsecase.call(messageId);

      result.fold((BaseResponse<bool> deletionResponse) async {
        if (deletionResponse.code == 200 && (deletionResponse.data == true)) {
          //
          //
          // notify the function to delete message from list and offline DB
          await _onMessageDeletion(messageId);
        }
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });

      _isDeletingMessage(false);
    } on Exception catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      _isDeletingMessage(false);
      debugPrint(e.toString());
    }
  }

  Future<void> loadMessagesFromLocalDb() async {
    _isLoadingFromDatabase(true);
    update();

    final localMessages = await messagesDatabase.getAllMessages(conversationId);
    _messagesList.assignAll(localMessages); // this is your RxList
    _sortMessagesList(); // optional if needed
    _isLoadingFromDatabase(false);

    update();
  }

  removeSelectedAttachment() {
    selectedAttachments.clear();
    updateSendIcon();
  }

  setSendIcon() {
    _hideSendIcon.value = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      _recorderEnabled.value = false;
      _hideSendIcon.value = false;
    });
  }

  setMicIcon() {
    _hideSendIcon.value = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      _recorderEnabled.value = true;
      _hideSendIcon.value = false;
    });
  }

  sendMessage() async {
    if (richTextController.text.isEmpty && selectedAttachments.isEmpty) {
      updateSendIcon();
      return;
    }

    if (selectedAttachments.isEmpty) {
      final uuid = DateTime.now().millisecondsSinceEpoch.toString();

      final message = ConversationMessageModel(
          model: ConversationUserModel(
            id: int.parse(myId),
            image: myImageUrl,
          ),
          modelId: int.parse(myId),
          type: MessageTypes.text,
          message: richTextController.text.toString().trim(),
          createdAt: DateTime.now(),
          tempId: uuid);
      message.sendedNow = true;
      message.replyOn = selectedMessageForReply.value;
      _messagesList.insert(0, message);
      if (_messagesList.length > 10) {
        scrollController.scrollTo(
            index: 0,
            duration: const Duration(seconds: 1),
            curve: Curves.easeOut);
      }
      richTextController.clear();

      final params = SendTextMessageParams(
          conversationId: conversationId.toString(),
          message: message.message!,
          type: message.type,
          tempId: uuid,
          replyOnMessageId: selectedMessageForReply.value?.id);

      // clearing selected message
      selectedMessageForReply.value = null;

      // sending message to server
      try {
        final Either<MessageSentEntity, Failure> result =
            await sendTextMessageUseCase.call(params);
        result.fold((MessageSentEntity messageSentFromRemote) async {
          if (messageSentFromRemote.code == 200 &&
              (messageSentFromRemote.data?.isNotEmpty ?? false)) {
            for (var element in messageSentFromRemote.data!) {
              for (int i = (_messagesList.length - 1); i >= 0; i--) {
                if (_messagesList[i].sendedNow &&
                    _messagesList[i].tempId == uuid) {
                  _messagesList[i].id = element.id;
                  _messagesList[i].sentSuccessfully = true;
                  _messagesList[i].conversationId = conversationId;

                  Get.find<OtoConversationsController>().moveConversationOnTop(
                    conversationId,
                    ConversationLastMessageEntity(
                      id: _messagesList[i].id,
                      message: _messagesList[i].message,
                      type: _messagesList[i].type,
                      modelId: _messagesList[i].modelId,
                      attachments: _messagesList[i].attachments,
                      createdAt: _messagesList[i].createdAt,
                    ),
                    incrementUnread: false,
                  );
                  _messagesList[i].model =
                      element.model ?? _messagesList[i].model;

                  await messagesDatabase.insertMessage(_messagesList[i]);

                  _messagesList.refresh();
                  break;
                }
              }
            }
          }
        }, (Failure r) {
          CommonWidgets.showSnackBar(
            title: 'Error'.tr,
            message: r.message,
          );
        });
      } catch (e) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: e.toString(),
        );
        debugPrint(e.toString());
      }
    } else {
      //
      List<File> files = [];
      //
      final uuid = DateTime.now().millisecondsSinceEpoch.toString();

      // collecting files and adding message to messages list
      for (var attachment in selectedAttachments) {
        //
        final file = File(attachment.file!.path);

        //
        files.add(file);

        // creating media object and configs the object
        final conversationMedia = AttachmentModel();
        conversationMedia.sendedNow = true;
        conversationMedia.sending = true;
        conversationMedia.file = file;
        conversationMedia.mimeType = attachment.mimeType;

        /// creating message object in order to add it to messages lis tto show on front end
        final message = ConversationMessageModel(
          model: ConversationUserModel(id: int.parse(myId)),
          modelId: int.parse(myId),
          type: attachment.attachmentType,
          message: richTextController.text.toString().trim(),
          tempId: uuid,
          createdAt: DateTime.now(),
          attachments: [conversationMedia],
        );
        message.sendedNow = true;
        message.replyOn = selectedMessageForReply.value;

        // adding message to list
        _messagesList.insert(0, message);
        if (_messagesList.length > 10) {
          scrollController.scrollTo(
              index: 0,
              duration: const Duration(seconds: 1),
              curve: Curves.easeOut);
        }
      }

      /// creating params in order to send to api
      var messageParams = SendFilesMessageParams(
          conversationId: conversationId.toString(),
          message: richTextController.text.toString(),
          tempId: uuid,
          files: files,
          type: selectedAttachments[0].attachmentType,
          progressListener: (progress) {
            // for (var element in messages) {
            //   if (element.tempId == uuid && element.sendedNow) {
            //     if (element.media?.isNotEmpty ?? false) {
            //       element.media![0].progress = progress;
            //     }
            //     break;
            //   }
            // }
          },
          replyOnMessageId: selectedMessageForReply.value?.id);

      removeSelectedAttachment();
      richTextController.clear();
      selectedMessageForReply.value = null;

      try {
        final response = await sendFileMessageUseCase.call(messageParams);

        response.fold((l) {
          // for (int i = (_messagesList.length - 1); i >= 0; i--) {
          //   if (_messagesList[i].sendedNow && _messagesList[i].tempId == uuid) {
          //     _messagesList[i].id = l.id;
          //     _messagesList[i].sentSuccessfully = true;
          //     _messagesList.refresh();
          //     break;
          //   }
          // }

          if (l.code == 200 && (l.data?.isNotEmpty ?? false)) {
            // remove message which are related to this request call
            _messagesList.removeWhere(
                (element) => (element.sendedNow && (element.tempId == uuid)));

            // iterating messages list and compare its id with sent message
            for (var element in l.data!) {
              final newMessage =
                  ConversationMessageEntity.fromJson(element.toJson());
              _messagesList.insert(0, newMessage);
            }

            // sorting messages
            _messagesList.sort((a, b) =>
                b.createdAt?.compareTo(a.createdAt ?? DateTime.now()) ?? 0);
          }
        }, (r) {
          // for (var element in messages) {
          //   if (element.tempId == uuid && element.sendedNow) {
          //     if (element.media?.isNotEmpty ?? false) {
          //       element.media![0].sending = false;
          //       element.media![0].sendedSuccessfully = false;
          //       element.media![0].progress = 0;
          //     }
          //     break;
          //   }
          // }
        });
      } catch (error) {
        // for (var element in messages) {
        //   if (element.tempId == uuid && element.sendedNow) {
        //     if (element.media?.isNotEmpty ?? false) {
        //       element.media![0].sending = false;
        //       element.media![0].sendedSuccessfully = false;
        //       element.media![0].progress = 0;
        //     }
        //     break;
        //   }
        // }
      }
    }
  }

  sendVoiceMessage() async {
    if (recorder.filePath.isEmpty) {
      return;
    }

    final file = File(recorder.filePath);

    if (!await file.exists()) {
      return;
    }

    final uuid = DateTime.now().millisecondsSinceEpoch.toString();

    String? mimeType;
    if (file.path.endsWith('.mp3')) {
      mimeType = 'audio/mpeg';
    } else if (file.path.endsWith('.wav')) {
      mimeType = 'audio/wav';
    } else if (file.path.endsWith('.m4a')) {
      mimeType = 'audio/mp4';
    } else {
      mimeType = lookupMimeType(file.path);
    }

    // creating media object and configs the object
    final conversationMedia = AttachmentModel();
    conversationMedia.sendedNow = true;
    conversationMedia.sending = true;
    conversationMedia.file = file;
    conversationMedia.mimeType = mimeType;

    /// creating message object in order to add it to messages lis tto show on front end
    final message = ConversationMessageModel(
      model: ConversationUserModel(id: int.parse(myId)),
      modelId: int.parse(myId),
      type: MessageTypes.recorded,
      message: richTextController.text.toString().trim(),
      tempId: uuid,
      createdAt: DateTime.now(),
      attachments: [conversationMedia],
    );
    message.sendedNow = true;
    message.duration = recorder.duration.inSeconds;
    message.replyOn = selectedMessageForReply.value;

    _messagesList.insert(0, message);
    // adding message to list
    if (_messagesList.length > 10) {
      scrollController.scrollTo(
          index: 0,
          duration: const Duration(seconds: 1),
          curve: Curves.easeOut);
    }

    /// creating params in order to send to api
    var messageParams = SendFilesMessageParams(
      conversationId: conversationId.toString(),
      message: "",
      tempId: uuid,
      files: [file],
      type: MessageTypes.recorded,
      duration: recorder.duration.inSeconds,
      progressListener: (progress) {
        // for (var element in messages) {
        //   if (element.tempId == uuid && element.sendedNow) {
        //     if (element.media?.isNotEmpty ?? false) {
        //       element.media![0].progress = progress;
        //     }
        //     break;
        //   }
        // }
      },
      replyOnMessageId: selectedMessageForReply.value?.id,
    );

    selectedMessageForReply.value = null;

    try {
      final response = await sendFileMessageUseCase.call(messageParams);

      response.fold((l) {
        if (l.code == 200 && (l.data?.isNotEmpty ?? false)) {
          // iterating messages list and compare its id with sent message

          for (var element in l.data!) {
            for (int i = (_messagesList.length - 1); i >= 0; i--) {
              if (_messagesList[i].sendedNow &&
                  _messagesList[i].tempId == uuid) {
                _messagesList[i].id = element.id;
                _messagesList[i].sentSuccessfully = true;
                _messagesList.refresh();
                break;
              }
            }
          }
        }

        // for (var element in messages) {
        //   if (element.tempId == uuid && element.sendedNow) {
        //     if (element.media?.isNotEmpty ?? false) {
        //       element.media![0].sending = false;
        //       element.media![0].sendedSuccessfully = true;
        //     }
        //     break;
        //   }
        // }
      }, (r) {
        for (var element in messages) {
          if (element.tempId == uuid && element.sendedNow) {
            if (element.attachments?.isNotEmpty ?? false) {
              element.attachments![0].sending = false;
              element.attachments![0].sendedSuccessfully = false;
              element.attachments![0].downloadProgress.value = 0.0;
            }
            break;
          }
        }
      });
    } catch (error) {
      for (var element in messages) {
        if (element.tempId == uuid && element.sendedNow) {
          if (element.attachments?.isNotEmpty ?? false) {
            element.attachments![0].sending = false;
            element.attachments![0].sendedSuccessfully = false;
            element.attachments![0].downloadProgress.value = 0.0;
          }
          break;
        }
      }
    }
  }

  markMessageAsRead(ConversationMessageEntity message) async {
    if (message.deletedAt != null) {
      return;
    }

    // if i am sender no need to mark as read
    if (message.modelId?.toString() == myId) {
      return;
    }

    // check if api for this already called the no need to call again
    if (_messagesMarkedAsRead.contains(message.id)) {
      return;
    }

    // if active type is group then check if readby  users list contains my id
    // then return to function, no need to call mark as read api again for this user
    if (type == "group") {
      if (message.readBy?.isNotEmpty ?? false) {
        final readByMe = message.readBy!.firstWhereOrNull((element) {
          return element.modelId?.toString() == myId;
        });
        if (readByMe != null) {
          return;
        }
      }
    }
    // else it means its type is one to one then check for the readAt field so
    // if readAt is not null then return else pass it to api call
    else if (message.readAt != null && message.readAt != "null") {
      return;
    }

    //
    // add message it to list for record so we can check that
    // api for this message is already called
    _messagesMarkedAsRead.add(message.id ?? 0);
    //
    //
    // calling api for message mark as read
    try {
      final result = await messageMarkAsReadUseCase.call(message.id.toString());
      result.fold((readDetails) async {
        try {
          // update the read_at in the chat list
          for (int i = (_messagesList.length - 1); i >= 0; i--) {
            if (_messagesList[i].id == message.id) {
              _messagesList[i].readAt = DateTime.now().toString();
              break;
            }
          }
        } catch (_) {}

        // update the read_at in the offline db also
        try {
          final messageFromDb =
              await messagesDatabase.getMessage(message.id ?? 0);
          if (messageFromDb != null) {
            messageFromDb.readAt = DateTime.now().toString();
            await messagesDatabase.updateMessage(messageFromDb.conversationId!,
                messageFromDb.id!, messageFromDb);
          }
        } catch (_) {}
      }, (Failure r) {
        // print("/////////// faliure in updating message read status.");
      });
    } catch (_) {
      // print("/////////// faliure in updating message read status.");
    }
  }

  void toggleEmojiPicker() {
    if (isEmojiPickerVisible.value) {
      focusNode.value.requestFocus();
    } else {
      // match the keyboard height so the slot doesn't resize on swap
      panelHeight.value = keyboardHeight.value;
      isEmojiPickerVisible.value = true;
      focusNode.value.unfocus();
    }
  }

  /// Keyboard inset, read above the Scaffold where it's real (the body sees 0).
  void setKeyboardInset(double inset) {
    keyboardInset.value = inset;
    if (inset > keyboardHeight.value) keyboardHeight.value = inset;
    // hide the picker only once the keyboard has filled the slot (no end-jump)
    if (isEmojiPickerVisible.value &&
        focusNode.value.hasFocus &&
        inset >= panelHeight.value - 2) {
      isEmojiPickerVisible.value = false;
    }
  }

  void showAttachmentBottomSheet(ThemeData theme) {
    MediaPicker.showAttachmentBottomSheet(
      onGalleryPicked: (files) {
        _pickImagesVideos(files);
      },
      onDocumentPicked: (files) {
        _pickDocuments(files);
      },
      onCameraPicked: (file) {
        _openCameraAndCaptureImage(file);
      },
      onAudiosPicked: (files) {
        _pickAudios(files);
      },
      onLocationPicked: () {
        openLocationPickerBottomSheet();
      },
    );
  }

  void _pickDocuments(List<File> files) async {
    if (files.isEmpty) {
      return;
    }

    selectedAttachments.clear();
    for (var file in files) {
      final attachment = AttachmentModel();
      attachment.sendedNow = true;
      attachment.sending = true;
      attachment.file = file;
      attachment.attachmentType = MessageTypes.attachment;
      selectedAttachments.add(attachment);

      updateSendIcon();
    }
  }

  void _pickImagesVideos(List<File> files) async {
    if (files.isEmpty) {
      return;
    }

    selectedAttachments.clear();
    for (var file in files) {
      final mimeType = lookupMimeType(file.path);
      final attachment = AttachmentModel();
      attachment.sendedNow = true;
      attachment.sending = true;
      attachment.file = File(file.path);
      attachment.attachmentType =
          fileExtensionHelper.isImageFile(mimeType ?? "")
              ? MessageTypes.image
              : MessageTypes.attachment;
      attachment.mimeType = mimeType;
      selectedAttachments.add(attachment);
    }
    updateSendIcon();
  }

  void _pickAudios(List<File> files) async {
    if (files.isEmpty) {
      return;
    }

    selectedAttachments.clear();

    for (var file in files) {
      final attachment = AttachmentModel();
      attachment.sendedNow = true;
      attachment.sending = true;
      attachment.file = file;
      attachment.attachmentType = MessageTypes.audio;
      selectedAttachments.add(attachment);
    }
    updateSendIcon();
  }

  Future<void> _openCameraAndCaptureImage(File? file) async {
    if (file == null) {
      return;
    }
    selectedAttachments.clear();
    selectedAttachments.clear();
    final attachment = AttachmentModel();
    attachment.sendedNow = true;
    attachment.sending = true;
    attachment.file = File(file.path);
    attachment.attachmentType = MessageTypes.image;
    selectedAttachments.add(attachment);
    updateSendIcon();
  }

  void showRecodingBottomSheet() async {
    if (!(await PermissionHelper.haveMicPermission(
        "Allow microphone permission in settings to send voice messages."))) {
      return;
    }
    showRecordingBottomSheet(this);

    _startRecording();
  }

  Future<void> _startRecording() async {
    recorder.startRecording();
  }

  stopRecording() async {
    await recorder.stopRecording();
  }

  Future<Position?> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
    return null;
  }

  void openLocationPickerBottomSheet() async {
    await PermissionHelper.haveLocationPermission(
      "Grant location permission in settings to share your location.",
    );

    showLocationBottomSheet(this);

    isMapLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 16,
    );
    isMapLoading.value = false;
  }

  String getStaticMapUrl(LocationModel? location) {
    if (location == null || location.lat == null || location.lng == null) {
      return '';
    }

    return "https://maps.googleapis.com/maps/api/staticmap?center=${location.lat},${location.lng}&zoom=16&size=600x300&markers=color:red%7C${location.lat},${location.lng}&key=$GOOGLE_MAPS_API_KEY";
  }

  sendLocationMessageNew() async {
    try {
      final uuid = DateTime.now().millisecondsSinceEpoch.toString();

      final coords =
          "${cameraPosition.target.latitude},${cameraPosition.target.longitude}";

      // Display message locally
      final message = ConversationMessageModel(
        model: ConversationUserModel(
          id: int.parse(myId),
          image: myImageUrl,
        ),
        modelId: int.parse(myId),
        type: MessageTypes.location,
        message: coords,
        location: LocationModel(
            lat: cameraPosition.target.latitude,
            lng: cameraPosition.target.longitude),
        createdAt: DateTime.now(),
        tempId: uuid,
      );
      message.sendedNow = true;

      _messagesList.insert(0, message);
      if (_messagesList.length > 10) {
        scrollController.scrollTo(
          index: 0,
          duration: const Duration(seconds: 1),
        );
      }

      // Prepare params
      final params = SendTextMessageParams(
        conversationId: conversationId.toString(),
        message: 'Shared Location',
        tempId: uuid,
        type: message.type,
        latitude: cameraPosition.target.latitude,
        longitude: cameraPosition.target.longitude,
      );

      final Either<MessageSentEntity, Failure> result =
          await sendTextMessageUseCase.call(params);

      result.fold((MessageSentEntity messageSentFromRemote) async {
        if (messageSentFromRemote.code == 200 &&
            (messageSentFromRemote.data?.isNotEmpty ?? false)) {
          for (var element in messageSentFromRemote.data!) {
            for (int i = (_messagesList.length - 1); i >= 0; i--) {
              if (_messagesList[i].sendedNow &&
                  _messagesList[i].tempId == uuid) {
                _messagesList[i].id = element.id;
                _messagesList[i].sentSuccessfully = true;
                Get.find<OtoConversationsController>().moveConversationOnTop(
                  conversationId,
                  ConversationLastMessageEntity(
                    id: _messagesList[i].id,
                    message: "📍 Shared Location",
                    type: _messagesList[i].type,
                    modelId: _messagesList[i].modelId,
                    attachments: _messagesList[i].attachments,
                    createdAt: _messagesList[i].createdAt,
                  ),
                  incrementUnread: false,
                );
                _messagesList[i].model =
                    element.model ?? _messagesList[i].model;

                await messagesDatabase.insertMessage(_messagesList[i]);

                _messagesList.refresh();

                break;
              }
            }
          }
        }
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
    }
  }

  _setChatListeners() async {
    var messageDataChannel =
        await pusher.subscribeToMessageDataChannel(conversationId.toString());

    // attaching message received event listener
    messageReceivedSubscription =
        messageDataChannel.bind("message-received").listen((event) async {
      if (event.data != null) {
        final newMessage = newMessageModelFromJson(event.data);
        final convertedMessage =
            newMessage.convertToConversationMessageEntity();
        // if messagetype is not call log then move conversation to top in converstoin list screen
        if (newMessage.messageData?.type != MessageTypes.callLog) {
          try {
            if (type == "group") {
              Get.find<GroupConversationsController>()
                  .moveGroupConversationOnTop(
                conversationId,
                newMessage.convertToGroupConversationLastMessageEntity(),
              );
            } else {
              Get.find<OtoConversationsController>().moveConversationOnTop(
                conversationId,
                newMessage.convertToConversationLastMessageEntity(),
              );
            }
          } catch (_) {}
        }

        //else message is a call log then check if message
        // not exists in the list add it and also add it to offline DB
        else {
          // checking if message not exists in the array then add it else update status
          if (_messagesList.firstWhereOrNull(
                  (element) => element.id == convertedMessage.id) ==
              null) {
            _messagesList.insert(0, convertedMessage);
            messagesDatabase.insertMessage(convertedMessage);
          } else {
            // finding old message and updating in the database
            final oldMessage = _messagesList.firstWhereOrNull(
                (element) => element.id == convertedMessage.id);
            if (oldMessage != null) {
              oldMessage.message = convertedMessage.message;
              oldMessage.duration = convertedMessage.duration;
              oldMessage.updatedAt = convertedMessage.updatedAt;
              _messagesList.refresh();

              // refreshing in the offline db
              // update the call logs in the offline db also
              try {
                final messageFromDb =
                    await messagesDatabase.getMessage(convertedMessage.id ?? 0);
                if (messageFromDb != null) {
                  messageFromDb.message = convertedMessage.message;
                  messageFromDb.duration = convertedMessage.duration;
                  messageFromDb.updatedAt = convertedMessage.updatedAt;
                  await messagesDatabase.updateMessage(
                      messageFromDb.conversationId!,
                      messageFromDb.id!,
                      messageFromDb);
                }
              } catch (_) {}
            }
          }
          return;
        }
        messagesDatabase.insertMessage(convertedMessage);
        if (newMessage.messageData?.modelId != int.parse(myId)) {
          _messagesList.insert(0, convertedMessage);
        } else if (_messagesList.firstWhereOrNull((element) => (element.id ==
                    convertedMessage.id ||
                (element.tempId ?? "1") == (convertedMessage.tempId ?? "0"))) ==
            null) {
          _messagesList.insert(0, convertedMessage);
        }
      }
    });

    // attaching message read event listener
    messageReadSubscription =
        messageDataChannel.bind("message-read").listen((event) async {
      if (event.data != null) {
        try {
          final jsonData = jsonDecode(event.data);
          // if type is single then update single message
          if (jsonData['type'] == "single") {
            final messageData = jsonData['message'];

            // update the read_at in the chat list
            for (int i = (_messagesList.length - 1); i >= 0; i--) {
              if (_messagesList[i].id == messageData['id'] ||
                  (_messagesList[i].tempId ?? "0") ==
                      (messageData['temp_id'] ?? "1")) {
                if (type == "group") {
                  if (_messagesList[i].readBy == null) {
                    _messagesList[i].readBy = [];
                  }
                  _messagesList[i].readBy?.add(ReadByModel(
                        messageId: messageData['id'],
                        createdAt: DateTime.now(),
                      ));
                } else {
                  _messagesList[i].readAt =
                      messageData['read_at'] ?? DateTime.now().toString();
                }
                _messagesList.refresh();
                break;
              }
            }

            // update the read_at in the offline db also
            try {
              final messageFromDb =
                  await messagesDatabase.getMessage(messageData['id']);
              if (messageFromDb != null) {
                messageFromDb.readAt = messageData['read_at'];
                messageFromDb.readBy ??= [];
                messageFromDb.readBy?.add(ReadByModel(
                  messageId: messageData['id'],
                  createdAt: DateTime.now(),
                ));
                await messagesDatabase.updateMessage(
                    messageFromDb.conversationId!,
                    messageFromDb.id!,
                    messageFromDb);
              }
            } catch (_) {}
          } else if (jsonData['type'] == "bulk") {
            // update the read_at in the chat list
            for (int i = (_messagesList.length - 1); i >= 0; i--) {
              if (_messagesList[i].readAt == null ||
                  _messagesList[i].readAt == "null") {
                _messagesList[i].readAt = DateTime.now().toString();
              }
            }
            _messagesList.refresh();
          }
        } catch (_) {}
      }
    });

    typingSubscription =
        messageDataChannel.bind("client-typing").listen((event) {
      if (event.data != null) {
        if (type == "group") {
          try {
            final typingUser = ConversationTypingModel.fromJson(event.data);
            typingMessage = "${typingUser.user?.firstName} is typing...";
            _isTyping(true);
            Future.delayed(const Duration(seconds: 2), () {
              _isTyping(false);
            });
          } catch (_) {}
        } else {
          typingMessage = "typing...";
          _isTyping(true);
          Future.delayed(const Duration(seconds: 2), () {
            _isTyping(false);
          });
        }
      }
    });

    //
    //
    // attaching a message reaction event listener
    messageReactionSubscription =
        messageDataChannel.bind("message-reaction").listen((event) {
      if (event.data != null) {
        try {
          final jsonData = jsonDecode(event.data);
          final messageId = jsonData['message_id'];
          final reaction = MessageReactionModel.fromJson(jsonData);

          // if pid in reaction not null and reacted by current user then skip
          if ((reaction.pId == getMyPid()) && (reaction.pId != null)) {
            return;
          }

          // finding message
          final message = _messagesList.firstWhereOrNull((element) =>
              (element.id?.toString() == messageId.toString()) &&
              (element.id != null));

          if (message != null) {
            _onMessageReaction(message, reaction);
          }
        } catch (_) {}
      }
    });

    //
    //
    // attaching a message deletion event listener
    messageDeletionSubscription =
        messageDataChannel.bind("message-deleted").listen((event) async {
      if (event.data != null) {
        try {
          final jsonData = jsonDecode(event.data);
          final messageId = jsonData['message_id'];
          final id = int.parse(messageId.toString());
          await _onMessageDeletion(id);
        } catch (_) {}
      }
    });
  }

  int? getMyPid() {
    return conversationDetails.value?.participants
        ?.firstWhereOrNull((element) =>
            element.id?.toString() == myId && element.modelType == "applicants")
        ?.pId;
  }

  getChatDetails() async {
    try {
      _isLoadingChatDetails(true);
      final Either<ConversationDetailsEntity, Failure> result =
          await getConversationDetailsUseCase.call(conversationId.toString());
      _isLoadingChatDetails(false);
      result.fold((ConversationDetailsEntity conversationDetialsFromRemote) {
        conversationDetails.value = conversationDetialsFromRemote;

        // filering new messages
        final newMessages = conversationDetialsFromRemote.messages ?? [];

        if (newMessages.isNotEmpty) {
          _messagesList.clear();
          _messagesList.addAll(newMessages);

          syncNewMessagesWithDatabase(newMessages);
        }
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isLoadingChatDetails(false);
    }
  }

  loadPreviousMessages(int? lastMessageId) async {
    try {
      _isLoadingPreviousMessages(true);

      // calling api and getting previous messages response
      final Either<List<ConversationMessageEntity>, Failure> result =
          await getPreviousMessagesUseCase.call(GetPreviousMessagesParams(
              conversationId: conversationId.toString(),
              lastMessageId: lastMessageId.toString()));

      // setting loading state to false
      _isLoadingPreviousMessages(false);

      // folding response of the api
      result.fold((List<ConversationMessageEntity> previousMessages) {
        // filering new messages
        if (previousMessages.isNotEmpty) {
          _messagesList.addAll(previousMessages);
        } else {
          noMoreMessages = true;
          _messagesList.refresh();
        }
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
        _isLoadingPreviousMessages(false);
      });
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isLoadingPreviousMessages(false);
    }
  }

  syncNewMessagesWithDatabase(
      List<ConversationMessageEntity> newMessages) async {
    try {
      if (newMessages.isNotEmpty) {
        await messagesDatabase
            .deleteConversation(newMessages[0].conversationId!);
        await messagesDatabase.insertMessages(newMessages.reversed.toList());
      }
    } catch (_) {}
  }

  showParticipantsBottomSheet() {
    showParticipantBottomSheet(this);
  }

  checkForImageInIosClipboard() async {
    if (!haveImageInClipBoard.value) {
      final result = await IosClipboardService().getImageFromClipboard();
      if (result != null) {
        haveImageInClipBoard(true);
      } else {
        haveImageInClipBoard(false);
      }
    }
  }

  attachFileFromClipboard() async {
    if (Platform.isIOS) {
      final result = await IosClipboardService().getImageFromClipboard();
      if (result != null) {
        haveImageInClipBoard(false);

        final image = File.fromRawPath(result);

        final tempDir = await getTemporaryDirectory();
        File file =
            await File('${tempDir.path}/${DateTime.now().toString()}.png')
                .create();
        file.writeAsBytesSync(result);

        // ignore: unnecessary_null_comparison
        if (image != null) {
          selectedAttachments.clear();
          final attachment = AttachmentModel();
          attachment.sendedNow = true;
          attachment.sending = true;
          attachment.file = File(image.path);
          attachment.attachmentType = MessageTypes.image;
          selectedAttachments.add(attachment);
          updateSendIcon();
        }
      }
    }
  }

  placeCall(AgoraCallType callType) async {
    if (isPlacingCall) {
      return;
    }

    // Mic is required for every call; camera only for video. A video call whose
    // camera is denied is placed as audio instead of being blocked.
    final effectiveType = await _resolveCallPermissions(callType);
    if (effectiveType == null) return;

    _isPlacingCall.value = true;
    await _placeCallInNativeLayer(effectiveType);
    _isPlacingCall.value = false;
    return;
  }

  bool isMessageDeletable() {
    if (selectedMessages.length != 1) {
      return false;
    }

    final message = _messagesList
        .firstWhereOrNull((element) => element.id == selectedMessages.first);

    return ((message!.model?.id ==
            authController.user.value.personalDetails?.applicantId) &&
        (message.model?.modelType == "applicants") &&
        (message.type != MessageTypes.callLog) &&
        durationIsLessThan5Mins(message.createdAt));
  }

  bool durationIsLessThan5Mins(DateTime? createdAt) {
    if (createdAt == null) {
      return false;
    }

    Duration difference = DateTime.now().difference(createdAt);
    return (difference.inSeconds < 300);
  }

  /// Requests the permissions a call needs and returns the type to actually
  /// place. Mic is required for any call; camera only for video. A video call
  /// with camera denied downgrades to audio. Returns null when mic is denied.
  Future<AgoraCallType?> _resolveCallPermissions(AgoraCallType callType) async {
    final micGranted = await PermissionHelper.haveMicPermission(
        "Grant microphone permission in settings to make a call.");
    if (!micGranted) return null;

    if (callType != AgoraCallType.video) return AgoraCallType.audio;

    final cameraGranted = await PermissionHelper.haveCameraPermission(
        "Grant camera permission in settings to make a video call.");
    if (cameraGranted) return AgoraCallType.video;

    CommonWidgets.showSnackBar(
      title: "Camera unavailable",
      message: "Starting an audio call instead.",
    );
    return AgoraCallType.audio;
  }

  _placeCallInNativeLayer(AgoraCallType callType) async {
    //
    // check can we start call in native layer
    if (!(await NativeCallingMethodChannel.canStartCall())) {
      CommonWidgets.showSnackBar(
        title: "Error",
        message:
            "You can't start a new call. When one call is already in process.",
      );
      return;
    }

    if (Platform.isAndroid) {
      if ((await Permission.phone.request()) != PermissionStatus.granted) {
        CommonWidgets.showSnackBar(
          title: "Error",
          message:
              "Please first grant phone access in settings, in order to place call.",
        );
      }
    }

    //
    //
    // emitting event for call
    try {
      final response = await callEventUsecase.call(
        CallEventParam(
          eventName: AgoraCallEvents.incommingCall,
          eventDetails: {
            'conversationId': conversationId,
            'callType': callType == AgoraCallType.video ? "video" : 'audio',
          },
        ),
      );

      //
      //
      // check if response successful then start call at native layer
      // else show errors
      response.fold((CallEventEntity data) async {
        if (data.callPayload != null) {
          //
          // adding receiver name in payload, as needed in native layer
          final notificationPayload = data.callPayload!.toJson();
          notificationPayload["receiverName"] = userName;

          //
          // calling method channel function
          final result =
              await NativeCallingMethodChannel.placeCall(notificationPayload);

          debugPrint("result from placing native call is ===> $result");
          //
        } else {
          CommonWidgets.showSnackBar(
              title: 'Error', message: data.message ?? 'Something went wrong.');
        }
      }, (r) {
        CommonWidgets.showSnackBar(title: 'Error', message: r.message);
      });
    } catch (e) {
      CommonWidgets.showSnackBar(
          title: 'Error', message: 'Something went wrong.');
    }
  }

  selectMessage(ConversationMessageEntity message) {
    if (message.id == null || message.deletedAt != null) {
      return;
    }
    if (isMessageSelectionEnabled) {
      if (selectedMessages.contains(message.id)) {
        selectedMessages.remove(message.id);
        _isMessageSelectionEnabled(selectedMessages.isNotEmpty);
      } else if (selectedMessages.length < 5) {
        selectedMessages.add(message.id!);
      }
    } else {
      selectedMessages.clear();
      _isMessageSelectionEnabled(true);
      selectedMessages.add(message.id!);

      try {
        final index = messages.indexOf(message);
        if (index >= 0) {
          _showMessageReactionDialog(message, index);
        }
      } catch (_) {}
    }
  }

  copyMessage() {
    if (!isMessageSelectionEnabled) {
      return;
    }
    if (selectedMessages.isEmpty) {
      return;
    }
    ClipboardHelper.copyPlainText(messages
            .firstWhereOrNull((element) => element.id == selectedMessages[0])
            ?.message ??
        "");
    //
    // reset themessage selection states
    _isMessageSelectionEnabled(false);
    selectedMessages.clear();
  }

  _showMessageReactionDialog(ConversationMessageEntity message, index) {
    final context = Get.context;

    if (context == null) {
      return;
    }

    List<ReactionsMenuItem> menuItems = [
      ReactionsData.reply,
      ReactionsData.copy,
      ReactionsMenuItem(
        id: 5,
        label: 'Forward',
        icon: Icons.forward_rounded,
        customIcon: Transform.flip(
          flipX: true,
          child: Icon(
            Icons.reply_rounded,
            color: Theme.of(context).textTheme.bodyMedium!.color,
            size: 24,
          ),
        ),
      ),
    ];

    if (isMessageDeletable()) {
      menuItems.add(ReactionsData.delete);
    }

    Navigator.of(context).push(RaectionsDialogRoute(
      fullscreenDialog: true,
      builder: (context) {
        return ReactionsDialogWidget(
          menuItems: menuItems,
          menuItemsWidth: 0.65,
          menuItemsPadding: const EdgeInsets.all(10),
          widgetAlignment: message.modelId.toString() == myId
              ? Alignment.centerRight
              : Alignment.centerLeft,
          id: message.id!.toString(), // unique id for message
          messageWidget: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            elevation: 1,
            child: MessageMainView(
              message: message,
              index: index,
            ).marginSymmetric(horizontal: 5),
          ), // message widget
          onReactionTap: (reaction) {
            // add reaction to message
            _reactOnMessage(message, reaction);
            _clearMessageSelection();
          },
          onContextMenuTap: (menuItem) {
            switch (menuItem.id) {
              case 1:
                //reply
                selectedMessageForReply.value = message;
                _clearMessageSelection();
                break;

              case 2:
                //copy
                copyMessage();
                break;

              case 3:
                // delete
                if (isMessageDeletable()) {
                  deleteMessageClicked();
                }
                break;

              case 4:

                //edit

                break;

              case 5:
                //forward
                forwardMessage();
                break;
            }
          },
        );
      },
    ));
  }

  _clearMessageSelection() {
    selectedMessages.clear();
    _isMessageSelectionEnabled(false);
  }

  forwardMessage() async {
    if (!isMessageSelectionEnabled) {
      return;
    }
    if (selectedMessages.isEmpty) {
      return;
    }

    final messagesToForward = messages
        .where((element) =>
            selectedMessages.contains(element.id) && (element.id != null))
        .toList();

    try {
      messagesToForward.sort((a, b) {
        DateTime? aDate = a.createdAt;
        DateTime? bDate = b.createdAt;

        if (aDate == null && bDate != null) {
          return 1;
        } else if (bDate == null && aDate != null) {
          return -1;
        } else if (bDate == null && aDate == null) {
          return 0;
        } else {
          return aDate!.compareTo(bDate!);
        }
      });
    } catch (_) {}

    // navigate to forward message screen
    if (messagesToForward.isNotEmpty) {
      await Get.toNamed(Routes.FORWARD_MESSAGE, arguments: messagesToForward);
    }

    //
    // reset themessage selection states
    _isMessageSelectionEnabled(false);
    selectedMessages.clear();
  }

  void onImageClicked(String? url, File? file) {
    final images = messages
        .where(
      (e) =>
          (e.type == MessageTypes.image) &&
          (e.attachments?.isNotEmpty ?? false) &&
          ((e.attachments?[0].url != null) || (e.attachments?[0].file != null)),
    )
        .map(
      (e) {
        return PreviewImage(
          url: e.attachments?.firstOrNull?.url,
          file: e.attachments?.firstOrNull?.file,
        );
      },
    ).toList();

    int initailIndex = 0;
    if (url != null || file != null) {
      final foundIndex = images.indexOf(PreviewImage(url: url, file: file));
      if (foundIndex >= 0 && foundIndex < images.length) {
        initailIndex = foundIndex;
      }
    }

    Get.to(
      ChatImagePreview(
        title: userName,
        previewImages: images,
        initialIndex: initailIndex,
      ),
    );
  }

  String getCallText(int? callPlacedBy, String event, int? duration) {
    //
    if (type == "group") {
      //
      return "group call";
    } else {
      //
      switch (event) {
        //
        // event the call status is not updated
        case AgoraCallEvents.incommingCall:
          return "Missed.";
        //
        // event the call is declined
        case AgoraCallEvents.callDeclined:
          return "Declined.";
        //
        // event the call is not answered
        case AgoraCallEvents.noAnswer:
          return "Not Answered.";
        //
        // event the call is not answered
        case AgoraCallEvents.callEnded:
          return duration != null ? _formatDuration(duration) : "";

        default:
          return "Missed.";
      }
    }
  }

  deleteMessageClicked() async {
    if (!isMessageSelectionEnabled) {
      return;
    }
    if (selectedMessages.isEmpty) {
      return;
    }
    final message = messages
        .firstWhereOrNull((element) => element.id == selectedMessages[0]);

    if (message == null) {
      return;
    }

    if (message.type == MessageTypes.callLog) {
      return;
    }

    //
    //
    // show delete emssage confirmation dialog
    await showDeleteMessageConfirmationDialog(message.id!);
  }

  showDeleteMessageConfirmationDialog(int messageId) async {
    //
    await Get.defaultDialog(
      title: 'Delete Message',
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20.sp,
        color: AppColorsLight.mainColor,
      ),
      onWillPop: () async {
        return false;
      },
      titlePadding: EdgeInsets.only(top: 10.h),
      content: DeleteMessageConfirmationDialog(
        onDeleteCalled: () async {
          //
          // hit api for delete
          await deleteMessage(messageId);
          Get.back();
        },
        onCancelCalled: () {
          Get.back();
        },
      ),
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
    );

    //
    // reset the message selection states
    _isMessageSelectionEnabled(false);
    selectedMessages.clear();
  }

  //
  //
  /// This function will handle the buzz logic,
  onBuzzReceived(BuzzMessageParams buzzMessageParams) async {
    if (buzzMessageParams.converstionId == conversationId) {
      buzzOnMessageId.value = buzzMessageParams.messageId;

      if (buzzOnMessageId.value != null) {
        await findMessageAndScrollToIndex(buzzOnMessageId.value);
      }
      _receivedBuzz.value = true;

      Future.delayed(const Duration(seconds: 3), () {
        _receivedBuzz.value = false;
        buzzOnMessageId.value = null;
      });
    }
  }

  String _formatDuration(int totalTicks) {
    var tick = totalTicks;
    // // calculating days from tick
    // days.value = tick ~/ (24 * 3600);

    // // subracting days from the tick
    // tick = tick % (24 * 3600);

    // calculating hours
    final hours = tick ~/ 3600;

    // subracting hours from tick
    tick = tick % 3600;

    // calculating minutes
    final minutes = tick ~/ 60;

    // removing minutes and getting seconds
    final seconds = tick % 60;
    String duration =
        "${hours <= 9 ? '0' : ''}$hours-${minutes <= 9 ? '0' : ''}$minutes-${seconds <= 9 ? '0' : ''}$seconds";
    return duration;
  }

  _reactOnMessage(ConversationMessageEntity message, String reaction) async {
    try {
      //

      final myPid = getMyPid();

      if (myPid == null) {
        return;
      }

      final response = await reactMessageUseCase.call(ReactMessageParams(
          messageId: message.id!, participantId: myPid, reaction: reaction));

      response.fold((l) {
        if (l.data == true) {
          //
          //
          // on reaction success
          try {
            _onMessageReaction(
                message, MessageReactionModel(pId: myPid, reaction: reaction));
          } catch (_) {}
        } else {
          CommonWidgets.showSnackBar(
              title: 'Error'.tr,
              message: l.message?.toString() ??
                  "Something went wrong with message reaction.",
              isError: false);
        }
      }, (r) {
        CommonWidgets.showSnackBar(
            title: 'Error'.tr, message: r.message.toString(), isError: false);
      });
    } catch (e) {
      CommonWidgets.showSnackBar(
          title: 'Error'.tr, message: e.toString(), isError: false);
    }
  }

  _onMessageReaction(
      ConversationMessageEntity message, MessageReactionEntity reaction) async {
    if (message.reactions?.isEmpty ?? true) {
      message.reactions = [reaction];
    } else {
      final oldReaction = message.reactions!
          .firstWhereOrNull((element) => element.pId == reaction.pId);

      if (oldReaction != null) {
        oldReaction.reaction = reaction.reaction;
      } else {
        message.reactions!.add(reaction);
      }
    }

    _messagesList.refresh();

    //
    //
    // update message reactions in db
    try {
      final messageFromDb = await messagesDatabase.getMessage(message.id ?? 0);
      if (messageFromDb != null) {
        messageFromDb.reactions = message.reactions;
        await messagesDatabase.updateMessage(
            messageFromDb.conversationId!, messageFromDb.id!, messageFromDb);
      }
    } catch (_) {}
  }

  _onMessageDeletion(int messageId) async {
    //
    //
    // remove message from list
    try {
      _messagesList
          .firstWhereOrNull((message) => message.id == messageId)
          ?.deletedAt = DateTime.now();
      _messagesList.refresh();
    } catch (_) {}

    //
    //
    // update message in offline DB
    try {
      try {
        final messageFromDb = await messagesDatabase.getMessage(messageId);
        if (messageFromDb != null) {
          messageFromDb.message = "";
          messageFromDb.attachments = [];
          messageFromDb.deletedAt = DateTime.now();
          messageFromDb.updatedAt = DateTime.now();
          await messagesDatabase.updateMessage(
            messageFromDb.conversationId!,
            messageFromDb.id!,
            messageFromDb,
          );
        }
      } catch (_) {}
    } catch (_) {}

    //
    //
    // if deleted message was last message of conversation then
    // notify coversations listing
    try {
      if (type == "group") {
        Get.find<GroupConversationsController>()
            .onMessageDelete(conversationId, messageId);
      } else {
        Get.find<OtoConversationsController>()
            .onMessageDelete(conversationId, messageId);
      }
    } catch (_) {}
  }

  showMessageReactionBottomSheet(ConversationMessageEntity message) {
    if (message.reactions?.isEmpty ?? true) {
      return;
    }

    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: AppColorsLight.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return MessageReactionsBottomSheet(message: message);
      },
    );
  }

  /// Generate a random 6-digit number
  int generateUid() {
    Random random = Random();
    int min = 100000;
    int max = 999999;
    int randomSixDigitNumber = min + random.nextInt(max - min);
    return randomSixDigitNumber;
  }

  Future<void> initializeChatVideoPlayer({
    required String videoUrl,
    required String title,
    File? videoFile,
  }) async {
    final sameVideo = chatVideoController != null &&
        chatVideoUrl == videoUrl &&
        chatVideoFile.value?.path == videoFile?.path;
    if (sameVideo) return;

    disposeChatVideoPlayer();

    chatVideoUrl = videoUrl;
    chatVideoTitle = title;
    chatVideoFile.value = videoFile;
    chatVideoIsError.value = false;
    chatVideoIsLoading.value = true;
    chatVideoIsDownloading.value = false;
    chatVideoDownloadProgress.value = 0.0;
    chatVideoIsPlaying.value = false;
    chatVideoShowControls.value = true;
    chatVideoIsMuted.value = false;
    chatVideoPlaybackSpeed.value = 1.0;

    chatVideoController = videoFile != null
        ? VideoPlayerController.file(videoFile)
        : VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    chatVideoController!.addListener(_syncChatVideoState);

    try {
      await chatVideoController!.initialize();
      chatVideoIsLoading.value = false;
      chatVideoIsPlaying.value = true;
      await chatVideoController!.play();
      onTapChatVideoControls();
    } catch (error) {
      handleChatVideoError(error.toString());
    }
  }

  void _syncChatVideoState() {
    final controller = chatVideoController;
    if (controller == null) return;

    if (controller.value.hasError) {
      handleChatVideoError(controller.value.errorDescription);
      return;
    }

    if (chatVideoIsPlaying.value != controller.value.isPlaying) {
      chatVideoIsPlaying.value = controller.value.isPlaying;
    }
  }

  void handleChatVideoError(String? error) {
    chatVideoIsLoading.value = false;
    chatVideoIsError.value = true;
    debugPrint("VideoPlayer Error: $error");
  }

  void onTapChatVideoControls() {
    chatVideoShowControls.value = true;
    _chatVideoControlsTimer?.cancel();
    _chatVideoControlsTimer = Timer(const Duration(seconds: 3), () {
      if (chatVideoController?.value.isPlaying == true) {
        chatVideoShowControls.value = false;
      }
    });
  }

  void toggleChatVideoPlay() {
    final controller = chatVideoController;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }

    chatVideoIsPlaying.value = controller.value.isPlaying;
    onTapChatVideoControls();
  }

  void toggleChatVideoMute() {
    final controller = chatVideoController;
    if (controller == null) return;

    chatVideoIsMuted.value = !chatVideoIsMuted.value;
    controller.setVolume(chatVideoIsMuted.value ? 0.0 : 1.0);
  }

  void setChatVideoSpeed(double speed) {
    final controller = chatVideoController;
    if (controller == null) return;

    chatVideoPlaybackSpeed.value = speed;
    controller.setPlaybackSpeed(speed);
  }

  void seekChatVideoForward() {
    final controller = chatVideoController;
    if (controller == null) return;

    final position = controller.value.position + const Duration(seconds: 10);
    controller.seekTo(position);
    onTapChatVideoControls();
  }

  void seekChatVideoBackward() {
    final controller = chatVideoController;
    if (controller == null) return;

    final position = controller.value.position - const Duration(seconds: 10);
    controller.seekTo(position);
    onTapChatVideoControls();
  }

  void seekChatVideoToMilliseconds(double milliseconds) {
    final controller = chatVideoController;
    if (controller == null) return;

    controller.seekTo(Duration(milliseconds: milliseconds.toInt()));
    onTapChatVideoControls();
  }

  Future<void> enterChatVideoFullScreenMode() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> exitChatVideoFullScreenMode() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> handleChatVideoDownloadOrOpen() async {
    try {
      final file = chatVideoFile.value;
      if (file != null) {
        await _saveChatVideoToGallery(file);
      } else {
        await downloadChatVideo();
      }
    } catch (_) {}
  }

  Future<void> downloadChatVideo() async {
    try {
      final file = await chatVideosManager.getFile(
        chatVideosManager.getFileName(chatVideoUrl, withExtension: true),
      );

      if (file != null) {
        chatVideoFile.value = file;
        await _saveChatVideoToGallery(file);
        return;
      }

      chatVideoIsDownloading.value = true;

      final filePath = await chatVideosManager.downloadFile(
        chatVideoUrl,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          chatVideoDownloadProgress.value = received / total;
        },
        onFailure: (_) {
          CommonWidgets.showSnackBar(
            title: "Error",
            message: "Something went wrong while downloading",
          );
        },
      );

      chatVideoIsDownloading.value = false;
      chatVideoDownloadProgress.value = 0.0;

      if (filePath == null) return;

      final downloadedFile = File(filePath);

      if (await downloadedFile.exists()) {
        chatVideoFile.value = downloadedFile;
        await _saveChatVideoToGallery(downloadedFile);
      }
    } catch (_) {
      chatVideoIsDownloading.value = false;
      chatVideoDownloadProgress.value = 0.0;
    }
  }

  Future<void> _saveChatVideoToGallery(File file) async {
    try {
      await Gal.putVideo(file.path);
      CommonWidgets.showSnackBar(
        title: "Success",
        message: "Video saved successfully",
        isError: false,
      );
    } on GalException catch (e) {
      CommonWidgets.showSnackBar(
        title: "Error",
        message: e.type.message,
      );
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: "Error",
        message: "Something went wrong while saving video",
      );
    }
  }

  String formatChatVideoDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$minutes:$seconds";
  }

  String chatVideoSpeedLabel() {
    final speed = chatVideoPlaybackSpeed.value;
    if (speed == speed.truncateToDouble()) {
      return "${speed.toStringAsFixed(0)}x";
    }
    return "${speed}x";
  }

  void disposeChatVideoPlayer() {
    _chatVideoControlsTimer?.cancel();
    _chatVideoControlsTimer = null;
    chatVideoController?.removeListener(_syncChatVideoState);
    chatVideoController?.dispose();
    chatVideoController = null;
    exitChatVideoFullScreenMode();
  }

  @override
  void onClose() {
    // persist for next cold-start seed
    if (keyboardHeight.value > 120) {
      CommonVariables.settings.write(KB_HEIGHT, keyboardHeight.value);
    }
    messageReceivedSubscription?.cancel();
    messageReadSubscription?.cancel();
    typingSubscription?.cancel();
    messageReactionSubscription?.cancel();
    messageDeletionSubscription?.cancel();
    pusher.unsubscribeActiveCountChannel();
    pusher.unsubscribeMessageDataChannel();
    recorder.dispose();
    // textEditingController.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');

    // Cleanup all audio players for this chat
    AudioPlayerManager().disposeAll();

    disposeChatVideoPlayer();

    // seting conversation and group conversations unread count to zero
    try {
      if (Get.isRegistered<GroupConversationsController>()) {
        Get.find<GroupConversationsController>()
            .setGroupConversationUnreadCountToZero(conversationId);
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<OtoConversationsController>()) {
        Get.find<OtoConversationsController>()
            .setConversationUnreadCountToZero(conversationId);
      }
    } catch (_) {}

    super.onClose();
  }
}

class AgoraCallEvents {
  static const incommingCall = 'incomming-call';
  static const incommingCallDeclined = 'incomming-call-declined';
  static const callAccepted = 'call-accepted';
  static const callDeclined = 'call-declined';
  static const callEnded = 'call-ended';
  static const userBueasy = 'user-bueasy';
  static const callRinging = 'call-ringing';
  static const noAnswer = 'no-answer';
}

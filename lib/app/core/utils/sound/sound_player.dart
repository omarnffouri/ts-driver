import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;
import 'package:rxdart/rxdart.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/utils/sound/sound_widgets.dart';
import 'package:ts_driver/app/core/utils/sound/audio_player_manager.dart';

import '../../../modules/chat_detail/domain/entities/conversation_details_entity.dart';

class SoundPlayer extends StatefulWidget with WidgetsBindingObserver {
  final ConversationMessageEntity message;
  final String myId;

  SoundPlayer({super.key, required this.message, required this.myId});

  @override
  State<SoundPlayer> createState() => _SoundPlayerState();
}

class _SoundPlayerState extends State<SoundPlayer> {
  final _playerManager = AudioPlayerManager();
  AudioPlayer? _player;
  bool _isInitialized = false;
  String? _messageId;

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream => _player != null
      ? Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player!.positionStream,
          _player!.bufferedPositionStream,
          _player!.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero))
      : Stream.value(PositionData(Duration.zero, Duration.zero, Duration.zero));

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Get or create player for this message
    _messageId = widget.message.id.toString();
    _player = await _playerManager.getPlayer(_messageId!);

    // Listen to player state changes to pause other players when this one starts
    _player!.playerStateStream.listen((state) {
      if (state.playing) {
        // When this player starts, pause all other players
        _playerManager.pauseOtherPlayers(_messageId!);
      }
    });

    // Check if audio source is already set
    if (_player!.audioSource == null) {
      // Try to load audio from a source and catch any errors.
      try {
        if (widget.message.sendedNow ||
            (widget.message.attachments![0].file != null)) {
          if ((widget.message.attachments?.isEmpty ?? false) ||
              widget.message.attachments![0].file != null) {
            await _player!.setAudioSource(
                AudioSource.file(widget.message.attachments![0].file!.path));
          }
        } else {
          await _player!.setAudioSource(AudioSource.uri(
              Uri.parse(widget.message.attachments![0].url ?? "")));
        }
      } catch (e) {
        debugPrint("Error loading audio source: $e");

        try {
          await _player!.setAudioSource(AudioSource.uri(
              Uri.parse(widget.message.attachments![0].url ?? "")));
        } catch (_) {}
      }
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _player == null) {
      return const SizedBox(
        width: 25,
        height: 25,
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5, left: 6, right: 6),
              width: 45,
              height: 45,
              child: Stack(
                children: [
                  // Profile Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image(
                      image: CachedNetworkImageProvider(
                        widget.message.model?.image ??
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDwmG52pVI5JZfn04j9gdtsd8pAGbqjjLswg&usqp=CAU",
                      ),
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Image(
                        image: CachedNetworkImageProvider(
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDwmG52pVI5JZfn04j9gdtsd8pAGbqjjLswg&usqp=CAU",
                        ),
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Microphone Icon Overlay
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mic,
                        size: 16,
                        color: AppColorsLight.mainColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Display play/pause button and volume/speed sliders.
            ControlButtons(
                _player!, widget.message.modelId.toString() == widget.myId),
            // Display seek bar. Using StreamBuilder, this widget rebuilds
            // each time the position, buffered position or duration changes.
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return SizedBox(
                  width: (getx.Get.width * 0.50),
                  child: SeekBar(
                    duration: positionData?.duration ?? Duration.zero,
                    position: positionData?.position ?? Duration.zero,
                    bufferedPosition:
                        positionData?.bufferedPosition ?? Duration.zero,
                    onChangeEnd: _player!.seek,
                    isSenderView:
                        widget.message.modelId.toString() == widget.myId,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Pause the player when app goes to background
      _player?.pause();
    }
  }

  @override
  void dispose() {
    // Don't dispose the player here - it's managed by AudioPlayerManager
    // The player persists across widget rebuilds to prevent playback interruption
    super.dispose();
  }
}

/// Displays the play/pause button and volume/speed sliders.
class ControlButtons extends StatelessWidget {
  final AudioPlayer player;
  final bool isSenderView;

  const ControlButtons(this.player, this.isSenderView, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Opens volume slider dialog
        // IconButton(
        //   icon: const Icon(Icons.volume_up),
        //   onPressed: () {
        //     showSliderDialog(
        //       context: context,
        //       title: "Adjust volume",
        //       divisions: 10,
        //       min: 0.0,
        //       max: 1.0,
        //       value: player.volume,
        //       stream: player.volumeStream,
        //       onChanged: player.setVolume,
        //     );
        //   },
        // ),

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  color:
                      isSenderView ? chatSenderTextColor : chatReciverTextColor,
                ),
              );
            } else if (playing != true) {
              return GestureDetector(
                onTap: player.play,
                child: Icon(
                  Icons.play_arrow,
                  color: isSenderView
                      ? chatReciverTextColor
                      : AppColorsLight.mainColor.withValues(alpha: 0.8),
                  size: 35,
                ),
              );
            } else if (processingState != ProcessingState.completed) {
              return SizedBox(
                width: 25,
                height: 25,
                child: GestureDetector(
                  onTap: player.pause,
                  child: Icon(
                    Icons.pause,
                    color: isSenderView
                        ? chatReciverTextColor
                        : AppColorsLight.mainColor.withValues(alpha: 0.8),
                    size: 25,
                  ),
                ),
              );
            } else {
              return GestureDetector(
                child: Icon(
                  Icons.replay,
                  color: isSenderView
                      ? chatReciverTextColor
                      : AppColorsLight.mainColor.withValues(alpha: 0.8),
                  size: 35,
                ),
                onTap: () => player.seek(Duration.zero),
              );
            }
          },
        ),
        // Opens speed slider dialog
        // StreamBuilder<double>(
        //   stream: player.speedStream,
        //   builder: (context, snapshot) => IconButton(
        //     icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
        //         style: const TextStyle(fontWeight: FontWeight.bold)),
        //     onPressed: () {
        //       showSliderDialog(
        //         context: context,
        //         title: "Adjust speed",
        //         divisions: 10,
        //         min: 0.5,
        //         max: 1.5,
        //         value: player.speed,
        //         stream: player.speedStream,
        //         onChanged: player.setSpeed,
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}

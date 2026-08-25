import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// Singleton manager for audio players
/// Maintains a separate AudioPlayer instance for each message ID
/// This prevents players from being disposed when the widget tree rebuilds
class AudioPlayerManager {
  AudioPlayerManager._();
  static final AudioPlayerManager _instance = AudioPlayerManager._();
  factory AudioPlayerManager() => _instance;

  final Map<String, AudioPlayer> _players = {};
  bool _sessionConfigured = false;

  /// Get or create an AudioPlayer for a specific message ID
  Future<AudioPlayer> getPlayer(String messageId) async {
    // Configure audio session on first use
    if (!_sessionConfigured) {
      await _configureAudioSession();
      _sessionConfigured = true;
    }

    // Return existing player if available
    if (_players.containsKey(messageId)) {
      return _players[messageId]!;
    }

    // Create new player
    final player = AudioPlayer();

    // Listen to errors during playback
    player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      debugPrint('Audio player error for message $messageId: $e');
    });

    _players[messageId] = player;
    return player;
  }

  /// Configure the audio session for speech playback
  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } catch (e) {
      debugPrint('Error configuring audio session: $e');
    }
  }

  /// Dispose a specific player (call when message is removed from list)
  Future<void> disposePlayer(String messageId) async {
    final player = _players.remove(messageId);
    if (player != null) {
      await player.dispose();
    }
  }

  /// Pause all players except the one specified
  Future<void> pauseOtherPlayers(String exceptMessageId) async {
    for (final entry in _players.entries) {
      if (entry.key != exceptMessageId && entry.value.playing) {
        await entry.value.pause();
      }
    }
  }

  /// Stop all players
  Future<void> stopAll() async {
    for (final player in _players.values) {
      if (player.playing) {
        await player.stop();
      }
    }
  }

  /// Dispose all players (call on app termination or chat close)
  Future<void> disposeAll() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }

  /// Get the count of active players
  int get playerCount => _players.length;
}

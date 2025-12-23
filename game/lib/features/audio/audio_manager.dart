import 'package:flutter/foundation.dart';

class AudioManager {
  // Singleton instance
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _muted = false;
  double _volume = 1.0;

  bool get isMuted => _muted;
  double get volume => _volume;

  void toggleMute() {
    _muted = !_muted;
    debugPrint('Audio Muted: $_muted');
  }

  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
  }

  void playSfx(String name) {
    if (_muted) return;
    debugPrint('Playing SFX: $name');
    // Actual implementation would use audioplayers or similar
  }

  void playMusic(String name) {
    if (_muted) return;
    debugPrint('Playing Music: $name');
  }
}

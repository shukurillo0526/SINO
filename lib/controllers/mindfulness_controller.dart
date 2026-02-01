import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class NatureSound {
  final String id;
  final String nameEn;
  final String nameKo;
  final String url;
  final IconData icon;

  NatureSound({
    required this.id, 
    required this.nameEn, 
    required this.nameKo, 
    required this.url,
    required this.icon,
  });
}

class MindfulnessController extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  NatureSound? _selectedSound;
  bool _isAudioEnabled = false;

  final List<NatureSound> sounds = [
    NatureSound(
      id: 'forest',
      nameEn: 'Jeju Forest Whisper',
      nameKo: '제주 숲의 속삭임',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', // Placeholder
      icon: Icons.forest,
    ),
    NatureSound(
      id: 'rain',
      nameEn: 'Hallasan Rain',
      nameKo: '한라산의 빗소리',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3', // Placeholder
      icon: Icons.umbrella,
    ),
    NatureSound(
      id: 'waves',
      nameEn: 'Iho Tewoo Waves',
      nameKo: '이호테우 파도 소리',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3', // Placeholder
      icon: Icons.waves,
    ),
  ];

  NatureSound? get selectedSound => _selectedSound;
  bool get isAudioEnabled => _isAudioEnabled;

  void selectSound(NatureSound? sound) {
    _selectedSound = sound;
    if (_isAudioEnabled && sound != null) {
      _play();
    }
    notifyListeners();
  }

  void toggleAudio(bool enabled) {
    _isAudioEnabled = enabled;
    if (enabled) {
      _play();
    } else {
      _stop();
    }
    notifyListeners();
  }

  Future<void> _play() async {
    if (_selectedSound != null && _isAudioEnabled) {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(UrlSource(_selectedSound!.url));
    }
  }

  Future<void> _stop() async {
    await _audioPlayer.stop();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

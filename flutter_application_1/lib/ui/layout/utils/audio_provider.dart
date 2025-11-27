import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../../features/pages/play_page.dart';
import '../../../app/global.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  bool _isInitialized = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Song? _currentSong;

  AudioPlayer get player => _player;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  Song? get currentSong => _currentSong;

  static const String coverBaseUrl = 'http://100.116.248.20/music/';

  Future<void> init() async {
    if (_isInitialized) return;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.durationStream.listen((dur) {
      if (dur != null) _duration = dur;
      notifyListeners();
    });

    _isInitialized = true;
  }

  Future<void> load(String url, {Song? song}) async {
    await init(); 

    if (_currentSong?.hash == song?.hash) return;

    _currentSong = song;

    final source = AudioSource.uri(
      Uri.parse(url),
      tag: MediaItem(id: url, title: song?.song ?? 'Unknown title', album: song?.album ?? 'Unknown album', 
        artist: song?.artist ?? 'Unknown artist', artUri: Uri.parse('$coverBaseUrl${song?.cover}'))
    );

    await _player.setAudioSource(source);
    notifyListeners();
  }

  void play() {
    _player.play();
  }

  void pause() {
    _player.pause();
  }

  void seek(Duration position) {
    _player.seek(position);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void toggleLike(String? hash) async {
    await Globals.likeUnlike(hash);

    // Update the current song’s like status
    if (_currentSong?.hash == hash) {
      _currentSong!.liked = _currentSong!.liked == 1 ? 0 : 1;
    }

    notifyListeners(); // 🔔 Notify UI everywhere
  }
}

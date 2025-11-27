import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/components/nav_bar.dart';
import '../../ui/layout/utils/audio_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../app/global.dart';

class Song {
  String? file;
  String? hash;
  String? artist;
  String? album;
  String? song;
  String? cover;
  int? liked;

  Song({this.file, 
    this.hash, 
    this.artist, 
    this.album, 
    this.song, 
    this.cover,
    this.liked,
  });

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        file: json['file'],
        hash: json['hash'],
        artist: json['artist'],
        album: json['album'],
        song: json['song'],
        cover: json['cover'],
        liked: json['liked'] ?? 0,
      );
}

Future<Song> getData(String? hash) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('userToken');
  final response = await http.get(
    Uri.parse('http://100.116.248.20:3000/music/$hash'),
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": 'Bearer $token'
    },
  );

  if (response.statusCode == 200) {
    return Song.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load song');
  }
}

class PlayPage extends StatefulWidget {
  final String? hash;
  final List<Map<String, dynamic>>? playlist;

  const PlayPage({super.key, required this.hash, this.playlist});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  static const String baseUrl = 'http://100.116.248.20/music/';
  Song? currentSong;
  bool isLoading = true;
  List<Map<String, dynamic>> actualPlaylist = [];

  List<Map<String, dynamic>> get playlist => widget.playlist ?? [];

  @override
  void initState() {
    super.initState();
    _loadSong(widget.hash);
  }

  Future<void> _loadSong(String? hash) async {
    if (hash == null) return;
    if (playlist.isNotEmpty) {
      Globals.playlist = playlist;
    }
    actualPlaylist = playlist.isEmpty ? Globals.playlist : playlist;
    
    final audioProvider = context.read<AudioProvider>();

    if (audioProvider.currentSong != null && audioProvider.currentSong!.hash == hash) {
      setState(() {
        currentSong = audioProvider.currentSong;
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = true);

    try {
      final song = await getData(hash);
      await audioProvider.load('$baseUrl${song.file}', song: song);
      audioProvider.play();

      setState(() {
        currentSong = song;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading song: $e');
      setState(() => isLoading = false);
    }
  }

  void playNext() {
    if (actualPlaylist.length <= 1 || currentSong == null) return;
    final currentIndex = actualPlaylist.indexWhere((s) => s['hash'] == currentSong!.hash);
    final nextIndex = (currentIndex + 1) % actualPlaylist.length;
    _loadSong(actualPlaylist[nextIndex]['hash']);
  }

  void playPrevious() {
    if (actualPlaylist.length <= 1 || currentSong == null) return;
    final currentIndex = actualPlaylist.indexWhere((s) => s['hash'] == currentSong!.hash);
    final prevIndex = (currentIndex - 1 + actualPlaylist.length) % actualPlaylist.length;
    _loadSong(actualPlaylist[prevIndex]['hash']);
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();

    return Scaffold(
      body: isLoading || currentSong == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  '$baseUrl${currentSong!.cover}',
                  fit: BoxFit.cover,
                ),
                Container(color: Colors.black.withValues(alpha: 0.6)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentSong!.song ?? 'Unknown Song',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentSong!.artist ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40, width: 60,),
                        IconButton(
                          iconSize: 48,
                          color: actualPlaylist.length > 1 ? Colors.cyanAccent : Colors.grey,
                          icon: const Icon(Icons.skip_previous),
                          onPressed: actualPlaylist.length > 1 ? playPrevious : null,
                        ),
                        IconButton(
                          iconSize: 72,
                          color: Colors.cyanAccent,
                          icon: Icon(audio.isPlaying ? Icons.pause_circle : Icons.play_circle),
                          onPressed: () {
                            if (audio.isPlaying) {
                              audio.pause();
                            } else {
                              audio.play();
                            }
                          },
                        ),
                        IconButton(
                          iconSize: 48,
                          color: actualPlaylist.length > 1 ? Colors.cyanAccent : Colors.grey,
                          icon: const Icon(Icons.skip_next),
                          onPressed: actualPlaylist.length > 1 ? playNext : null,
                        ),
                        IconButton(
                          icon: Icon((currentSong?.liked ?? 0) == 1 ? Icons.favorite : Icons.favorite_border,
                          color: (currentSong?.liked ?? 0) == 1 ? Colors.red : Colors.white,
                          size: 40,),
                          onPressed: () async {
                            if (currentSong?.hash == null) return;
                            context.read<AudioProvider>().toggleLike(currentSong?.hash);
                          },
                        ),
                      ],
                    ),
                    Slider(
                      activeColor: Colors.cyanAccent,
                      inactiveColor: Colors.white,
                      min: 0,
                      max: audio.duration.inSeconds.toDouble(),
                      value: audio.position.inSeconds.clamp(0, audio.duration.inSeconds).toDouble(),
                      onChanged: (value) {
                        audio.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatTime(audio.position), style: const TextStyle(color: Colors.white)),
                          Text(_formatTime(audio.duration), style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
      bottomNavigationBar: const NavBar(),
    );
  }
}

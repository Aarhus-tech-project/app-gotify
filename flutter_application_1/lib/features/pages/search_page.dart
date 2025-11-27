// ignore_for_file: sort_child_properties_last
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../ui/layout/page_scaffold.dart';
import '../../ui/components/nav_bar.dart';
import '../../ui/components/song_list.dart';
import '../../app/global.dart';
import '../../app/route_observer.dart';
import '../../ui/components/profile_icon.dart';
import '../../ui/layout/utils/audio_provider.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _results = [];
  Timer? _debounce;
  bool _isLoading = false;
  String? _token;
  bool _songAdded = false;
  final List<Map<String, dynamic>> _playlists = [];

  // List<String> _recentSearches = [];

  static const String baseUrl = 'http://100.116.248.20';
  static const String apiUrl = '$baseUrl:3000/music/search';
  static const String musicBaseUrl = '$baseUrl/music/';

  @override
  void initState() {
    super.initState();
    _loadToken();
    //_loadRecentSearches();
  }

  Future<void> _fetchPlaylists() async {
    if (_token == null) {
      debugPrint('No auth token found.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl:3000/playlist'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _playlists
            ..clear()
            ..addAll(
              data.map((item) => {'id': item['id'], 'name': item['name']}),
            );
        });
      } else {
        debugPrint('Failed to load playlists: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching playlists: $e');
    }
  }

  Future<void> _apiAddToPlaylist(String? hash, int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/playlist/add/$id'),
      headers: {
        'Authorization': 'Bearer $_token',
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: jsonEncode(<String, String?>{"hash": hash}),
    );

    if (response.statusCode == 200) {
      _songAdded = true;
    }
  }

  Future<void> _addSongToPlaylist(String? hash) async {
    if (_token == null) return;

    await _fetchPlaylists();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Playlist',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._playlists.map((playlist) {
                return ListTile(
                  title: Text(playlist['name']),
                  onTap: () async {
                    Navigator.pop(context); // Close the sheet
                    await _apiAddToPlaylist(hash, playlist['id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Song added to ${playlist['name']}'),
                      ),
                    );
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('userToken');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.isNotEmpty) {
        _fetchResults(query);
      } else {
        setState(() => _results = []);
      }
    });
  }

  Future<void> _fetchResults(String query) async {
    if (_token == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $_token",
        },
        body: jsonEncode({"query": query}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() => _results = data);
      } else {
        setState(() => _results = []);
      }
    } catch (e) {
      setState(() => _results = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;

        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop(_songAdded);
        } else {
          router.goNamed('home');
        }
      },
      child: PageScaffold(
        title: 'Search',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop(_songAdded);
            } else {
              router.goNamed('home');
            }
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ProfileIcon(),
          ),
        ],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: TextField(
                controller: _controller,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey),
                  hintText: 'Search songs, albums, artists...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),

            if (_isLoading) const LinearProgressIndicator(),

            Expanded(
              child: Consumer<AudioProvider>(
                builder: (context, audio, _) {
                  return _controller.text.isEmpty
                      ? ListView.builder(
                          itemCount: Globals.recentSearches.length,
                          itemBuilder: (context, index) {
                            final recentSong = jsonDecode(Globals.recentSearches[index]);
                            return SongList(
                              hash: recentSong['hash'],
                              title: recentSong['songName'] ?? 'Unknown Song',
                              artist: recentSong['artist'] ?? 'Unknown Artist',
                              album: recentSong['album'] ?? 'Unknown Album',
                              coverUrl: recentSong['cover'],
                              liked: Globals.likeStatus[recentSong['hash']] ?? recentSong['liked'],
                              onAddToPlaylist: _addSongToPlaylist,
                              onSongTapped: (encodedSong) async {
                                await Globals.addRecentSearches(encodedSong);
                                setState(() {});
                              },
                              onLikeToggle: Globals.likeUnlike,
                              onGlobalLikeChanged: () => setState(() {}),
                            );
                          },
                        )
                      : (_results.isEmpty
                          ? const Center(child: Text('No results yet'))
                          : ListView.builder(
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final song = _results[index];
                                return SongList(
                                  hash: song['hash'],
                                  title: song['song'] ?? 'Unknown Song',
                                  artist: song['artist'] ?? 'Unknown Artist',
                                  album: song['album'],
                                  coverUrl: song['cover'],
                                  liked: Globals.likeStatus[song['hash']] ?? song['liked'],
                                  onAddToPlaylist: _addSongToPlaylist,
                                  onSongTapped: (encodedSong) async {
                                    await Globals.addRecentSearches(encodedSong);
                                    setState(() {});
                                  },
                                  onLikeToggle: Globals.likeUnlike,
                                  onGlobalLikeChanged: () => setState(() {}),
                                );
                              },
                            ));
                },
              ),
            ),

          ],
        ),
        bottomNavigationBar: const NavBar(),
      ),
    );
  }
}

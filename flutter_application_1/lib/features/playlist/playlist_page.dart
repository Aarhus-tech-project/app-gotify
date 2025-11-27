import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/layout/page_scaffold.dart';
import '../../ui/components/primary_button.dart';
import '../../ui/components/nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../pages/play_page.dart';
import '../../app/global.dart';
import '../../app/route_observer.dart';
import '../../ui/components/song_list.dart';  

class PlaylistPage extends StatefulWidget {
  final dynamic playlistId;
  final String playlistName;

  const PlaylistPage({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> with RouteAware {
  final List<Map<String, dynamic>> _songs = [];
  bool _loading = true;
  String? _token;

  static const String baseUrl = 'http://100.116.248.20';
  static const String baseCoverUrl = 'http://100.116.248.20/music/';

  @override
  void initState() {
    super.initState();
    _loadToken();
    _fetchSongs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _fetchSongs();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('userToken');
    });
  }

  void _openPlaylistSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Rename Playlist'),
                  onTap: () {
                    Navigator.pop(context);
                    _renamePlaylistDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete Playlist',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeletePlaylist();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _renamePlaylistDialog() async {
    final controller = TextEditingController(text: widget.playlistName);
    final formKey = GlobalKey<FormState>();
    String? newName;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Rename Playlist'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter a name' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  newName = controller.text.trim();
                  Navigator.pop(context);
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );

    if (newName == null || newName == widget.playlistName) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    if (token == null) return;

    try {
      final response = await http.put(
        Uri.parse('http://100.116.248.20:3000/playlist/${widget.playlistId}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': newName}),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Playlist renamed successfully')));
        context.pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to rename: ${response.body}')),
        );
      }
    } catch (e) {
      debugPrint('Rename error: $e');
    }
  }

  Future<void> _confirmDeletePlaylist() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Playlist'),
          content: const Text('Are you sure you want to delete this playlist?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token == null) return;

    try {
      final response = await http.delete(
        Uri.parse(
          'http://100.116.248.20:3000/playlist/${widget.playlistId}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Playlist deleted')));
        context.pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${response.body}')),
        );
      }
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  Future<void> _fetchSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token == null) {
      debugPrint('No auth token found.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://100.116.248.20:3000/playlist/${widget.playlistId}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final playlistData = jsonDecode(response.body);
        final songs = playlistData['music'] ?? [];

        setState(() {
          _songs
            ..clear()
            ..addAll(List<Map<String, dynamic>>.from(songs));
          Globals.playlist..clear()..addAll(_songs);
          _loading = false;
        });
      } else {
        debugPrint('Failed to fetch songs: ${response.body}');
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('Error fetching songs $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: widget.playlistName,
      bottomNavigationBar: const NavBar(),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _openPlaylistSettings,
        ),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty
          ? _buildEmptyState(context)
          : _buildSongList(),

    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "This playlist has no songs yet.",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: "Add song to this playlist",
            onPressed: () => context.pushNamed('search'),
          ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    return ListView.builder(
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final song = _songs[index];
        return SongList(
          hash: song['hash'],
          title: song['song'] ?? 'Unknown Song',
          artist: song['artist'] ?? 'Unknown Artist',
          album: song['album'],
          coverUrl: song['cover'],
          liked: song['liked'],
          onAddToPlaylist: null,
          addToRecentSearch: false,
          onSongTapped: (encodedSong) async {
            await Globals.addRecentSearches(encodedSong);
            setState(() {});
          },
          onLikeToggle: Globals.likeUnlike,
          onGlobalLikeChanged: () => setState(() {
            final likeIndex = _songs.indexWhere((s) => s['hash'] == song['hash']);
            if (likeIndex != -1) {
              _songs[likeIndex]['liked'] = _songs[likeIndex]['liked'] == 1 ? 0 : 1;
            }
          }),
        );
      },
    );
  }
}

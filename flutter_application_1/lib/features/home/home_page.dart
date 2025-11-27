import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/layout/page_scaffold.dart';
import '../../ui/components/primary_button.dart';
import '../../ui/components/nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../app/global.dart';
import '../../ui/components/profile_icon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final List<Map<String, dynamic>> _playlists = [];

  @override
  void initState() {
    super.initState();
    _fetchPlaylists();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('recentSearches');
    final List<String>? storedSearches = prefs.getStringList('recentSearches');
    setState(() {
      Globals.recentSearches = storedSearches ?? [];
    });
  }

  Future<void> _fetchPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token == null) {
      debugPrint('No auth token found.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://100.116.248.20:3000/playlist'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _playlists
            ..clear()
            ..addAll(data.map((item) =>{
              'id': item['id'],
              'name': item['name'],
            }));
        });
      } else {
        debugPrint('Failed to load playlists: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching playlists: $e');
    }
  }

  void _goToProfile() {
    context.push('/profile');
  }

  Future<void> _createPlaylistDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? newPlaylistName;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Create Playlist'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Playlist Name',
                hintText: 'e.g My Favorite Songs',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  newPlaylistName = controller.text.trim();
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (newPlaylistName == null || newPlaylistName!.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token == null) {
      debugPrint('No auth token found, user not logged in.');
      _showErrorDialog('You must be logged in to create a playlist.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://100.116.248.20:3000/playlist'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': newPlaylistName}),
      );

      if (response.statusCode == 200) {
        await _fetchPlaylists();
        setState(() {});
      } else {
        debugPrint('Failed to create playlist: ${response.body}');
        _showErrorDialog('Failed to create playlist: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error creating playlist: $e');
      _showErrorDialog('Error creating playlist: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Home',
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: ProfileIcon(),
        )
      ],
      child: _playlists.isEmpty ? _buildEmptyState(context) : _buildPlaylistList(context),
      bottomNavigationBar: const NavBar(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No playlists yet.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first playlist to get started!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Create Playlist',
            onPressed: _createPlaylistDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistList(BuildContext context) {
    return Column(
      children: [
        // List of playlists
        Expanded(
          child: ListView.builder(
            itemCount: _playlists.length,
            itemBuilder: (context, index) {
              final playlist = _playlists[index];
              return Card(
                color: Theme.of(context).colorScheme.surface,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(playlist['name']),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final id = playlist['id'];
                    final name = playlist['name'];
                    
                    final changed = await context.pushNamed(
                      'playlist',
                      pathParameters: {'id': id.toString()},
                      queryParameters: {'name': name},
                    );

                    if (changed == true) {
                      _fetchPlaylists();
                    }
                  },
                ),
              );
            },
          ),
        ),

        // Create Playlist button at the bottom
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Create Playlist',
          onPressed: _createPlaylistDialog,
        ),
      ],
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
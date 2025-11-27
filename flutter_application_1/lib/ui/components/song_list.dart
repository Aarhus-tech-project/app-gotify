import 'dart:convert';
import 'package:flutter/material.dart';
import '../../app/global.dart';
import '../../features/pages/play_page.dart';

class SongList extends StatefulWidget {
  final String? hash;
  final String title;
  final String artist;
  final String? album;
  final String? coverUrl;
  final int? liked;
  final bool addToRecentSearch;
  final Future<void> Function(String?)? onAddToPlaylist;
  final Future<void> Function(String)? onSongTapped;
  final Future<void> Function(String?)? onLikeToggle;
  final VoidCallback? onGlobalLikeChanged;

  static const String coverBaseUrl = 'http://100.116.248.20/music/';

  const SongList({
    super.key,
    required this.hash,
    required this.title,
    required this.artist,
    this.album,
    this.coverUrl,
    this.liked,
    this.onAddToPlaylist,
    this.onSongTapped,
    this.addToRecentSearch = true,
    this.onLikeToggle,
    this.onGlobalLikeChanged,
  });

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {


  Future<void> _toggleLike() async {
    try {
      await widget.onLikeToggle!(widget.hash);
      widget.onGlobalLikeChanged?.call();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update like status')),
      );
    }
  }

  bool get isLiked {
    final globalLike = Globals.likeStatus[widget.hash];
    if (globalLike != null) return globalLike == 1;
    return widget.liked == 1;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.coverUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                '${SongList.coverBaseUrl}${widget.coverUrl}',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
              ),
            )
          : const Icon(Icons.music_note),
      title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        widget.album != null && widget.album!.isNotEmpty
            ? '${widget.artist} — ${widget.album}'
            : widget.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _openPlayer(context),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Colors.white,
            ),
            onPressed: _toggleLike,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'add_to_playlist' &&
                  widget.onAddToPlaylist != null) {
                await widget.onAddToPlaylist!(widget.hash);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Song added to playlist')),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'add_to_playlist',
                child: Text('Add to playlist'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openPlayer(BuildContext context) async {
    if (widget.addToRecentSearch) {
      await widget.onSongTapped?.call(jsonEncode({
        'hash': widget.hash,
        'songName': widget.title,
        'artist': widget.artist,
        'album': widget.album,
        'cover': widget.coverUrl,
        'liked': isLiked ? 1 : 0,
      }));
    }
                                                                 
    if (!Globals.playerIsOpen) {
      Globals.playerIsOpen = true;
      if (ModalRoute.of(context)?.settings.name != 'playlist') {
        Globals.playlist.clear();
      }
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => FractionallySizedBox(
          heightFactor: 1,
          child: PlayPage(hash: widget.hash),
        ),
      );
      Globals.playerIsOpen = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layout/utils/audio_provider.dart';
import '../../features/pages/play_page.dart';
import '../../app/global.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();

    if (audio.currentSong == null) return const SizedBox.shrink();

    final song = audio.currentSong!;

    return GestureDetector(
      onTap: () async {

        if (Globals.playerIsOpen) return;
        Globals.playerIsOpen = true;

        if (song.hash != null) {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => FractionallySizedBox(
              heightFactor: 1,
              child: PlayPage(hash: song.hash),
            ),
          );
        }
        Globals.playerIsOpen = false;
      },
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.1),
          border: const Border(
            top: BorderSide(color: Colors.grey, width: 0.3),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                song.cover != null
                    ? 'http://100.116.248.20/music/${song.cover}'
                    : '',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    song.song ?? 'Unknown Song',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    song.artist ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                song.liked == 1 ? Icons.favorite : Icons.favorite_border,
                color: song.liked == 1 ? Colors.red : Colors.white,
              ),
              onPressed: () async {
                if (song.hash == null) return;
                context.read<AudioProvider>().toggleLike(song.hash!);
              },
            ),
            IconButton(
              icon: Icon(
                audio.isPlaying ? Icons.pause_circle : Icons.play_circle,
                color: Colors.cyanAccent,
                size: 36,
              ),
              onPressed: () {
                if (audio.isPlaying) {
                  audio.pause();
                } else {
                  audio.play();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

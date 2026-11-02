import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../model/song.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key, required this.song, required this.player});

  final Song song;
  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now playing'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C35B4), Color(0xFFBE6BDA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x553F176E),
                    blurRadius: 28,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 112,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 34),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                song.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Local file',
                style: TextStyle(color: Color(0xFF9B93A6), fontSize: 15),
              ),
            ),
            const SizedBox(height: 28),
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = player.duration ?? Duration.zero;
                final maximum = duration.inMilliseconds.toDouble();
                final value = maximum == 0
                    ? 0.0
                    : position.inMilliseconds
                          .clamp(0, duration.inMilliseconds)
                          .toDouble();
                return Column(
                  children: [
                    Slider(
                      value: value,
                      max: maximum == 0 ? 1 : maximum,
                      onChanged: maximum == 0
                          ? null
                          : (newValue) => player.seek(
                              Duration(milliseconds: newValue.round()),
                            ),
                      activeColor: const Color(0xFFB36CFF),
                      inactiveColor: const Color(0xFF352C43),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position)),
                        Text(_formatDuration(duration)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data?.playing ?? player.playing;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => player.seekToPrevious(),
                      icon: const Icon(Icons.skip_previous_rounded),
                      iconSize: 34,
                    ),
                    const SizedBox(width: 20),
                    IconButton.filled(
                      onPressed: isPlaying ? player.pause : player.play,
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      iconSize: 36,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF9B5CFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () => player.seekToNext(),
                      icon: const Icon(Icons.skip_next_rounded),
                      iconSize: 34,
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

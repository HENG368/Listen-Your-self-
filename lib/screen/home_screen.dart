import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../model/song.dart';
import '../screen/player_screen.dart';

class MyHomePageState extends State<MyHomePage> {
  final AudioPlayer _player = AudioPlayer();
  final TextEditingController _searchController = TextEditingController();
  final List<Song> _songs = [];
  static const _bundledSongs = [
    'assets/Audio/ABBA_Lay_All_Your_Love_On_Me_Official_Lyric_VideoM4A_128K.m4a',
    'assets/Audio/Maroon 5 - Sunday Morning(M4A_128K).m4a',
    'assets/Audio/Maroon_5_Won_t_Go_Home_Without_You_Official_Music_VideoM4A_128K.m4a',
  ];

  String _searchQuery = '';
  Song? _currentSong;
  String? _errorMessage;
  List<Song> get _filteredSongs {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return List.unmodifiable(_songs);
    }
    return _songs
        .where((song) => song.title.toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadLibrary() async {
    final preferences = await SharedPreferences.getInstance();
    final paths = preferences.getStringList('local_music_paths') ?? [];
    if (!mounted) {
      return;
    }
    setState(() {
      _songs.addAll(
        _bundledSongs.map((path) => Song(path: path, title: _titleFor(path))),
      );
      _songs.addAll(
        paths.map(
          (path) => Song(
            path: path,
            title: _titleFor(path.split(RegExp(r'[/\\]')).last),
          ),
        ),
      );
    });
  }

  Future<void> _importSongs() async {
    setState(() {
      _errorMessage = null;
    });
    try {
      // List<PlatformFile> songs = [];
      final result = await FilePicker.pickFiles(type: FileType.audio);
      // final result = await FilePicker.pickFiles(type: FileType.audio);
      if (result.isEmpty) {
        return;
      }
      final imported = result
          .where((file) => file.path != null)
          .map((file) => Song(path: file.path!, title: _titleFor(file.name)))
          .where(
            (song) => !_songs.any((existing) => existing.path == song.path),
          )
          .toList();
      if (imported.isNotEmpty && mounted) {
        setState(() => _songs.addAll(imported));
        final preferences = await SharedPreferences.getInstance();
        await preferences.setStringList(
          'local_music_paths',
          _songs.map((song) => song.path).toList(),
        );
      }
    } on Exception catch (error) {
      if (mounted) {
        setState(() => _errorMessage = 'Could not import music: $error');
      }
    }
  }

  String _titleFor(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    return lastDot > 0 ? fileName.substring(0, lastDot) : fileName;
  }

  Future<void> _playSong(Song song) async {
    try {
      setState(()  {
        _currentSong = song;
        _errorMessage = null;
      });
      await _player.stop();
      await _player.setFilePath(song.path);
      await _player.play();
      
    } on Exception catch (error) {
      if (mounted) {
        setState(
          () => _errorMessage = 'Could not play "${song.title}": $error',
        );
      }
    }
  }

  Future<void> _togglePlayback() async {
    if (_currentSong == null) {
      if (_songs.isNotEmpty) {
        await _playSong(_songs.first);
      }
      return;
    }
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _removeSong(Song song) async {
    if (_currentSong?.path == song.path) {
      await _player.stop();
      if (mounted) {
        setState(() => _currentSong = null);
      }
    }
    setState(() => _songs.removeWhere((item) => item.path == song.path));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      'local_music_paths',
      _songs.map((item) => item.path).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 130),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildLibraryHeader(),
                  const SizedBox(height: 12),
                  if (_errorMessage != null) _buildErrorMessage(),
                  if (_filteredSongs.isEmpty)
                    _buildEmptyState()
                  else
                    ..._filteredSongs.map(_buildSongTile),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildNowPlayingBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF18131F),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF332344)),
            ),
            child: Image.asset('assets/logomusic.png'),
          ),
          const SizedBox(width: 12),
          Text(
            widget.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          IconButton(
            onPressed: _importSongs,
            tooltip: 'Import music',
            icon: const Icon(Icons.library_add_rounded),
            color: const Color(0xFFB36CFF),
          ),
          const CircleAvatar(
            radius: 19,
            backgroundColor: Color(0xFF6D3FB1),
            child: Icon(Icons.person_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryHeader() {
    return Row(
      children: [
        const Text(
          'Local music',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        SizedBox(
          width: 150,
          height: 40,
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search library',
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      icon: const Icon(Icons.close_rounded, size: 16),
                    ),
              filled: true,
              fillColor: const Color(0xFF15141B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF111016),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF24202D)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.library_music_outlined,
            size: 42,
            color: Color(0xFF9B5CFF),
          ),
          const SizedBox(height: 12),
          Text(
            _songs.isEmpty ? 'Your library is empty' : 'No songs found',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            _songs.isEmpty
                ? 'Choose audio files from your device to start listening.'
                : 'Try a different search term.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8F8999), height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        _errorMessage!,
        style: const TextStyle(color: Color(0xFFFF8B9D), fontSize: 12),
      ),
    );
  }

  Widget _buildSongTile(Song song) {
    final isCurrent = _currentSong?.path == song.path;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 3),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: const LinearGradient(
            colors: [Color(0xFF6C35B4), Color(0xFFBE6BDA)],
          ),
        ),
        child: Icon(
          isCurrent && _player.playing
              ? Icons.equalizer_rounded
              : Icons.music_note_rounded,
          color: Colors.white,
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Text('Local file', style: TextStyle(color: Color(0xFF8F8999))),
      ),
      onTap: () => _playSong(song),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'remove') {
            _removeSong(song);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'remove', child: Text('Remove from library')),
        ],
        icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF8F8999)),
      ),
    );
  }

  Widget _buildNowPlayingBar() {
    if (_currentSong == null) {
      return NavigationBar(
        height: 72,
        backgroundColor: const Color(0xFF0F0E14),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music_rounded),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
      );
    }
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PlayerScreen(song: _currentSong!, player: _player),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        decoration: const BoxDecoration(
          color: Color(0xFF17131F),
          border: Border(top: BorderSide(color: Color(0xFF30223E))),
        ),
        child: Row(
          children: [
            const Icon(Icons.music_note_rounded, color: Color(0xFFB36CFF)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _currentSong!.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: _togglePlayback,
              icon: Icon(
                _player.playing
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
              ),
              color: Colors.white,
              tooltip: 'Play or pause',
            ),
          ],
        ),
      ),
    );
  }
}

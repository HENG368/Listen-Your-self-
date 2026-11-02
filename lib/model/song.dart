class Song {
  const Song({required this.path, required this.title});

  final String path;
  final String title;

  String get artist => 'Local file';
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/song_model.dart';
import '../services/storage_service.dart';
import '../config/app_colors.dart';
import '../widgets/result_section.dart';

class SongDetailScreen extends StatefulWidget {
  final SongModel song;
  const SongDetailScreen({super.key, required this.song});

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  late SongModel _currentSong;
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _currentSong = widget.song;
  }

  String? _extractYouTubeVideoId(String url) {
    final patterns = [
      RegExp(r'youtube\.com/watch\?v=([^&]+)'),
      RegExp(r'youtu\.be/([^?]+)'),
      RegExp(r'youtube\.com/embed/([^?]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  void _onTokenTap(int lineIndex, int tokenIndex) async {
    setState(() {
      final token = _currentSong.lines[lineIndex][tokenIndex];
      token.isSelected = !token.isSelected;
    });

    final allSongs = await _storage.loadSongs();
    final index = allSongs.indexWhere((s) => s.id == _currentSong.id);
    if (index != -1) {
      allSongs[index] = _currentSong;
      await _storage.saveSongs(allSongs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_currentSong.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Единна информационна лента
            _buildInfoBar(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ResultSection(
                lines: _currentSong.lines,
                translation: _currentSong.translation.isNotEmpty
                    ? _currentSong.translation
                    : null,
                onTokenTap: _onTokenTap,
                isViewMode: true, // Нов параметър за "Текст на песента"
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Единна информационна лента с всичко
  Widget _buildInfoBar() {
    final videoId = _extractYouTubeVideoId(_currentSong.youtubeLink);
    final sourceLinks = _currentSong.sourceLinks;
    final hasYoutube = _currentSong.youtubeLink.isNotEmpty && videoId != null;
    final hasSourceLinks = sourceLinks.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, const Color(0xFF7E57C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Заглавие и изпълнител
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentSong.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _currentSong.artist,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Линкове към текста
          if (hasSourceLinks) ...[
            const SizedBox(width: 16),
            ...sourceLinks.take(2).map((link) {
              final displayText = Uri.tryParse(link)?.host ?? 'Линк';
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => launchUrl(Uri.parse(link)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lyrics, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          displayText.length > 15
                              ? '${displayText.substring(0, 15)}...'
                              : displayText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],

          // YouTube thumbnail (малък)
          if (hasYoutube) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(_currentSong.youtubeLink)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
                        width: 80,
                        height: 45,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 45,
                            color: Colors.black54,
                            child: const Icon(Icons.play_circle, color: Colors.white, size: 24),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
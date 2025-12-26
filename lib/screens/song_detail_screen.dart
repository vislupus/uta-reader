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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            // Линкове на един ред
            _buildLinksRow(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ResultSection(
                lines: _currentSong.lines,
                translation: _currentSong.translation.isNotEmpty 
                    ? _currentSong.translation 
                    : null,
                onTokenTap: _onTokenTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, const Color(0xFF7E57C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentSong.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                _currentSong.artist,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// YouTube thumbnail + линкове на един ред
  Widget _buildLinksRow() {
    final videoId = _extractYouTubeVideoId(_currentSong.youtubeLink);
    final sourceLinks = _currentSong.sourceLinks;
    
    final hasYoutube = _currentSong.youtubeLink.isNotEmpty && videoId != null;
    final hasSourceLinks = sourceLinks.isNotEmpty;
    
    if (!hasYoutube && !hasSourceLinks) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // YouTube thumbnail (малък)
          if (hasYoutube)
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(_currentSong.youtubeLink)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
                      width: 160,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 160,
                          height: 90,
                          color: Colors.black87,
                          child: const Icon(Icons.video_library, size: 40, color: Colors.white54),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          
          if (hasYoutube && hasSourceLinks) const SizedBox(width: 16),
          
          // Линкове към текста
          if (hasSourceLinks)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lyrics, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Източници на текста',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...sourceLinks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final link = entry.value;
                    final displayText = Uri.tryParse(link)?.host ?? 'Линк ${index + 1}';
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        onTap: () => launchUrl(Uri.parse(link)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.link, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                displayText,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
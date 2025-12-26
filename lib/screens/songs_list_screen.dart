// screens/songs_list_screen.dart
import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/storage_service.dart';
import '../config/app_colors.dart';
import '../config/app_texts.dart';
import 'analyzer_screen.dart';
import 'song_detail_screen.dart';

class SongsListScreen extends StatefulWidget {
  const SongsListScreen({super.key});

  @override
  State<SongsListScreen> createState() => _SongsListScreenState();
}

class _SongsListScreenState extends State<SongsListScreen> {
  final StorageService _storage = StorageService();
  List<SongModel> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final songs = await _storage.loadSongs();
    setState(() {
      _songs = songs;
      _isLoading = false;
    });
  }

  double _calculateProgress(SongModel song) {
    int meaningfulCount = 0;
    int selectedCount = 0;
    for (var line in song.lines) {
      for (var token in line) {
        if (token.isMeaningful) {
          meaningfulCount++;
          if (token.isSelected) selectedCount++;
        }
      }
    }
    return meaningfulCount > 0 ? selectedCount / meaningfulCount : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppTexts.songsListTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty
              ? Center(child: Text(AppTexts.noSongs))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _songs.length,
                  itemBuilder: (context, index) {
                    final song = _songs[index];
                    final progress = _calculateProgress(song);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(song.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(song.artist),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.surfaceVariant,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        trailing: Text('${(progress * 100).toInt()}%', 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SongDetailScreen(song: song)),
                          );
                          _loadSongs(); // Обнови списъка при връщане
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AnalyzerScreen()),
          );
          _loadSongs();
        },
        label: const Text(AppTexts.analyzeNew),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.secondary,
      ),
    );
  }
}
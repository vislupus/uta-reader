import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/storage_service.dart';
import '../config/app_colors.dart';
import '../config/app_texts.dart';
import 'analyzer_screen.dart';
import 'song_detail_screen.dart';
import 'edit_song_screen.dart';

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

  Future<void> _deleteSong(SongModel song) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изтриване на песен'),
        content: Text('Сигурен ли си, че искаш да изтриеш "${song.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отказ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Изтрий'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storage.deleteSong(song.id);
      _loadSongs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${song.title} беше изтрита')),
        );
      }
    }
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
              ? _buildEmptyState()
              : _buildSongsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AnalyzerScreen()),
          );
          _loadSongs();
        },
        label: const Text('Нова песен'),
        icon: const Icon(Icons.add),
        foregroundColor: Colors.white,
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_off, size: 80, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            AppTexts.noSongs,
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnalyzerScreen()),
              );
              _loadSongs();
            },
            icon: const Icon(Icons.add),
            label: const Text('Добави първата песен'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final song = _songs[index];
        final progress = _calculateProgress(song);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SongDetailScreen(song: song)),
              );
              _loadSongs();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Прогрес индикатор (кръгъл)
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 4,
                              backgroundColor: AppColors.surfaceVariant,
                              color: progress == 1.0 
                                  ? Colors.green 
                                  : AppColors.primary,
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Заглавие и изпълнител
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.person, 
                                  size: 14, 
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  song.artist,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Бутони за редакция и триене
                      IconButton(
                        icon: Icon(Icons.edit, color: AppColors.primary),
                        tooltip: 'Редактирай',
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditSongScreen(song: song),
                            ),
                          );
                          _loadSongs();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: AppColors.error),
                        tooltip: 'Изтрий',
                        onPressed: () => _deleteSong(song),
                      ),
                    ],
                  ),
                  
                  // Линеен прогрес бар
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceVariant,
                      color: progress == 1.0 ? Colors.green : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_texts.dart';
import '../models/song_model.dart';
import '../services/storage_service.dart';

class EditSongScreen extends StatefulWidget {
  final SongModel song;

  const EditSongScreen({super.key, required this.song});

  @override
  State<EditSongScreen> createState() => _EditSongScreenState();
}

class _EditSongScreenState extends State<EditSongScreen> {
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _sourceLinkController;
  late TextEditingController _youtubeLinkController;

  final StorageService _storage = StorageService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.song.title);
    _artistController = TextEditingController(text: widget.song.artist);
    _sourceLinkController = TextEditingController(text: widget.song.sourceLink);
    _youtubeLinkController = TextEditingController(text: widget.song.youtubeLink);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _sourceLinkController.dispose();
    _youtubeLinkController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      _showError('Моля, въведи заглавие');
      return;
    }
    if (_artistController.text.trim().isEmpty) {
      _showError('Моля, въведи изпълнител');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedSong = SongModel(
        id: widget.song.id,
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        sourceLink: _sourceLinkController.text.trim(),
        youtubeLink: _youtubeLinkController.text.trim(),
        translation: widget.song.translation,
        lines: widget.song.lines,
      );

      final allSongs = await _storage.loadSongs();
      final index = allSongs.indexWhere((s) => s.id == widget.song.id);
      if (index != -1) {
        allSongs[index] = updatedSong;
        await _storage.saveSongs(allSongs);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Промените са запазени')),
        );
      }
    } catch (e) {
      _showError('Грешка при запазване: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Редактирай песен'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check, color: Colors.white),
            label: Text(
              _isSaving ? 'Запазване...' : 'Запази',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: AppTexts.songTitle,
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _artistController,
              decoration: InputDecoration(
                labelText: AppTexts.artist,
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _youtubeLinkController,
              decoration: InputDecoration(
                labelText: AppTexts.youtubeUrl,
                prefixIcon: const Icon(Icons.play_circle_filled, color: Colors.red),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
                hintText: 'https://youtube.com/...',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sourceLinkController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '${AppTexts.sourceUrl} (по един на ред)',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.link),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
                hintText: 'https://...\nhttps://...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Запазване...' : 'Запази промените'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
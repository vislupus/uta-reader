import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../config/app_colors.dart';
import '../config/app_texts.dart';
import '../models/word_token.dart';
import '../models/song_model.dart';
import '../services/japanese_service.dart';
import '../services/storage_service.dart';
import '../widgets/input_section.dart';
import '../widgets/result_section.dart';

class AnalyzerScreen extends StatefulWidget {
  const AnalyzerScreen({super.key});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _sourceLinkController = TextEditingController();
  final TextEditingController _youtubeLinkController = TextEditingController();

  final JapaneseService _japaneseService = JapaneseService();
  final StorageService _storage = StorageService();

  List<List<WordToken>> _lines = [];
  String? _translation;
  bool _isAnalyzing = false;
  bool _isTranslating = false;
  bool _isInitializing = true;
  bool _isSaving = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() => setState(() {}));
    _initMecab();
  }

  Future<void> _initMecab() async {
    try {
      await _japaneseService.init();
      setState(() => _isInitializing = false);
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _initError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _titleController.dispose();
    _artistController.dispose();
    _sourceLinkController.dispose();
    _youtubeLinkController.dispose();
    super.dispose();
  }

  // ПРЕМАХНАТ _preprocessText - вече не е нужен!

  Future<void> _analyze() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      setState(() => _lines = []);
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      // Подаваме ОРИГИНАЛНИЯ текст - japanese_service ще се справи с {{...}}
      final lines = await _japaneseService.tokenize(text);

      setState(() {
        _lines = lines;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() => _isAnalyzing = false);
      _showError('Грешка: $e');
    }
  }

  Future<void> _translate() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      // japanese_service ще премахне {{...}} при превод
      final translation = await _japaneseService.translateToBulgarian(text);
      setState(() {
        _translation = translation;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() => _isTranslating = false);
      _showError('Грешка: $e');
    }
  }

  void _clear() {
    _inputController.clear();
    setState(() {
      _lines = [];
      _translation = null;
    });
  }

  void _toggleToken(int lineIndex, int tokenIndex) {
    setState(() {
      final token = _lines[lineIndex][tokenIndex];
      _lines[lineIndex][tokenIndex] = token.copyWith(
        isSelected: !token.isSelected,
      );
    });
  }

  Future<void> _saveSong() async {
    if (_titleController.text.trim().isEmpty) {
      _showError('Моля, въведи заглавие на песента');
      return;
    }
    if (_artistController.text.trim().isEmpty) {
      _showError('Моля, въведи изпълнител');
      return;
    }
    if (_lines.isEmpty) {
      _showError('Моля, първо анализирай текста');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final song = SongModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        sourceLink: _sourceLinkController.text.trim(),
        youtubeLink: _youtubeLinkController.text.trim(),
        translation: _translation ?? '',
        lines: _lines,
      );

      final allSongs = await _storage.loadSongs();
      allSongs.add(song);
      await _storage.saveSongs(allSongs);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _showError('Грешка при запазване: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isInitializing
            ? _buildLoading()
            : _initError != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            AppTexts.initializingMecab,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 20),
            const Text(
              'Грешка при инициализация на MeCab',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _initError ?? '',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isInitializing = true;
                  _initError = null;
                });
                _initMecab();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Опитай пак'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverPadding(
          padding: const EdgeInsets.all(AppConfig.screenPadding),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildMetadataSection(),
              const SizedBox(height: AppConfig.sectionSpacing),
              InputSection(
                controller: _inputController,
                onAnalyze: _analyze,
                onTranslate: _translate,
                onClear: _clear,
                isLoading: _isAnalyzing,
              ),
              const SizedBox(height: AppConfig.sectionSpacing),
              ResultSection(
                lines: _lines,
                onTokenTap: _toggleToken,
                translation: _translation,
                isTranslating: _isTranslating,
              ),
              const SizedBox(height: 24),
              _buildSaveButton(),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, const Color(0xFF7E57C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '日',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppTexts.analyzeNew,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      _japaneseService.isInitialized
                          ? Icons.check_circle
                          : Icons.hourglass_empty,
                      size: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _japaneseService.isInitialized
                          ? 'MeCab готов'
                          : 'MeCab зарежда...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Информация за песента',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: AppTexts.songTitle,
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _artistController,
                  decoration: InputDecoration(
                    labelText: AppTexts.artist,
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _youtubeLinkController,
                  decoration: InputDecoration(
                    labelText: AppTexts.youtubeUrl,
                    prefixIcon: const Icon(
                      Icons.play_circle_filled,
                      color: Colors.red,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'https://youtube.com/...',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _sourceLinkController,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: '${AppTexts.sourceUrl} (по един на ред)',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.link),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'https://...\nhttps://...',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Съвет: Използвай {{текст}} за да запазиш но игнорираш части като [Verse 1]',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textHint,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveSong,
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
        label: Text(_isSaving ? 'Запазване...' : AppTexts.saveButton),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
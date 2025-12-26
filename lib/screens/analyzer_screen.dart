import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../config/app_colors.dart';
import '../config/app_texts.dart';
import '../models/word_token.dart';
import '../services/japanese_service.dart';
import '../widgets/input_section.dart';
import '../widgets/result_section.dart';

class AnalyzerScreen extends StatefulWidget {
  const AnalyzerScreen({super.key});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> {
  final TextEditingController _inputController = TextEditingController();
  final JapaneseService _japaneseService = JapaneseService();
  
  List<List<WordToken>> _lines = [];
  String? _translation;
  bool _isAnalyzing = false;
  bool _isTranslating = false;
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _inputController.text = AppConfig.initialText;
    _inputController.addListener(() => setState(() {}));
    _initMecab();
  }

  Future<void> _initMecab() async {
    try {
      await _japaneseService.init();
      setState(() => _isInitializing = false);
      _analyze();
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
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      setState(() => _lines = []);
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
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
      _lines[lineIndex][tokenIndex] = token.copyWith(isSelected: !token.isSelected);
    });
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
          Text(AppTexts.initializingMecab, style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
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
            const Text('Грешка при инициализация на MeCab', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(_initError ?? '', 
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
              InputSection(
                controller: _inputController,
                onAnalyze: _analyze,
                onTranslate: _translate,
                onClear: _clear,
                isLoading: _isAnalyzing,
              ),
              const SizedBox(height: AppConfig.sectionSpacing),
              // Без LegendWidget!
              ResultSection(
                lines: _lines,
                onTokenTap: _toggleToken,
                translation: _translation,
                isTranslating: _isTranslating,
              ),
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
            child: const Text('日', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(AppTexts.appTitle, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              Row(
                children: [
                  Icon(
                    _japaneseService.isInitialized ? Icons.check_circle : Icons.hourglass_empty,
                    size: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _japaneseService.isInitialized ? 'MeCab готов' : 'MeCab зарежда...',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
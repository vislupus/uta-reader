import 'dart:io';

import 'package:flutter/services.dart';
import 'package:jm_dict/jm_dict.dart';
import 'package:mecab_for_flutter/mecab_for_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:translator/translator.dart';

import '../models/word_token.dart';

class JapaneseService {
  static final JapaneseService _instance = JapaneseService._internal();
  factory JapaneseService() => _instance;
  JapaneseService._internal();

  final GoogleTranslator _translator = GoogleTranslator();
  final Map<String, String> _glossCache = {};
  final Map<String, List<String>> _dictCache = {};

  Mecab? _mecab;
  final JMDict _jmdict = JMDict();
  bool _initialized = false;
  bool _dictInitialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      final dictPath = await _prepareMecabDictFromAssets(
        assetDir: 'assets/ipadic',
        dictName: 'ipadic',
      );

      _mecab = Mecab();
      await _mecab!.initFlutter(dictPath, true);

      _initialized = true;
      print('✅ MeCab initialized OK');

      try {
        if (_jmdict.isNotEmpty) {
          _dictInitialized = true;
          print('✅ JMDict already loaded');
        } else {
          print(
            '📥 Downloading JMDict (this may take a while on first run)...',
          );
          await _jmdict.initFromNetwork(forceUpdate: false);
          _dictInitialized = true;
          print('✅ JMDict initialized OK');
        }
      } catch (e) {
        print('⚠️ JMDict init error: $e');
        _dictInitialized = false;
      }
    } catch (e) {
      _initialized = false;
      print('❌ MeCab init error: $e');
      rethrow;
    }
  }

  bool get isInitialized => _initialized;

  Future<List<List<WordToken>>> tokenize(String text) async {
    if (text.isEmpty) return [];

    if (!_initialized) {
      await init();
    }

    final lines = text.split('\n');
    final result = <List<WordToken>>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        result.add([]);
      } else {
        // Използваме нов метод който обработва {{ }} правилно
        final tokens = _tokenizeLineWithIgnored(line);
        result.add(tokens);
      }
    }

    await _enrichTokens(result);

    return result;
  }

  /// Токенизира ред като запазва текста в {{...}} като отделни ignored токени
  List<WordToken> _tokenizeLineWithIgnored(String line) {
    final tokens = <WordToken>[];
    final regex = RegExp(r'\{\{([^}]*)\}\}');

    int lastEnd = 0;

    for (final match in regex.allMatches(line)) {
      // Текст ПРЕДИ този мач - токенизирай нормално с MeCab
      if (match.start > lastEnd) {
        final normalText = line.substring(lastEnd, match.start);
        if (normalText.trim().isNotEmpty) {
          tokens.addAll(_tokenizeLine(normalText));
        }
      }

      // Съдържанието между {{ }} - създай един ignored токен с оригиналния текст
      final ignoredContent = match.group(1)?.trim() ?? '';
      if (ignoredContent.isNotEmpty) {
        tokens.add(
          WordToken(
            surface: ignoredContent, // Показва: [Verse 1]
            pos: 'ignored',
            baseForm: ignoredContent,
          ),
        );
      }

      lastEnd = match.end;
    }

    // Текст СЛЕД последния мач
    if (lastEnd < line.length) {
      final remainingText = line.substring(lastEnd);
      if (remainingText.trim().isNotEmpty) {
        tokens.addAll(_tokenizeLine(remainingText));
      }
    }

    // Ако няма никакви {{...}} маркери, токенизирай целия ред нормално
    if (tokens.isEmpty && line.trim().isNotEmpty) {
      tokens.addAll(_tokenizeLine(line));
    }

    return tokens;
  }

  Future<String> translateToBulgarian(String text) async {
    if (text.isEmpty) return '';

    try {
      // Премахваме {{ }} маркерите за превода
      final cleanText = text.replaceAll(RegExp(r'\{\{[^}]*\}\}'), '');
      final result = await _translator.translate(
        cleanText,
        from: 'ja',
        to: 'bg',
      );
      return result.text;
    } catch (e) {
      return 'Грешка при превод: $e';
    }
  }

  Future<String> _prepareMecabDictFromAssets({
    required String assetDir,
    required String dictName,
  }) async {
    final baseDir = await getApplicationSupportDirectory();
    final outDir = Directory(p.join(baseDir.path, 'mecab', dictName));

    if (await outDir.exists()) {
      final ok = _checkDictFiles(outDir.path);
      if (ok) return outDir.path;

      try {
        await outDir.delete(recursive: true);
      } catch (_) {}
      await outDir.create(recursive: true);
    } else {
      await outDir.create(recursive: true);
    }

    const files = [
      'sys.dic',
      'unk.dic',
      'matrix.bin',
      'char.bin',
      'dicrc',
      'mecabrc',
      'left-id.def',
      'right-id.def',
      'pos-id.def',
      'rewrite.def',
    ];

    for (final f in files) {
      try {
        final data = await rootBundle.load('$assetDir/$f');
        final outFile = File(p.join(outDir.path, f));
        await outFile.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          flush: true,
        );
      } catch (e) {
        print('⚠️ Could not copy $f -> $e');
      }
    }

    return outDir.path;
  }

  bool _checkDictFiles(String dirPath) {
    final needed = ['sys.dic', 'unk.dic', 'matrix.bin', 'char.bin', 'dicrc'];
    for (final f in needed) {
      if (!File(p.join(dirPath, f)).existsSync()) return false;
    }
    return true;
  }

  List<WordToken> _tokenizeLine(String line) {
    final tokens = <WordToken>[];

    if (_mecab == null) {
      for (final char in line.split('')) {
        tokens.add(WordToken(surface: char, pos: 'other'));
      }
      return tokens;
    }

    try {
      final nodes = _mecab!.parse(line);

      for (final node in nodes) {
        if (node.surface.isEmpty) continue;
        if (node.surface == 'EOS' || node.surface == 'BOS') continue;
        if (node.features.isNotEmpty &&
            (node.features[0] == 'BOS/EOS' ||
                node.features[0] == 'BOS' ||
                node.features[0] == 'EOS')) {
          continue;
        }

        tokens.add(_parseNode(node));
      }
    } catch (e) {
      print('Parse error: $e');
      for (final char in line.split('')) {
        tokens.add(WordToken(surface: char, pos: 'other'));
      }
    }

    return tokens;
  }

  WordToken _parseNode(TokenNode node) {
    final surface = node.surface;
    final features = node.features;

    String posJapanese = _getFeature(features, 0);
    String posDetail1 = _getFeature(features, 1);
    String posDetail2 = _getFeature(features, 2);
    String conjugationType = _getFeature(features, 4);
    String conjugationForm = _getFeature(features, 5);
    String baseForm = _getFeature(features, 6);
    String reading = _getFeature(features, 7);

    if (baseForm.isEmpty || baseForm == '*') {
      baseForm = surface;
    }

    String furigana = '';
    if (_hasKanji(surface) && reading.isNotEmpty) {
      furigana = _katakanaToHiragana(reading);
      if (furigana == surface) furigana = '';
    }

    String pos = _mapPos(posJapanese);

    return WordToken(
      surface: surface,
      reading: reading,
      furigana: furigana,
      baseForm: baseForm,
      pos: pos,
      posDetail1: posDetail1,
      posDetail2: posDetail2,
      posJapanese: posJapanese,
      conjugationType: conjugationType,
      conjugationForm: conjugationForm,
    );
  }

  bool _hasKanji(String text) {
    for (int i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      if ((code >= 0x4e00 && code <= 0x9fff) ||
          (code >= 0x3400 && code <= 0x4dbf) ||
          (code >= 0xf900 && code <= 0xfaff)) {
        return true;
      }
    }
    return false;
  }

  String _getFeature(List<String> features, int index) {
    if (index < features.length) {
      final value = features[index];
      return value == '*' ? '' : value;
    }
    return '';
  }

  String _mapPos(String posJapanese) {
    switch (posJapanese) {
      case '名詞':
        return 'noun';
      case '動詞':
        return 'verb';
      case '形容詞':
        return 'adjective';
      case '形容動詞':
        return 'adjective';
      case '副詞':
        return 'adverb';
      case '連体詞':
        return 'adnominal';
      case '接続詞':
        return 'conjunction';
      case '感動詞':
        return 'interjection';
      case '助詞':
        return 'particle';
      case '助動詞':
        return 'auxiliary';
      case '接頭詞':
        return 'prefix';
      case '接尾詞':
        return 'suffix';
      case '記号':
        return 'symbol';
      case 'フィラー':
        return 'filler';
      default:
        return 'other';
    }
  }

  String _katakanaToHiragana(String text) {
    if (text.isEmpty) return '';
    final buffer = StringBuffer();
    for (final code in text.runes) {
      if (code >= 0x30A1 && code <= 0x30F6) {
        buffer.writeCharCode(code - 0x60);
      } else {
        buffer.writeCharCode(code);
      }
    }
    return buffer.toString();
  }

  Future<void> _enrichTokens(List<List<WordToken>> lines) async {
    final wordsToProcess = <String>{};

    for (final line in lines) {
      for (final token in line) {
        if (token.isMeaningful) {
          final word = token.baseForm.isNotEmpty
              ? token.baseForm
              : token.surface;
          if (word.isNotEmpty) {
            wordsToProcess.add(word);
          }
        }
      }
    }

    for (final word in wordsToProcess) {
      if (!_dictCache.containsKey(word)) {
        _dictCache[word] = _lookupDictionary(word);
      }

      if (!_glossCache.containsKey(word)) {
        try {
          final result = await _translator.translate(
            word,
            from: 'ja',
            to: 'en',
          );
          _glossCache[word] = result.text;
        } catch (_) {
          final dictMeanings = _dictCache[word] ?? [];
          _glossCache[word] = dictMeanings.isNotEmpty ? dictMeanings.first : '';
        }
      }
    }

    for (final line in lines) {
      for (int i = 0; i < line.length; i++) {
        final token = line[i];
        if (token.isMeaningful) {
          final word = token.baseForm.isNotEmpty
              ? token.baseForm
              : token.surface;
          line[i] = token.copyWith(
            gloss: _glossCache[word],
            meanings: _dictCache[word] ?? [],
          );
        }
      }
    }
  }

  List<String> _lookupDictionary(String word) {
    if (!_dictInitialized) return [];

    try {
      final results = _jmdict.search(keyword: word, limit: 5);

      if (results == null || results.isEmpty) return [];

      final meanings = <String>[];

      for (final entry in results) {
        for (final sense in entry.senseElements) {
          for (final glossary in sense.glossaries) {
            if (meanings.length < 3 && !meanings.contains(glossary.text)) {
              meanings.add(glossary.text);
            }
            if (meanings.length >= 3) break;
          }
          if (meanings.length >= 3) break;
        }
        if (meanings.length >= 3) break;
      }

      return meanings;
    } catch (e) {
      print('Dictionary lookup error for "$word": $e');
      return [];
    }
  }
}

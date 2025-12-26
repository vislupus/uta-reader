class AppTexts {
  static const String appTitle = 'Japanese Text Analyzer';
  static const String appSubtitle = 'MeCab Morphological Analyzer';
  static const String inputLabel = 'Въведи японски текст';
  static const String inputHint = 'Напиши или постави японски текст...';
  static const String analyzeButton = 'Анализирай';
  static const String translateButton = 'Преведи';
  static const String translationTitle = 'Превод на български';
  static const String resultTitle = 'Морфологичен анализ';
  static const String legendTitle = 'Легенда';
  static const String loading = 'Зареждане...';
  static const String translating = 'Превеждане...';
  static const String noText = 'Няма въведен текст';
  static const String initializingMecab = 'Инициализиране на MeCab...';

  static const Map<String, String> posLabels = {
    'noun': 'съществително',
    'verb': 'глагол',
    'adjective': 'прилагателно',
    'adverb': 'наречие',
    'particle': 'частица',
    'auxiliary': 'спомагателен',
    'conjunction': 'съюз',
    'interjection': 'междуметие',
    'prefix': 'префикс',
    'suffix': 'суфикс',
    'adnominal': 'определение',
    'symbol': 'символ',
    'other': 'друго',
  };
  
  static const Map<String, String> posLabelsJa = {
    'noun': '名詞',
    'verb': '動詞',
    'adjective': '形容詞',
    'adverb': '副詞',
    'particle': '助詞',
    'auxiliary': '助動詞',
    'conjunction': '接続詞',
    'interjection': '感動詞',
    'prefix': '接頭詞',
    'suffix': '接尾詞',
    'adnominal': '連体詞',
    'symbol': '記号',
    'other': 'その他',
  };
}
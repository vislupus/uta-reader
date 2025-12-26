class AppTexts {
  static const String appTitle = 'Japanese Song Learner';
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
  static const String songsListTitle = 'Моите песни';
  static const String addSong = 'Добави нова песен';
  static const String songTitle = 'Заглавие';
  static const String artist = 'Изпълнител';
  static const String sourceUrl = 'Линк към източник';
  static const String youtubeUrl = 'YouTube линк';
  static const String saveButton = 'Запази песента';
  static const String deleteButton = 'Изтрий';
  static const String progressLabel = 'Прогрес: ';
  static const String noSongs = 'Все още нямате добавени песни.';
  static const String analyzeNew = 'Нова песен';

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
import 'word_token.dart';

class SongModel {
  final String id;
  final String title;
  final String artist;
  final String sourceLink;  
  final String youtubeLink;
  String translation;  
  final List<List<WordToken>> lines;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.sourceLink = '',
    this.youtubeLink = '',
    this.translation = '',
    required this.lines,
  });

  /// Връща списък с линкове към източниците
  List<String> get sourceLinks {
    if (sourceLink.isEmpty) return [];
    return sourceLink
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  int get totalWords {
    int count = 0;
    for (final line in lines) {
      count += line.where((t) => !t.isSymbol && !t.isIgnored).length;
    }
    return count;
  }

  int get selectedWords {
    int count = 0;
    for (final line in lines) {
      count += line.where((t) => t.isSelected).length;
    }
    return count;
  }

  double get progress {
    final meaningful = lines.expand((l) => l).where((t) => t.isMeaningful).length;
    if (meaningful == 0) return 0;
    return selectedWords / meaningful;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'sourceLink': sourceLink,
    'youtubeLink': youtubeLink,
    // translation НЕ се записва!
    'lines': lines.map((line) => line.map((t) => t.toJson()).toList()).toList(),
  };

  factory SongModel.fromJson(Map<String, dynamic> json) => SongModel(
    id: json['id'],
    title: json['title'],
    artist: json['artist'],
    sourceLink: json['sourceLink'] ?? '',
    youtubeLink: json['youtubeLink'] ?? '',
    translation: '',  // Винаги празен при зареждане
    lines: (json['lines'] as List)
        .map((line) => (line as List).map((t) => WordToken.fromJson(t)).toList())
        .toList(),
  );
}
class WordToken {
  final String surface;
  final String reading;
  final String furigana;
  final String baseForm;
  final String pos;
  final String posDetail1;
  final String posDetail2;
  final String posJapanese;
  final String conjugationType;
  final String conjugationForm;
  String? gloss;
  final List<String> meanings;  // От JMDict
  bool isSelected;

  WordToken({
    required this.surface,
    this.reading = '',
    this.furigana = '',
    this.baseForm = '',
    this.pos = 'other',
    this.posDetail1 = '',
    this.posDetail2 = '',
    this.posJapanese = '',
    this.conjugationType = '',
    this.conjugationForm = '',
    this.gloss,
    this.meanings = const [],
    this.isSelected = false,
  });

  bool get hasKanji {
    for (int i = 0; i < surface.length; i++) {
      final code = surface.codeUnitAt(i);
      if ((code >= 0x4e00 && code <= 0x9fff) ||
          (code >= 0x3400 && code <= 0x4dbf) ||
          (code >= 0xf900 && code <= 0xfaff)) {
        return true;
      }
    }
    return false;
  }

  bool get showFurigana => hasKanji && furigana.isNotEmpty && furigana != surface;
  
  bool get showGloss {
    final validPos = ['noun', 'verb', 'adjective', 'adverb'].contains(pos);
    return validPos && gloss != null && gloss!.isNotEmpty && gloss != surface;
  }
  
  bool get isSymbol => pos == 'symbol';
  
  /// Значеща дума - може да се селектира
  bool get isMeaningful => ['noun', 'verb', 'adjective', 'adverb'].contains(pos);

  WordToken copyWith({bool? isSelected, String? gloss, List<String>? meanings}) {
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
      gloss: gloss ?? this.gloss,
      meanings: meanings ?? this.meanings,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
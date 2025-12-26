import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF5C6BC0);
  static const Color secondary = Color(0xFFFF7043);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF1F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardSelected = Color(0xFFE8EAF6);
  static const Color cardHover = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color furigana = Color(0xFF5C6BC0);
  static const Color gloss = Color(0xFF616161);
  static const Color border = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFE53935);

  static const Map<String, Color> posColors = {
    'noun': Color(0xFF42A5F5),
    'verb': Color(0xFF66BB6A),
    'adjective': Color(0xFFFFCA28),
    'adverb': Color(0xFF26A69A),
    'particle': Color(0xFF78909C),
    'auxiliary': Color(0xFFAB47BC),
    'conjunction': Color(0xFFEC407A),
    'interjection': Color(0xFFEF5350),
    'prefix': Color(0xFF8D6E63),
    'suffix': Color(0xFF5D4037),
    'adnominal': Color(0xFF7E57C2),
    'symbol': Color(0xFF90A4AE),
    'other': Color(0xFF9E9E9E),
  };
  
  static Color getPosColor(String pos) {
    return posColors[pos.toLowerCase()] ?? posColors['other']!;
  }
}
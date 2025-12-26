import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../config/app_colors.dart';
import '../config/app_texts.dart';
import '../models/word_token.dart';

class WordCard extends StatefulWidget {
  final WordToken token;
  final VoidCallback? onTap;

  const WordCard({super.key, required this.token, this.onTap});

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  bool _isHovered = false;

  static const double _furiganaHeight = 16.0;
  static const double _glossHeight = 18.0;

  @override
  Widget build(BuildContext context) {
    // Игнорирани текстове - ПО-ТЪМЕН текст, същия фон
    if (widget.token.isIgnored) {
      return Padding(
        padding: const EdgeInsets.only(top: _furiganaHeight + 6),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.textHint.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            widget.token.surface,
            style: TextStyle(
              fontSize: 16,  // По-голям размер
              fontWeight: FontWeight.w600,  // По-дебел
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,  // По-тъмен цвят
            ),
          ),
        ),
      );
    }

    // Символи - просто Text
    if (widget.token.isSymbol) {
      return Padding(
        padding: const EdgeInsets.only(top: _furiganaHeight + 6),
        child: Text(
          widget.token.surface,
          style: TextStyle(
            fontSize: AppConfig.fontSurface,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      );
    }

    // Незначещи думи
    if (!widget.token.isMeaningful) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: _furiganaHeight),
              Text(
                widget.token.surface,
                style: TextStyle(
                  fontSize: AppConfig.fontSurface,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                height: AppConfig.posIndicatorHeight,
                constraints: const BoxConstraints(minWidth: 20),
                decoration: BoxDecoration(
                  color: AppColors.getPosColor(widget.token.pos).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(height: _glossHeight),
            ],
          ),
        ),
      );
    }

    // Значещи думи - с карта, hover и селекция
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Tooltip(
          richMessage: _buildTooltip(),
          waitDuration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: AppConfig.animationMs),
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.token.isSelected
                  ? AppColors.cardSelected
                  : _isHovered
                      ? AppColors.cardHover
                      : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
              border: Border.all(
                color: widget.token.isSelected
                    ? AppColors.getPosColor(widget.token.pos)
                    : _isHovered
                        ? AppColors.getPosColor(widget.token.pos).withOpacity(0.5)
                        : AppColors.border,
                width: widget.token.isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? AppColors.getPosColor(widget.token.pos).withOpacity(0.15)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: _isHovered ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: _furiganaHeight,
                    child: widget.token.showFurigana
                        ? Text(
                            widget.token.furigana,
                            style: TextStyle(
                              fontSize: AppConfig.fontFurigana,
                              color: AppColors.furigana,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : null,
                  ),
                  Text(
                    widget.token.surface,
                    style: TextStyle(
                      fontSize: AppConfig.fontSurface,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    height: AppConfig.posIndicatorHeight,
                    constraints: const BoxConstraints(minWidth: 20),
                    decoration: BoxDecoration(
                      color: AppColors.getPosColor(widget.token.pos),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: _glossHeight,
                    child: widget.token.showGloss
                        ? Text(
                            widget.token.gloss!,
                            style: TextStyle(
                              fontSize: AppConfig.fontGloss,
                              color: AppColors.gloss,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextSpan _buildTooltip() {
    final token = widget.token;
    final posLabel = AppTexts.posLabels[token.pos] ?? token.pos;

    return TextSpan(
      children: [
        TextSpan(
          text: token.surface,
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        if (token.reading.isNotEmpty)
          TextSpan(
            text:
                '  (${token.furigana.isNotEmpty ? token.furigana : token.reading})',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
          ),
        if (token.baseForm.isNotEmpty && token.baseForm != token.surface) ...[
          const TextSpan(text: '\n'),
          TextSpan(
            text: 'Основна форма: ${token.baseForm}',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
          ),
        ],
        const TextSpan(text: '\n\n'),
        TextSpan(
          text: posLabel,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getPosColor(token.pos),
            fontWeight: FontWeight.bold,
          ),
        ),
        if (token.meanings.isNotEmpty) ...[
          const TextSpan(text: '\n\n'),
          const TextSpan(
            text: 'Значения:\n',
            style: TextStyle(
                fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          for (int i = 0; i < token.meanings.length; i++)
            TextSpan(
              text:
                  '${i + 1}. ${token.meanings[i]}${i < token.meanings.length - 1 ? '\n' : ''}',
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
        ],
        if (token.meanings.isEmpty &&
            token.gloss != null &&
            token.gloss!.isNotEmpty) ...[
          const TextSpan(text: '\n\n'),
          TextSpan(
            text: token.gloss!,
            style: const TextStyle(
                fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }
}
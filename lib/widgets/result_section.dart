import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_texts.dart';
import '../models/word_token.dart';
import 'word_card.dart';

class ResultSection extends StatelessWidget {
  final List<List<WordToken>> lines;
  final Function(int, int) onTokenTap;
  final String? translation;
  final bool isTranslating;

  const ResultSection({
    super.key,
    required this.lines,
    required this.onTokenTap,
    this.translation,
    this.isTranslating = false,
  });

  /// Брой значещи думи (съществителни, глаголи, прилагателни, наречия)
  int get meaningfulWords {
    int count = 0;
    for (final line in lines) {
      count += line.where((t) => t.isMeaningful).length;
    }
    return count;
  }

  /// Общ брой думи (без символи)
  int get totalWords {
    int count = 0;
    for (final line in lines) {
      count += line.where((t) => !t.isSymbol).length;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (translation != null || isTranslating) _buildTranslation(context),
        _buildHeader(context),
        const SizedBox(height: 16),
        lines.isEmpty || lines.every((line) => line.isEmpty)
            ? _buildEmpty(context)
            : _buildTokens(context),
      ],
    );
  }

  Widget _buildTranslation(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppTexts.translationTitle,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isTranslating)
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  AppTexts.translating,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            )
          else
            SelectableText(
              translation ?? '',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          AppTexts.resultTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        // Показва: значещи / всички думи
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$meaningfulWords',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
              Text(
                ' / $totalWords думи',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.text_fields, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            AppTexts.noText,
            style: TextStyle(color: AppColors.textHint, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTokens(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          for (int lineIndex = 0; lineIndex < lines.length; lineIndex++)
            if (lines[lineIndex].isEmpty)
              const SizedBox(height: 24)
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Wrap(
                  spacing: 0,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    for (
                      int tokenIndex = 0;
                      tokenIndex < lines[lineIndex].length;
                      tokenIndex++
                    )
                      WordCard(
                        token: lines[lineIndex][tokenIndex],
                        // Само значещите думи могат да се кликат
                        onTap: lines[lineIndex][tokenIndex].isMeaningful
                            ? () => onTokenTap(lineIndex, tokenIndex)
                            : null,
                      ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

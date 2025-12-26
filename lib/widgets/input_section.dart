import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_texts.dart';

class InputSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAnalyze;
  final VoidCallback onTranslate;
  final VoidCallback onClear;
  final bool isLoading;

  const InputSection({
    super.key,
    required this.controller,
    required this.onAnalyze,
    required this.onTranslate,
    required this.onClear,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_note, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTexts.inputLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(AppTexts.inputHint, style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            minLines: 1,  // Започва с 1 ред
            maxLines: 5,  // Нараства до 5 реда максимум
            style: const TextStyle(fontSize: 20, height: 1.5),
            decoration: InputDecoration(
              hintText: '日本語のテキストを入力...',
              hintStyle: TextStyle(color: AppColors.textHint),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onAnalyze,
                  icon: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.analytics_outlined),
                  label: Text(isLoading ? AppTexts.loading : AppTexts.analyzeButton),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onTranslate,
                  icon: const Icon(Icons.translate),
                  label: const Text(AppTexts.translateButton),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
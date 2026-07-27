import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';


class PdfExportResultSheet extends StatelessWidget {
  final String filePath;

  const PdfExportResultSheet({super.key, required this.filePath});

  String get _fileName => filePath.split('/').last;

  Future<void> _share(BuildContext context) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        text: 'Relatório Financeiro',
        subject: 'Relatório Financeiro',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 38,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              tr('analytics.pdf_success_title'),
              textAlign: TextAlign.center,
              style: AppTextStyles.headingMedium.copyWith(fontSize: 19),
            ),

            const SizedBox(height: 8),

            Text(
              tr('analytics.pdf_success_subtitle'),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () => _share(context),
              icon: const Icon(Icons.ios_share_rounded),
              label: Text(tr('analytics.share')),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('common.close')),
            ),
          ],
        ),
      ),
    );
  }
}

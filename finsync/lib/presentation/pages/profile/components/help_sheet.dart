import 'dart:io';

import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSheet extends StatelessWidget {
  const HelpSheet({super.key});

  static const _supportEmail = 'diogodemouramarques2004@gmail.com';

  /// Só os sufixos das chaves: o texto vive no ficheiro de traduções.
  /// Guardar aqui as perguntas em texto fixo era o que fazia esta folha
  /// aparecer sempre em português, mesmo com a app em inglês.
  static const _faqKeys = <String>[
    'currency',
    'theme',
    'language',
    'notifications',
    'desire',
    'events',
    'statement',
    'password',
  ];

  Future<void> _contactSupport(BuildContext context) async {
    // O corpo já vai com o sistema e a versão preenchidos. Sem isso, o
    // primeiro email de resposta é sempre a perguntar em que telemóvel é
    // que o problema aconteceu.
    final body = tr('help.email_body', {
      'platform': _platformName(),
      'version': _appVersion,
    });

    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query:
          'subject=${Uri.encodeComponent(tr('help.email_subject'))}'
          '&body=${Uri.encodeComponent(body)}',
    );

    var launched = false;
    try {
      launched = await launchUrl(uri);
    } catch (_) {
      // Sem app de email configurada, o sistema devolve erro em vez de
      // false. O tratamento é o mesmo.
      launched = false;
    }

    if (launched || !context.mounted) return;

    // Sem forma de abrir o email, ao menos que o endereço fique na área de
    // transferência — dizer "escreve-nos para X" e obrigar a copiar à mão
    // de um snackbar que desaparece não serve de nada.
    await Clipboard.setData(const ClipboardData(text: _supportEmail));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('help.email_copied', {'email': _supportEmail})),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  static const _appVersion = '1.0.0';

  String _platformName() {
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    return Platform.operatingSystem;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.disabled,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(tr('help.title'), style: AppTextStyles.headingMedium),

                const SizedBox(height: 6),

                Text(
                  tr('help.subtitle'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      for (final key in _faqKeys)
                        // `Material` e não `Container`: o `ExpansionTile`
                        // constrói um `ListTile` por dentro, e este pinta o
                        // fundo e a onda do toque no Material mais próximo
                        // acima dele. Um Container colorido pelo meio
                        // esconde esse efeito — é o aviso "ink splashes may
                        // be invisible". O `clipBehavior` recorta a onda aos
                        // cantos arredondados do cartão.
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: AppColors.background,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: AppColors.border),
                            ),
                            child: Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                childrenPadding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                iconColor: AppColors.secondary,
                                collapsedIconColor: AppColors.textSecondary,
                                title: Text(
                                  tr('help.faq_${key}_q'),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      tr('help.faq_${key}_a'),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      OutlinedButton.icon(
                        onPressed: () => _contactSupport(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          side: BorderSide(color: AppColors.secondary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: Icon(
                          Icons.mail_outline_rounded,
                          color: AppColors.secondary,
                        ),
                        label: Text(
                          tr('help.contact_support'),
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSheet extends StatelessWidget {
  const HelpSheet({super.key});

  // Endereço de suporte provisório — tem de ser substituído pelo endereço
  // real antes de publicar a app, senão os pedidos de ajuda não chegam a
  // lado nenhum.
  static const _supportEmail = 'suporte@finsync.app';

  static const _faqs = <(String, String)>[
    (
      "Como mudo a moeda usada na app?",
      "Vai a Perfil > Moeda e escolhe entre EUR, USD, GBP ou BRL. Todos os "
          "valores da app passam a mostrar-se nessa moeda.",
    ),
    (
      "Como mudo entre modo claro e escuro?",
      "Vai a Perfil > Tema e escolhe Claro, Escuro ou Automático (segue o "
          "tema do sistema).",
    ),
    (
      "As notificações enviam avisos reais?",
      "Por agora não — as preferências em Perfil > Notificações ficam "
          "guardadas apenas no dispositivo. O envio de notificações push "
          "chega numa atualização futura.",
    ),
    (
      "Como funciona o dinheiro guardado num desejo?",
      "Ao criares ou editares um desejo podes indicar quanto já guardaste "
          "para esse objetivo. Esse valor é descontado automaticamente do "
          "teu saldo.",
    ),
    (
      "Como troco a password da minha conta?",
      "Vai a Perfil > Segurança, introduz a password atual e a nova "
          "password para confirmar a alteração.",
    ),
  ];

  Future<void> _contactSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: 'subject=Suporte FinSync',
    );

    final launched = await launchUrl(uri);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível abrir o email. Contacta-nos em $_supportEmail.',
          ),
        ),
      );
    }
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

                Text("Ajuda", style: AppTextStyles.headingMedium),

                const SizedBox(height: 6),

                Text(
                  "Perguntas frequentes e formas de contacto.",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      for (final (question, answer) in _faqs)
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
                                  question,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      answer,
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
                          "Contactar suporte",
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

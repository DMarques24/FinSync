import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:flutter/material.dart';

/// A marca da app.
///
/// Existe num só sítio porque aparecia em quatro ecrãs — arranque, login,
/// registo e barra de topo — e cada um tinha o seu quadrado com o ícone de
/// carteira do Material, ligeiramente diferente dos outros.
class AppLogo extends StatelessWidget {
  final double size;

  /// Cantos arredondados proporcionais ao tamanho, como nos ícones do
  /// sistema. Fixá-los faria um logo de 30px parecer um quadrado e um de
  /// 96px parecer um círculo.
  const AppLogo({super.key, this.size = 88});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.all(size * 0.2237),
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        // Se o ficheiro faltar, a app não pode ficar com um ecrã partido
        // no arranque. Volta ao ícone que estava aqui antes.
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          color: AppColors.secondary.withValues(alpha: .10),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            size: size * 0.5,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }
}

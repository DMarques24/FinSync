import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:flutter/material.dart';

/// Bloco cinzento com brilho a passar, usado para imitar o conteúdo
/// enquanto ele carrega.
///
/// É preferível a um círculo de progresso porque mostra desde logo a
/// forma do que vai aparecer: o ecrã não "salta" quando os dados chegam e
/// a espera parece mais curta.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = AppRadius.xs,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    // Sem isto o controlador continuaria a animar depois do widget sair
    // do ecrã, gastando bateria à toa.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = AppColors.isDark
        ? Colors.white.withValues(alpha: .06)
        : Colors.black.withValues(alpha: .05);
    final highlight = AppColors.isDark
        ? Colors.white.withValues(alpha: .12)
        : Colors.black.withValues(alpha: .02);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              // O gradiente desliza da esquerda para a direita ao longo
              // do ciclo, criando o efeito de brilho.
              begin: Alignment(-1 - 2 * _controller.value, 0),
              end: Alignment(1 - 2 * _controller.value, 0),
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
            ),
          ),
        );
      },
    );
  }
}

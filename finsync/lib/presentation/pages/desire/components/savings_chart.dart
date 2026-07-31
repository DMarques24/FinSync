import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/desire_saving.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Total acumulado ao longo do tempo, com a meta como linha de referência.
///
/// Acumulado e não valor por depósito: a pergunta que a pessoa faz ao olhar
/// para aqui é "quanto é que já tenho e quando é que lá chego", e barras
/// soltas de 20 e 50 euros não respondem a isso.
class SavingsChart extends StatelessWidget {
  final List<DesireSaving> savings;
  final double goal;

  const SavingsChart({super.key, required this.savings, required this.goal});

  @override
  Widget build(BuildContext context) {
    final points = _cumulativePoints();

    // Os pontos do gráfico já estão convertidos para a moeda selecionada,
    // por isso a meta tem de estar na mesma escala — senão a linha de
    // referência aparecia no sítio errado em qualquer moeda que não o euro.
    final goalInDisplayCurrency = AppCurrency.convert(goal);

    return SizedBox(
      height: 220,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        margin: EdgeInsets.zero,
        primaryXAxis: DateTimeAxis(
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: AxisLine(color: AppColors.border),
          labelStyle: AppTextStyles.bodySmall.copyWith(fontSize: 11),
          intervalType: DateTimeIntervalType.auto,
        ),
        primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          majorGridLines: MajorGridLines(
            width: 1,
            color: AppColors.border,
            dashArray: const [4, 4],
          ),
          labelStyle: AppTextStyles.bodySmall.copyWith(fontSize: 11),
          // A meta fica sempre visível, mesmo com pouco poupado — é o que
          // dá a noção de quanto falta.
          maximum: goal <= 0 ? null : goalInDisplayCurrency * 1.05,
          plotBands: <PlotBand>[
            if (goal > 0)
              PlotBand(
                isVisible: true,
                start: goalInDisplayCurrency,
                end: goalInDisplayCurrency,
                borderColor: AppColors.success,
                borderWidth: 1.5,
                dashArray: const [6, 4],
                text: AppCurrency.format(goal),
                textStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                horizontalTextAlignment: TextAnchor.end,
                verticalTextAlignment: TextAnchor.start,
              ),
          ],
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x : point.y',
        ),
        series: <CartesianSeries<_Point, DateTime>>[
          AreaSeries<_Point, DateTime>(
            dataSource: points,
            xValueMapper: (point, _) => point.date,
            yValueMapper: (point, _) => point.total,
            color: AppColors.secondary.withValues(alpha: .18),
            borderColor: AppColors.secondary,
            borderWidth: 2.5,
            markerSettings: MarkerSettings(
              isVisible: true,
              height: 7,
              width: 7,
              borderWidth: 2,
              color: AppColors.surface,
              borderColor: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  List<_Point> _cumulativePoints() {
    final sorted = [...savings]..sort((a, b) => a.date.compareTo(b.date));

    var running = 0.0;
    final points = <_Point>[];

    for (final saving in sorted) {
      running += AppCurrency.convert(saving.amount);
      points.add(_Point(saving.date, running));
    }

    // Com um único depósito não há linha nenhuma para desenhar. Um ponto no
    // dia anterior a zero dá a inclinação e mostra de onde se partiu.
    if (points.length == 1) {
      points.insert(
        0,
        _Point(points.first.date.subtract(const Duration(days: 1)), 0),
      );
    }

    return points;
  }
}

class _Point {
  final DateTime date;
  final double total;

  const _Point(this.date, this.total);
}

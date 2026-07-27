import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/analytics/components/category_visuals.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryPieChart extends StatelessWidget {
  final List<CategorySlice> slices;
  final double total;

  const CategoryPieChart({
    super.key,
    required this.slices,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 240,
          child: SfCircularChart(
            margin: const EdgeInsets.all(12),
            tooltipBehavior: TooltipBehavior(enable: true),
            annotations: <CircularChartAnnotation>[
              CircularChartAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TOTAL',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppCurrency.format(total),
                      style: AppTextStyles.headingSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            series: <CircularSeries>[
              DoughnutSeries<CategorySlice, String>(
                dataSource: slices,
                xValueMapper: (data, _) => data.category,
                yValueMapper: (data, _) => data.total,
                pointColorMapper: (data, _) => data.color,
                // Anel maior e sem cantos arredondados: com fatias muito
                // desiguais (ex: 95% vs 1%) os cantos curvos deformavam o
                // anel visualmente. Sem labels de fora do gráfico também
                // já não há linhas de conector a cruzar-se — os valores
                // ficam todos na legenda por baixo, sempre visíveis por
                // inteiro, e o toque numa fatia mostra o detalhe (tooltip).
                innerRadius: '58%',
                radius: '82%',
                strokeColor: AppColors.surface,
                strokeWidth: 3,
                explode: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Wrap(
          spacing: 18,
          runSpacing: 10,
          children: [
            for (final slice in slices)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: slice.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${slice.category} · ${slice.percent.toStringAsFixed(0)}% · '
                    '${AppCurrency.format(slice.total)}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

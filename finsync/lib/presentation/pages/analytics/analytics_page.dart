import 'dart:async';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/calendar_event.dart';
import 'package:finsync/presentation/pages/analytics/analytics_bloc.dart';
import 'package:finsync/presentation/pages/analytics/analytics_event.dart';
import 'package:finsync/presentation/pages/analytics/analytics_state.dart';
import 'package:finsync/presentation/pages/analytics/components/add_event_calendar.dart';
import 'package:finsync/presentation/pages/analytics/components/category_pie_chart.dart';
import 'package:finsync/presentation/pages/analytics/components/category_visuals.dart';
import 'package:finsync/presentation/pages/analytics/components/empty_state.dart';
import 'package:finsync/presentation/pages/analytics/components/error_card.dart';
import 'package:finsync/presentation/pages/analytics/components/event_tile.dart';
import 'package:finsync/presentation/pages/analytics/components/pdf_export_result_sheet.dart';
import 'package:finsync/presentation/pages/analytics/components/section_card.dart';
import 'package:finsync/presentation/pages/analytics/components/top_category_card.dart';
import 'package:finsync/presentation/pages/profile/profile_bloc.dart';
import 'package:finsync/presentation/pages/profile/profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sankey_flutter/sankey_helpers.dart';
import 'package:table_calendar/table_calendar.dart';

const _months = [
  '',
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final now = DateTime.now();
  bool _isExportingPdf = false;

  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(LoadAnalyticsEvent());
  }

  Future<void> _deleteEvent(CalendarEventEntity event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remover evento"),
        content: Text('Tens a certeza que queres remover "${event.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Remover", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final completer = Completer<void>();
      context.read<AnalyticsBloc>().add(
        DeleteEventCalendarEvent(event, completer: completer),
      );

      await completer.future.timeout(const Duration(seconds: 12));

      if (!mounted) return;
      context.read<ProfileBloc>().add(LoadProfileEvent());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _exportPdf() async {
    if (_isExportingPdf) return;

    setState(() {
      _isExportingPdf = true;
    });

    try {
      final completer = Completer<String>();
      context.read<AnalyticsBloc>().add(
        ExportAnalyticsPdfEvent(completer: completer),
      );
      final path = await completer.future.timeout(const Duration(seconds: 20));

      if (!mounted) return;

      await showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (_) => PdfExportResultSheet(filePath: path),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A exportacao demorou demasiado. Tenta novamente.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao exportar PDF: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isExportingPdf = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            if (state is AnalyticsLoadingState ||
                state is AnalyticsInitialState) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              );
            }

            if (state is AnalyticsErrorState) {
              return Center(
                child: ErrorCard(
                  message: state.message,
                  onRetry: () =>
                      context.read<AnalyticsBloc>().add(LoadAnalyticsEvent()),
                ),
              );
            }

            final loaded = state as AnalyticsLoadedState;
            final dayEvents = _selectedDay == null
                ? const <CalendarEventEntity>[]
                : loaded.event
                      .where((event) => isSameDay(event.date, _selectedDay))
                      .toList();
            final categorySlices = buildCategorySlices(loaded.expenses);
            final categoryTotal = categorySlices.fold<double>(
              0,
              (sum, slice) => sum + slice.total,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Analytics",
                    style: AppTextStyles.headingLarge.copyWith(fontSize: 28),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "O teu calendário e o fluxo das tuas finanças",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SectionCard(
                    icon: Icons.calendar_month_rounded,
                    title: "Calendário",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TableCalendar(
                          firstDay: DateTime.utc(
                            now.year,
                            now.month - 2,
                            now.day,
                          ),
                          lastDay: DateTime.utc(
                            now.year + 5,
                            now.month,
                            now.day,
                          ),
                          focusedDay: _focusedDay,

                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },

                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },

                          eventLoader: (day) {
                            return loaded.event
                                .where((event) => isSameDay(event.date, day))
                                .toList();
                          },

                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            weekendStyle: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),

                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            leftChevronIcon: Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.secondary,
                            ),
                            rightChevronIcon: Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.secondary,
                            ),
                          ),

                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            defaultTextStyle: AppTextStyles.bodyMedium,
                            weekendTextStyle: AppTextStyles.bodyMedium,
                            todayDecoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.secondary,
                                width: 1.5,
                              ),
                            ),
                            todayTextStyle: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, day, events) {
                              if (events.isEmpty) return null;
                              final dayEvents = events
                                  .cast<CalendarEventEntity>();

                              return Positioned(
                                bottom: 4,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: dayEvents.take(3).map((event) {
                                    final color =
                                        event.type == CalendarEventType.receita
                                        ? AppColors.success
                                        : AppColors.error;

                                    return Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ),

                        const Divider(height: 32),

                        Text(
                          _selectedDay == null
                              ? "Seleciona um dia para ver os eventos"
                              : "Eventos de ${_selectedDay!.day} ${_months[_selectedDay!.month]}",
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (_selectedDay != null && dayEvents.isEmpty)
                          const EmptyState(
                            icon: Icons.event_busy_rounded,
                            message: "Sem eventos neste dia.",
                          )
                        else
                          ...dayEvents.map(
                            (event) => EventTile(
                              event: event,
                              onDelete: () => _deleteEvent(event),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppColors.surface,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                          builder: (_) => const AddEventCalendar(),
                        );
                      },
                      icon: Icon(Icons.add_rounded, color: AppColors.secondary),
                      label: Text(
                        "Criar um evento",
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.secondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SectionCard(
                    icon: Icons.account_tree_rounded,
                    title: "Fluxo de Despesas",
                    subtitle: "Como o teu salário se distribui pelas despesas",
                    child: loaded.nodes.isEmpty
                        ? const EmptyState(
                            icon: Icons.bar_chart_rounded,
                            message:
                                "Ainda não há despesas suficientes para gerar o gráfico.",
                          )
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final width = constraints.maxWidth;
                                const height = 380.0;
                                final dataSet =
                                    SankeyDataSet(
                                      nodes: loaded.nodes,
                                      links: loaded.links,
                                    )..layout(
                                      generateSankeyLayout(
                                        width: width,
                                        height: height,
                                      ),
                                    );

                                return SankeyDiagramWidget(
                                  data: dataSet,
                                  nodeColors: generateDefaultNodeColorMap(
                                    loaded.nodes,
                                  ),
                                  size: Size(width, height),
                                  showLabels: true,
                                  showTexture: false,
                                  onNodeSelected: (node) {},
                                );
                              },
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  SectionCard(
                    icon: Icons.donut_large_rounded,
                    title: "Despesas por categoria",
                    child: categorySlices.isEmpty
                        ? const EmptyState(
                            icon: Icons.pie_chart_outline_rounded,
                            message: "Ainda não existem despesas para mostrar.",
                          )
                        : CategoryPieChart(
                            slices: categorySlices,
                            total: categoryTotal,
                          ),
                  ),

                  const SizedBox(height: 24),

                  SectionCard(
                    icon: Icons.trending_up_rounded,
                    title: "Categoria com maior gasto",
                    child: TopCategoryCard(slices: categorySlices),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _isExportingPdf ? null : _exportPdf,
                      icon: _isExportingPdf
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            )
                          : Icon(
                              Icons.picture_as_pdf_rounded,
                              color: AppColors.error,
                            ),
                      label: Text(
                        _isExportingPdf
                            ? "A gerar relatório..."
                            : "Exportar relatório em PDF",
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

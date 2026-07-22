import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/analytics/analytics_bloc.dart';
import 'package:finsync/presentation/pages/analytics/analytics_event.dart';
import 'package:finsync/presentation/pages/analytics/analytics_state.dart';
import 'package:finsync/presentation/pages/analytics/components/add_event_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sankey_flutter/sankey_helpers.dart';
import 'package:table_calendar/table_calendar.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(LoadAnalyticsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Analytics and Calendar",
                    style: AppTextStyles.headingMedium.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 24),

                  TableCalendar(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),

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
                      if (state is! AnalyticsLoadedState) {
                        return [];
                      }

                      return state.event.where((event) {
                        return isSameDay(event.date, day);
                      }).toList();
                    },
                  ),

                  if (state is AnalyticsLoadedState && _selectedDay != null)
                    ...state.event
                        .where((event) => isSameDay(event.date, _selectedDay))
                        .map(
                          (event) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.event),
                              title: Text(event.name),
                              subtitle: Text("${event.price} €"),
                            ),
                          ),
                        ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => const AddEventCalendar(),
                        );
                      },
                      icon: const Icon(
                        Icons.calendar_month,
                        color: AppColors.secondary,
                      ),
                      label: const Text(
                        "Criar um evento",
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.secondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (state is AnalyticsLoadingState)
                    const Center(child: CircularProgressIndicator())
                  else if (state is AnalyticsErrorState)
                    Center(child: Text(state.message))
                  else if (state is AnalyticsLoadedState)
                    if (state.nodes.isEmpty)
                      const Text(
                        "Ainda não há despesas suficientes para gerar o gráfico.",
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          const height = 400.0;
                          final dataSet =
                              SankeyDataSet(
                                nodes: state.nodes,
                                links: state.links,
                              )..layout(
                                generateSankeyLayout(
                                  width: width,
                                  height: height,
                                ),
                              );

                          return SankeyDiagramWidget(
                            data: dataSet,
                            nodeColors: generateDefaultNodeColorMap(
                              state.nodes,
                            ),
                            size: Size(width, height),
                            showLabels: true,
                            showTexture: true,
                            onNodeSelected: (node) {},
                          );
                        },
                      ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: export PDF
                      },
                      icon: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: AppColors.error,
                      ),
                      label: const Text(
                        "PDF",
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
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

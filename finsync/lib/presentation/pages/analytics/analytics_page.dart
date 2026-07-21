import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/analytics/analytics_bloc.dart';
import 'package:finsync/presentation/pages/analytics/analytics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<StatefulWidget> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            if (state is AnalyticsLoadedState) {}

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state is AnalyticsLoadingState)
                    const Center(child: CircularProgressIndicator())
                  else if (state is AnalyticsErrorState)
                    Center(child: Text(state.message))
                  else
                    Text(
                      "Analytics and Calendar",
                      style: AppTextStyles.headingMedium.copyWith(fontSize: 22),
                    ),
                  const SizedBox(height: 24),

                  TableCalendar(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: DateTime.now(),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.logout_rounded,
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

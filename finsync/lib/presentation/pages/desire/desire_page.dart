import 'package:finsync/presentation/pages/desire/componente/desires_list.dart';
import 'package:finsync/presentation/pages/desire/desire_bloc.dart';
import 'package:finsync/presentation/pages/desire/desire_event.dart';
import 'package:finsync/presentation/pages/desire/desire_state.dart';
import 'package:flutter/material.dart';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

import 'package:finsync/presentation/pages/desire/componente/add_desire.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DesirePage extends StatefulWidget {
  const DesirePage({super.key});

  @override
  State<DesirePage> createState() => _DesirePageState();
}

class _DesirePageState extends State<DesirePage> {
  @override
  void initState() {
    super.initState();

    context.read<DesireBloc>().add(GetAllDesireEvent());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<DesireBloc, DesireState>(
        builder: (context, state) {
          if (state is DesireLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DesireErrorState) {
            return Center(child: Text(state.message));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  "Os teus desejos ✨",
                  style: AppTextStyles.headingLarge.copyWith(fontSize: 30),
                ),

                const SizedBox(height: 8),

                Text(
                  "Define objetivos e acompanha aquilo que queres comprar.",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,

                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

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
                        builder: (context) => const AddDesire(),
                      );
                    },

                    icon: const Icon(Icons.add_rounded),

                    label: const Text("Adicionar desejo"),
                  ),
                ),

                const SizedBox(height: 30),

                Text("Os teus objetivos", style: AppTextStyles.headingMedium),

                const SizedBox(height: 18),

                if (state is DesireLoadedState)
                  DesiresList(desires: state.desire),
              ],
            ),
          );
        },
      ),
    );
  }
}

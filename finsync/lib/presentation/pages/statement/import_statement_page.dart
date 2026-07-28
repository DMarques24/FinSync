import 'dart:async';
import 'dart:io';

import 'package:finsync/core/di/injection.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/analytics/components/error_card.dart';
import 'package:finsync/presentation/pages/home/home_bloc.dart';
import 'package:finsync/presentation/pages/home/home_event.dart';
import 'package:finsync/presentation/pages/statement/components/parsed_transaction_tile.dart';
import 'package:finsync/presentation/pages/statement/statement_bloc.dart';
import 'package:finsync/presentation/pages/statement/statement_event.dart';
import 'package:finsync/presentation/pages/statement/statement_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ImportStatementPage extends StatelessWidget {
  final File file;

  const ImportStatementPage({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StatementBloc>()..add(ParseStatementEvent(file)),
      child: const _ImportStatementView(),
    );
  }
}

class _ImportStatementView extends StatefulWidget {
  const _ImportStatementView();

  @override
  State<_ImportStatementView> createState() => _ImportStatementViewState();
}

class _ImportStatementViewState extends State<_ImportStatementView> {
  Future<void> _import() async {
    final completer = Completer<int>();
    context.read<StatementBloc>().add(
      ImportSelectedTransactionsEvent(completer: completer),
    );

    try {
      final imported = await completer.future.timeout(
        const Duration(seconds: 60),
      );

      if (!mounted) return;

      context.read<HomeBloc>().add(GetAllExpensesEvent());

      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            tr('statement.imported_success', {'count': '$imported'}),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('statement.import_timeout'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          tr('statement.title'),
          style: AppTextStyles.headingMedium.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<StatementBloc, StatementState>(
          builder: (context, state) {
            if (state is StatementErrorState) {
              return Center(
                child: ErrorCard(
                  message: state.message,
                  onRetry: () => Navigator.of(context).pop(),
                ),
              );
            }

            if (state is StatementReviewState) {
              return _ReviewList(state: state, onImport: _import);
            }

            return const _ParsingIndicator();
          },
        ),
      ),
    );
  }
}

class _ParsingIndicator extends StatelessWidget {
  const _ParsingIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.secondary),
          const SizedBox(height: 20),
          Text(tr('statement.parsing'), style: AppTextStyles.bodyMedium),
          const SizedBox(height: 6),
          Text(
            tr('statement.parsing_hint'),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  final StatementReviewState state;
  final VoidCallback onImport;

  const _ReviewList({required this.state, required this.onImport});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StatementBloc>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('statement.found', {
                        'count': '${state.transactions.length}',
                      }),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr('statement.review_hint'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    bloc.add(SelectAllTransactionsEvent(!state.allSelected)),
                child: Text(
                  state.allSelected
                      ? tr('statement.deselect_all')
                      : tr('statement.select_all'),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            itemCount: state.transactions.length,
            itemBuilder: (context, index) {
              return ParsedTransactionTile(
                transaction: state.transactions[index],
                selected: state.selectedIndexes.contains(index),
                onToggle: () => bloc.add(ToggleTransactionEvent(index)),
                onCategoryChanged: (category) =>
                    bloc.add(UpdateTransactionCategoryEvent(index, category)),
                onTypeChanged: (type) =>
                    bloc.add(UpdateTransactionTypeEvent(index, type)),
              );
            },
          ),
        ),

        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: FilledButton.icon(
              onPressed: state.isImporting || !_canImport() ? null : onImport,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: state.isImporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download_done_rounded),
              label: Text(
                _missingCategory()
                    ? tr('statement.missing_category')
                    : tr('statement.import_button', {
                        'count': '${state.selectedCount}',
                      }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _missingCategory() =>
      state.selectedTransactions.any((t) => t.category == null);

  bool _canImport() => state.selectedCount > 0 && !_missingCategory();
}

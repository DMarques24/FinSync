import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/domain/entities/expense_category.dart';


String categoryLabel(ExpenseCategory category) => tr(category.labelKey);

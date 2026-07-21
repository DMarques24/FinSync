import 'package:finsync/data/datasources/expense_remote_datasource.dart';
import 'package:finsync/data/models/expense_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseRemoteDatasourceImpl extends ExpenseRemoteDatasource {
  ExpenseRemoteDatasourceImpl();
  final supabase = Supabase.instance.client;

  String get userId => supabase.auth.currentUser!.id;

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    final List<dynamic> result = await supabase
        .from("expenses")
        .select()
        .eq('user_id', userId);
    return result.map((json) => ExpenseModel.fromJson(json)).toList();
  }

  @override
  Future<List<ExpenseModel>> getFilterTimeExpenses(DateTime date) async {
    final result = await supabase
        .from("expenses")
        .select()
        .eq("user_id", userId)
        .gte("created_at", date.toIso8601String());

    return result.map((json) => ExpenseModel.fromJson(json)).toList();
  }

  @override
  Future<void> insertExpense(ExpenseModel expense) async {
    await supabase.from("expenses").insert(expense.toJson(userId));
  }
}

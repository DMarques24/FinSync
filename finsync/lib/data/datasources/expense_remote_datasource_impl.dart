import 'package:finsync/data/datasources/expense_remote_datasource.dart';
import 'package:finsync/data/models/expense_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseRemoteDatasourceImpl extends ExpenseRemoteDatasource {
  ExpenseRemoteDatasourceImpl();
  final supabase = Supabase.instance.client;

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    final List<dynamic> result = await supabase.from("expenses").select();
    debugPrint("ExpenseRemoteDatasourceImpl: getAllExpenses: result: $result");
    return result.map((json) => ExpenseModel.fromJson(json)).toList();
  }

  @override
  Future<void> insertExpense(ExpenseModel expense) async {
    await supabase.from("expenses").insert(expense.toJson());
  }
}

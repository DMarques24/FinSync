import 'package:finsync/data/datasources/expenses_remote_datasource.dart';
import 'package:finsync/data/models/expenses_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpensesRemoteDatasourceImpl extends ExpensesRemoteDatasource {
  ExpensesRemoteDatasourceImpl();
  final supabase = Supabase.instance.client;

  @override
  Future<List<ExpensesModel>> getAllExpenses() async {
    final List<dynamic> result = await supabase.from("expenses").select();
    debugPrint("ExpensesRemoteDatasourceImpl: getAllExpenses: result: $result");
    return result.map((json) => ExpensesModel.fromJson(json)).toList();
  }

  @override
  Future<void> insertExpenses(ExpensesModel expense) async {
    await supabase.from("expenses").insert(expense.toJson());
  }
}

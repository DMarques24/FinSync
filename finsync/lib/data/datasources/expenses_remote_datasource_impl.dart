import 'package:finsync/data/datasources/expenses_remote_datasource.dart';
import 'package:finsync/data/models/expenses_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpensesRemoteDatasourceImpl extends ExpensesRemoteDatasource {
  ExpensesRemoteDatasourceImpl();

  @override
  Future<List<ExpensesModel>> getAllExpenses() async {
    final supabase = Supabase.instance.client;
    final List<dynamic> result = await supabase.from("expenses").select();
    return result.map((json) => ExpensesModel.fromJson(json)).toList();
  }
}

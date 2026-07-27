import 'package:finsync/data/datasources/expense_remote_datasource.dart';
import 'package:finsync/data/models/expense_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseRemoteDatasourceImpl extends ExpenseRemoteDatasource {
  ExpenseRemoteDatasourceImpl();
  final supabase = Supabase.instance.client;

  String get userId {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Utilizador não autenticado para consultar despesas.');
    }
    return user.id;
  }

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    final List<dynamic> result = await supabase
        .from("expenses")
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
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
  Future<ExpenseModel> getTopExpenseCategory() async {
    final result = await supabase.rpc(
      'get_top_expense_category',
      params: {'p_user_id': userId},
    );

    if (result is List &&
        result.isNotEmpty &&
        result.first is Map<String, dynamic>) {
      return ExpenseModel.fromJson(result.first as Map<String, dynamic>);
    }

    if (result is Map<String, dynamic>) {
      return ExpenseModel.fromJson(result);
    }

    return ExpenseModel(
      id: 0,
      name: '',
      price: 0,
      category: '',
      date: DateTime.now(),
    );
  }

  @override
  Future<void> insertExpense(ExpenseModel expense) async {
    await supabase.from("expenses").insert(expense.toJson(userId));
  }
}

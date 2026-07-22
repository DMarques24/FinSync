import 'package:finsync/data/datasources/user_remote_datasource.dart';
import 'package:finsync/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  final supabase = Supabase.instance.client;

  @override
  Future<List<UserModel>> getUser() async {
    final userId = supabase.auth.currentUser!.id;

    final List<dynamic> result = await supabase
        .from('profiles')
        .select()
        .eq('user_id', userId);

    return result
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> insertUser(UserModel user, String userId) async {
    await supabase.from('profiles').insert(user.toJson(userId));
  }

  @override
  Future<void> completeOnboarding(String userId, double balance) async {
    await supabase
        .from('profiles')
        .update({'balance': balance, 'isFirstLogin': false})
        .eq('user_id', userId);
  }

  @override
  Future<void> adjustBalance(double delta) async {
    await supabase.rpc('adjust_profile_balance', params: {'p_delta': delta});
  }
}

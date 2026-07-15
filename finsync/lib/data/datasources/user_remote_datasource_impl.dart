import 'package:finsync/data/datasources/user_remote_datasource.dart';
import 'package:finsync/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  final SupabaseClient supabase = Supabase.instance.client;

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
}

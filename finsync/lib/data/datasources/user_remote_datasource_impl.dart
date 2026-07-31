import 'dart:io';

import 'package:finsync/data/datasources/user_remote_datasource.dart';
import 'package:finsync/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  final supabase = Supabase.instance.client;

  static const _avatarBucket = 'avatars';

  // Antes isto era `currentUser!.id` espalhado pelos métodos. Quando a app
  // arranca sem sessão, esse `!` rebentava com um erro de null que não dizia
  // nada a ninguém. Agora falha com uma frase legível.
  String get userId {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Utilizador não autenticado.');
    }
    return user.id;
  }

  @override
  Future<List<UserModel>> getUser() async {
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

  @override
  Future<void> updateProfile({
    required String username,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{'username': username};
    if (avatarUrl != null) {
      updates['avatar_url'] = avatarUrl;
    }

    await supabase.from('profiles').update(updates).eq('user_id', userId);
  }

  @override
  Future<String> uploadAvatar(File file) async {
    final extension = file.path.contains('.')
        ? file.path.split('.').last
        : 'jpg';
    final path = '$userId/avatar.$extension';

    await supabase.storage
        .from(_avatarBucket)
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    final publicUrl = supabase.storage.from(_avatarBucket).getPublicUrl(path);
    return '$publicUrl?updated=${DateTime.now().millisecondsSinceEpoch}';
  }
}

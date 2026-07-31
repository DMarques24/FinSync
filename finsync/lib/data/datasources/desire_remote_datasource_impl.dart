import 'dart:io';

import 'package:finsync/data/datasources/desire_remote_datasource.dart';
import 'package:finsync/data/models/desire_model.dart';
import 'package:finsync/data/models/desire_saving_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DesireRemoteDatasourceImpl extends DesireRemoteDatasource {
  DesireRemoteDatasourceImpl();
  final supabase = Supabase.instance.client;

  static const _bucket = 'desire-images';

  String get userId {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Utilizador não autenticado para consultar desejos.');
    }
    return user.id;
  }

  @override
  Future<List<DesireModel>> getAllDesires() async {
    final List<dynamic> result = await supabase
        .from('desire')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: true);

    return result.map((json) => DesireModel.fromJson(json)).toList();
  }

  @override
  Future<void> insertDesire(DesireModel desire) async {
    await supabase.from('desire').insert(desire.toJson(userId));
  }

  @override
  Future<String> uploadImage(File file) async {
    final extension = file.path.contains('.')
        ? file.path.split('.').last
        : 'jpg';
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final path = '$userId/$fileName';

    await supabase.storage
        .from(_bucket)
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    return supabase.storage.from(_bucket).getPublicUrl(path);
  }

  @override
  Future<void> insertDesireSaving(DesireSavingModel saving) async {
    await supabase.from('desire_savings').insert(saving.toJson(userId));

    // A soma é feita na base de dados, não aqui. Ler o total, somar em Dart
    // e voltar a escrever perderia poupanças feitas ao mesmo tempo noutro
    // dispositivo — a última escrita apagava a outra.
    await supabase.rpc(
      'add_desire_saved',
      params: {'p_desire_id': saving.desireId, 'p_amount': saving.amount},
    );
  }

  @override
  Future<List<DesireSavingModel>> getDesireSavings(int desireId) async {
    final List<dynamic> result = await supabase
        .from('desire_savings')
        .select()
        .eq('user_id', userId)
        .eq('desire_id', desireId)
        .order('created_at', ascending: true);

    return result.map((json) => DesireSavingModel.fromJson(json)).toList();
  }

  @override
  Future<void> updateDesireReviews(
    int desireId,
    List<Map<String, dynamic>> reviews,
    DateTime reviewedAt,
  ) async {
    await supabase
        .from('desire')
        .update({
          'reviews': reviews,
          'last_reviewed_at': reviewedAt.toIso8601String(),
        })
        .eq('id', desireId)
        .eq('user_id', userId);
  }
}

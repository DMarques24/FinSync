import 'dart:io';

import 'package:finsync/data/datasources/desire_remote_datasource.dart';
import 'package:finsync/data/models/desire_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DesireRemoteDatasourceImpl extends DesireRemoteDatasource {
  DesireRemoteDatasourceImpl();
  final supabase = Supabase.instance.client;

  static const _bucket = 'desire-images';

  @override
  Future<List<DesireModel>> getAllDesires() async {
    final userId = supabase.auth.currentUser!.id;
    final List<dynamic> result = await supabase
        .from('desire')
        .select()
        .eq('user_id', userId);
    return result.map((json) => DesireModel.fromJson(json)).toList();
  }

  @override
  Future<void> insertDesire(DesireModel desire) async {
    final userId = supabase.auth.currentUser!.id;

    await supabase.from('desire').insert(desire.toJson(userId));
  }

  @override
  Future<String> uploadImage(File file) async {
    final userId = supabase.auth.currentUser!.id;

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
}

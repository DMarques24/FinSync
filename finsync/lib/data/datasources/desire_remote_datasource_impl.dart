import 'package:finsync/data/datasources/desire_remote_datasource.dart';
import 'package:finsync/data/models/desire_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DesireRemoteDatasourceImpl extends DesireRemoteDatasource {
  DesireRemoteDatasourceImpl();
  final supabase = Supabase.instance.client;

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
}

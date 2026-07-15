import 'package:finsync/data/datasources/desire_remote_datasource.dart';
import 'package:finsync/data/models/desire_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DesireRemoteDatasourceImpl extends DesireRemoteDatasource {
  DesireRemoteDatasourceImpl();
  final supabase = Supabase.instance.client;

  @override
  Future<List<DesireModel>> getAllDesires() async {
    final List<dynamic> result = await supabase.from('desire').select();
    debugPrint("DesireRemoteDatasourceImpl: getAllDesires result: $result");
    return result.map((json) => DesireModel.fromJson(json)).toList();
  }

  @override
  Future<void> insertDesire(DesireModel desire) async {
    await supabase.from('desire').insert(desire.toJson());
  }
}

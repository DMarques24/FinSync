import 'package:finsync/data/datasources/desire_remote_datasource.dart';
import 'package:finsync/data/models/desire_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DesireRemoteDatasourceImpl extends DesireRemoteDatasource {
  DesireRemoteDatasourceImpl();

  @override
  Future<List<DesireModel>> getAllDesire() async {
    final supabase = Supabase.instance.client;
    final List<dynamic> result = await supabase.from('desire').select();
    debugPrint("DesireRemoteDatasourceImpl: getAllDesire result: $result");
    return result.map((json) => DesireModel.fromJson(json)).toList();
  }
}

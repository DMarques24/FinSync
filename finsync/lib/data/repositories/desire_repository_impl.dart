import 'package:finsync/data/datasources/desire_remote_datasource.dart';
import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/domain/repositories/desire_repository.dart';

class DesireRepositoryImpl implements DesireRepository {
  final DesireRemoteDatasource remoteDatasource;

  DesireRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Desire>> getAllDesire() async {
    final models = await remoteDatasource.getAllDesire();
    return models.map((model) => model.toEntity()).toList();
  }
}

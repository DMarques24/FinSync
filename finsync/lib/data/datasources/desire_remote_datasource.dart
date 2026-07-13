import 'package:finsync/data/models/desire_model.dart';

abstract class DesireRemoteDatasource {
  Future<List<DesireModel>> getAllDesire();
}

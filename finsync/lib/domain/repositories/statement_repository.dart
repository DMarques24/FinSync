import 'dart:io';

import 'package:finsync/domain/entities/parsed_transaction.dart';

abstract class StatementRepository {
  Future<List<ParsedTransaction>> parseStatement(File file);
}

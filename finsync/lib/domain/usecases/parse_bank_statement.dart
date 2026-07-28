import 'dart:io';

import 'package:finsync/domain/entities/parsed_transaction.dart';
import 'package:finsync/domain/repositories/statement_repository.dart';

class ParseBankStatement {
  final StatementRepository repository;

  ParseBankStatement(this.repository);

  Future<List<ParsedTransaction>> call(File file) =>
      repository.parseStatement(file);
}

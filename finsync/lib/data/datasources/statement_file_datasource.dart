import 'dart:io';


enum StatementSourceKind { pdf, csv }

class StatementText {
  final StatementSourceKind kind;
  final List<String> lines;

  const StatementText({required this.kind, required this.lines});
}

abstract class StatementFileDatasource {
  Future<StatementText> extractText(File file);
}

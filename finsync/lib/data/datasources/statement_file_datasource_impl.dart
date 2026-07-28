import 'dart:convert';
import 'dart:io';

import 'package:finsync/data/datasources/statement_file_datasource.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class StatementFileDatasourceImpl implements StatementFileDatasource {
  @override
  Future<StatementText> extractText(File file) async {
    final extension = file.path.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return StatementText(
          kind: StatementSourceKind.pdf,
          lines: await _fromPdf(file),
        );
      case 'csv':
      case 'txt':
        return StatementText(
          kind: StatementSourceKind.csv,
          lines: await _fromCsv(file),
        );
      default:
        throw Exception(
          'Formato não suportado (.$extension). Usa o PDF ou o CSV do teu banco.',
        );
    }
  }

  Future<List<String>> _fromPdf(File file) async {
    final document = PdfDocument(inputBytes: await file.readAsBytes());
    try {
      final raw = PdfTextExtractor(document).extractText(layoutText: true);
      final lines = _splitLines(raw);

      if (lines.isEmpty) {
        throw Exception(
          'Este PDF não tem texto legível (parece ser digitalizado). '
          'Descarrega o extrato em PDF ou CSV a partir do homebanking.',
        );
      }
      return lines;
    } finally {
      document.dispose();
    }
  }

  Future<List<String>> _fromCsv(File file) async {
    final bytes = await file.readAsBytes();
    String content;
    try {
      content = utf8.decode(bytes);
    } catch (_) {
      content = latin1.decode(bytes);
    }
    return _splitLines(content);
  }

  List<String> _splitLines(String raw) {
    return raw
        .split(RegExp(r'\r\n|\r|\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }
}

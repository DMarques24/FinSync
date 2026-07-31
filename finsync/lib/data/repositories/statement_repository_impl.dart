import 'dart:io';

import 'package:finsync/data/datasources/statement_file_datasource.dart';
import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/entities/expense_category.dart';
import 'package:finsync/domain/entities/parsed_transaction.dart';
import 'package:finsync/domain/repositories/statement_repository.dart';

class StatementRepositoryImpl implements StatementRepository {
  final StatementFileDatasource datasource;

  StatementRepositoryImpl(this.datasource);

  @override
  Future<List<ParsedTransaction>> parseStatement(File file) async {
    final extracted = await datasource.extractText(file);

    final transactions = extracted.kind == StatementSourceKind.csv
        ? _parseCsv(extracted.lines)
        : _parseFreeText(extracted.lines);

    if (transactions.isEmpty) {
      throw Exception(
        'Não foi possível identificar movimentos neste ficheiro. '
        'Confirma que é um extrato bancário e tenta outro formato.',
      );
    }

    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  // =====================================================================
  // Texto livre (PDF)
  // =====================================================================

  List<ParsedTransaction> _parseFreeText(List<String> lines) {
    final result = <ParsedTransaction>[];

    for (final line in lines) {
      if (_isNoise(line)) continue;

      final amounts = _findAmounts(line);
      if (amounts.isEmpty) continue;
      final amount = amounts.first;
      if (amount.value == 0) continue;

      final dateMatch = _findDate(line);
      final description = _cleanDescription(line, dateMatch, amounts);
      if (description.isEmpty) continue;

      // A marca D/C do banco tem prioridade; só quando não existe é que
      // vamos adivinhar pela descrição.
      final isIncome =
          _debitCreditMarker(line, amount) ?? _looksLikeIncome(line, amount);

      result.add(
        ParsedTransaction(
          name: description,
          price: amount.value,
          date: dateMatch?.date ?? DateTime.now(),
          // Uma entrada de dinheiro não precisa de ser adivinhada: a
          // categoria é `rendimento` e não há nada a rever.
          category: isIncome
              ? ExpenseCategory.income
              : _inferCategory(description),
          type: isIncome ? ExpenseType.receita : ExpenseType.despesa,
          confidence: _confidence(dateMatch, description),
          rawLine: line,
        ),
      );
    }

    return result;
  }

  // =====================================================================
  // CSV / TSV
  // =====================================================================

  List<ParsedTransaction> _parseCsv(List<String> lines) {
    final delimiter = _detectDelimiter(lines);

    int? dateIndex;
    int? descriptionIndex;
    int? amountIndex;
    int? debitIndex;
    int? creditIndex;
    var headerRow = -1;

    for (var i = 0; i < lines.length && i < 15; i++) {
      final cells = _splitCsvLine(lines[i], delimiter).map(_normalize).toList();
      if (cells.length < 2) continue;

      for (var c = 0; c < cells.length; c++) {
        final cell = cells[c];
        if (cell.isEmpty) continue;

        if (dateIndex == null &&
            (cell.contains('data') || cell.contains('date'))) {
          dateIndex = c;
        }
        if (descriptionIndex == null &&
            (cell.contains('descri') ||
                cell.contains('movimento') ||
                cell.contains('historico') ||
                cell.contains('detalhe') ||
                cell.contains('memo') ||
                cell.contains('description'))) {
          descriptionIndex = c;
        }
        if (debitIndex == null && cell.contains('debito')) debitIndex = c;
        if (creditIndex == null && cell.contains('credito')) creditIndex = c;
        if (amountIndex == null &&
            (cell.contains('valor') ||
                cell.contains('montante') ||
                cell.contains('importancia') ||
                cell.contains('amount'))) {
          amountIndex = c;
        }
      }

      if (dateIndex != null &&
          descriptionIndex != null &&
          (amountIndex != null || debitIndex != null || creditIndex != null)) {
        headerRow = i;
        break;
      }

      dateIndex = null;
      descriptionIndex = null;
      amountIndex = null;
      debitIndex = null;
      creditIndex = null;
    }

    if (headerRow == -1) return _parseFreeText(lines);

    final result = <ParsedTransaction>[];

    for (var i = headerRow + 1; i < lines.length; i++) {
      final line = lines[i];
      if (_isNoise(line)) continue;

      final cells = _splitCsvLine(line, delimiter);
      if (cells.length <= descriptionIndex!) continue;

      final description = _tidy(cells[descriptionIndex]);
      if (description.isEmpty) continue;

      _Amount? amount;
      var isIncome = false;

      if (debitIndex != null && debitIndex < cells.length) {
        final debit = _findAmounts(cells[debitIndex]);
        if (debit.isNotEmpty && debit.first.value != 0) {
          amount = debit.first;
          isIncome = false;
        }
      }
      if (amount == null && creditIndex != null && creditIndex < cells.length) {
        final credit = _findAmounts(cells[creditIndex]);
        if (credit.isNotEmpty && credit.first.value != 0) {
          amount = credit.first;
          isIncome = true;
        }
      }
      if (amount == null && amountIndex != null && amountIndex < cells.length) {
        final generic = _findAmounts(cells[amountIndex]);
        if (generic.isNotEmpty && generic.first.value != 0) {
          amount = generic.first;
          isIncome =
              !generic.first.isNegative &&
              _looksLikeIncome(description, generic.first);
        }
      }

      if (amount == null) continue;

      final dateMatch = dateIndex != null && dateIndex < cells.length
          ? _findDate(cells[dateIndex])
          : _findDate(line);

      result.add(
        ParsedTransaction(
          name: description,
          price: amount.value,
          date: dateMatch?.date ?? DateTime.now(),
          category: isIncome
              ? ExpenseCategory.income
              : _inferCategory(description),
          type: isIncome ? ExpenseType.receita : ExpenseType.despesa,
          confidence: dateMatch == null ? 0.7 : 0.95,
          rawLine: line,
        ),
      );
    }

    return result;
  }

  String _detectDelimiter(List<String> lines) {
    final sample = lines.take(10).join('\n');
    final counts = {
      ';': ';'.allMatches(sample).length,
      ',': ','.allMatches(sample).length,
      '\t': '\t'.allMatches(sample).length,
    };
    var best = ';';
    var bestCount = -1;
    counts.forEach((delimiter, count) {
      if (count > bestCount) {
        best = delimiter;
        bestCount = count;
      }
    });
    return best;
  }

  List<String> _splitCsvLine(String line, String delimiter) {
    final cells = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == delimiter && !inQuotes) {
        cells.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    cells.add(buffer.toString());

    return cells.map((cell) => cell.trim()).toList();
  }

  // =====================================================================
  // Datas
  // =====================================================================

  static final _isoDateRegex = RegExp(r'\b(\d{4})-(\d{1,2})-(\d{1,2})\b');
  static final _fullDateRegex = RegExp(
    r'\b(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{2,4})\b',
  );
  static final _shortDateRegex = RegExp(r'\b(\d{1,2})[/\-.](\d{1,2})\b');

  _DateMatch? _findDate(String line) {
    final iso = _isoDateRegex.firstMatch(line);
    if (iso != null) {
      final date = _buildDate(
        int.parse(iso.group(3)!),
        int.parse(iso.group(2)!),
        int.parse(iso.group(1)!),
      );
      if (date != null) {
        return _DateMatch(date, iso.start, iso.end, hasYear: true);
      }
    }

    final full = _fullDateRegex.firstMatch(line);
    if (full != null) {
      var year = int.parse(full.group(3)!);
      if (year < 100) year += 2000;
      final date = _buildDate(
        int.parse(full.group(1)!),
        int.parse(full.group(2)!),
        year,
      );
      if (date != null) {
        return _DateMatch(date, full.start, full.end, hasYear: true);
      }
    }

    final short = _shortDateRegex.firstMatch(line);
    if (short != null) {
      final now = DateTime.now();
      var date = _buildDate(
        int.parse(short.group(1)!),
        int.parse(short.group(2)!),
        now.year,
      );

      if (date != null && date.isAfter(now.add(const Duration(days: 15)))) {
        date = DateTime(date.year - 1, date.month, date.day);
      }
      if (date != null) {
        return _DateMatch(date, short.start, short.end, hasYear: false);
      }
    }

    return null;
  }

  DateTime? _buildDate(int day, int month, int year) {
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 31) return null;
    if (year < 1990 || year > 2100) return null;

    final date = DateTime(year, month, day);
    if (date.day != day || date.month != month) return null;
    return date;
  }

  // =====================================================================
  // Valores monetários
  // =====================================================================

  /// O `(?![.,/\-]\d)` no fim é o que impede uma data de ser lida como um
  /// valor. Numa linha que comece por `01.03.2026`, o `01.03` encaixava em
  /// `\d+[.,]\d{2}` e era escolhido como o valor do movimento, porque vem
  /// antes do valor verdadeiro. Todos os movimentos de bancos que escrevem
  /// datas com pontos eram importados com um ou dois euros.
  ///
  /// Com esta condição, `01.03` é rejeitado por vir seguido de `.2026`,
  /// enquanto `45,20   1.234,56` continua a passar — o que vem a seguir são
  /// espaços, não um separador colado a dígitos.
  static final _amountRegex = RegExp(
    r'(-|\+)?\s*(?:€|EUR)?\s*('
    r'\d{1,3}(?:[.\s]\d{3})+,\d{2}'
    r'|\d{1,3}(?:[,\s]\d{3})+\.\d{2}'
    r'|\d+[.,]\d{2}'
    r')(?!\d)(?![.,/\-]\d)\s*(-)?\s*(?:€|EUR)?',
  );

  List<_Amount> _findAmounts(String line) {
    final amounts = <_Amount>[];

    for (final match in _amountRegex.allMatches(line)) {
      final value = _parseAmount(match.group(2)!);
      if (value == null) continue;
      final negative = match.group(1) == '-' || match.group(3) == '-';

      amounts.add(
        _Amount(
          value: value,
          isNegative: negative,
          start: match.start,
          end: match.end,
        ),
      );
    }

    return amounts;
  }

  double? _parseAmount(String raw) {
    final value = raw.replaceAll(' ', '');
    final separator = value.lastIndexOf(RegExp(r'[.,]'));
    if (separator == -1) return null;

    final integerPart = value
        .substring(0, separator)
        .replaceAll(RegExp(r'[.,]'), '');
    final decimalPart = value.substring(separator + 1);

    return double.tryParse('$integerPart.$decimalPart');
  }

  // =====================================================================
  // Tipo (despesa / receita)
  // =====================================================================

  static const _incomeKeywords = [
    'transferencia recebida',
    'transf recebida',
    'transf. recebida',
    'deposito',
    'salario',
    'ordenado',
    'vencimento',
    'reembolso',
    'estorno',
    'devolucao',
    'juros credores',
    'credito em conta',
    'recebido',
    'entrada',
  ];

  bool _looksLikeIncome(String line, _Amount amount) {
    if (amount.isNegative) return false;

    final normalized = _normalize(line);
    return _incomeKeywords.any(normalized.contains);
  }

  /// Muitos extratos marcam a natureza do movimento com uma letra a seguir
  /// ao valor: `52,37 D` para débito, `1.450,00 C` para crédito. Quando
  /// está lá, é informação do banco e vale mais do que qualquer palavra
  /// que tentemos adivinhar na descrição.
  static final _debitCreditRegex = RegExp(
    r'^\s*(DB|CR|D|C)\b',
    caseSensitive: false,
  );

  bool? _debitCreditMarker(String line, _Amount amount) {
    if (amount.end >= line.length) return null;

    final match = _debitCreditRegex.firstMatch(line.substring(amount.end));
    if (match == null) return null;

    final marker = match.group(1)!.toUpperCase();
    return marker == 'C' || marker == 'CR';
  }

  // =====================================================================
  // Categoria
  // =====================================================================

  /// Palavras-chave por categoria, com os comerciantes mais comuns em
  /// Portugal. Compras, saúde e subscrições — que já não são categorias
  /// próprias — foram distribuídas por Lazer, por ser o destino mais
  /// razoável para gastos de consumo geral.
  ///
  /// Já não é preciso o truque do espaço no fim (`'bp '`, `'cp '`) para
  /// evitar falsos positivos: a comparação passou a ser por palavra
  /// inteira. Esse truque, além de frágil, falhava sempre que a palavra
  /// era a última da descrição.
  static const _categoryKeywords = <ExpenseCategory, List<String>>{
    ExpenseCategory.alimentacao: [
      // Supermercados
      'continente', 'pingo doce', 'lidl', 'aldi', 'mercadona', 'minipreco',
      'intermarche', 'auchan', 'jumbo', 'el corte ingles', 'froiz',
      'meu super', 'amanhecer', 'coviran', 'spar', 'supercor',
      'supermercado', 'mercado', 'mini mercado', 'talho', 'peixaria',
      'frutaria', 'charcutaria', 'mercearia', 'celeiro', 'go natural',
      // Restauração
      'restaurante', 'restaur', 'cafe', 'cafetaria', 'snack', 'snack bar',
      'padaria', 'pastelaria', 'confeitaria', 'gelataria', 'churrasqueira',
      'cervejaria', 'marisqueira', 'tasca', 'cantina', 'catering',
      'mcdonald', 'burger king', 'burger', 'kfc', 'pizza hut', 'pizza',
      'telepizza', 'dominos', 'subway', 'vitaminas', 'h3', 'nandos',
      'starbucks', 'delta cafes', 'sical', 'buondi', 'a padaria portuguesa',
      'wok', 'sushi', 'kebab', 'pans', 'chicken',
      // Entregas
      'uber eats', 'ubereats', 'glovo', 'bolt food', 'takeaway', 'takeway',
      'deliveroo', 'noocity',
    ],
    ExpenseCategory.transporte: [
      // Combustível
      'galp', 'bp', 'repsol', 'cepsa', 'prio', 'intermarche combustivel',
      'combustivel', 'gasolina', 'gasoleo', 'abastecimento', 'posto',
      'estacao de servico', 'area de servico',
      // Portagens e estacionamento
      'via verde', 'viaverde', 'brisa', 'portagem', 'portagens', 'ascendi',
      'estacionamento', 'parquimetro', 'parque', 'emel', 'saba', 'empark',
      // Transportes públicos
      'cp', 'comboios', 'comboios de portugal', 'metro', 'metropolitano',
      'carris', 'transtejo', 'soflusa', 'rodoviaria', 'flixbus', 'rede expressos',
      'navegante', 'andante', 'passe',
      // Táxis e partilhados
      'uber', 'bolt', 'taxi', 'freenow', 'free now', 'cooltra', 'lime',
      // Manutenção
      'oficina', 'pneus', 'norauto', 'midas', 'feuvert', 'inspecao',
      'ipo automovel', 'lavagem auto', 'imt',
    ],
    ExpenseCategory.investimentos: [
      'xtb', 'degiro', 'trading 212', 'trading212', 'etoro', 'revolut invest',
      'interactive brokers', 'ibkr', 'coinbase', 'binance', 'kraken',
      'bison bank', 'lightyear', 'trade republic', 'saxo',
      'certificados de aforro', 'certificados do tesouro', 'obrigacoes',
      'ppr', 'plano poupanca reforma', 'fundo de investimento', 'fundos',
      'bolsa', 'corretora', 'dividendos', 'etf', 'acoes',
    ],
    ExpenseCategory.poupanca: [
      'poupanca', 'deposito a prazo', 'conta poupanca',
      'transferencia poupanca', 'aforro', 'mealheiro', 'reserva',
      'conta ordenado poupanca', 'aplicacao financeira',
    ],
    ExpenseCategory.lazer: [
      // Cultura e espetáculos
      'cinema', 'nos cinemas', 'ucicinemas', 'cinemas nos', 'teatro',
      'concerto', 'bilhete', 'bilheteira', 'ticketline', 'blueticket',
      'bol', 'museu', 'zoo', 'oceanario', 'feira',
      // Jogos
      'steam', 'playstation', 'xbox', 'nintendo', 'epic games', 'riot',
      'blizzard', 'ea games', 'twitch',
      // Desporto e bem-estar
      'ginasio', 'fitness', 'holmes place', 'solinca', 'phive', 'fitness hut',
      'crossfit', 'piscina', 'padel', 'spa',
      // Viagens
      'hotel', 'hostel', 'booking', 'airbnb', 'ryanair', 'tap', 'easyjet',
      'vueling', 'wizz air', 'lufthansa', 'iberia', 'viagem', 'agencia viagens',
      'abreu', 'edreams', 'skyscanner', 'trivago', 'pousada',
      // Bares
      'bar', 'discoteca', 'pub', 'lounge',
      // Antigas "Compras"
      'fnac', 'worten', 'amazon', 'aliexpress', 'ebay', 'zara', 'h&m',
      'primark', 'bershka', 'pull&bear', 'stradivarius', 'mango',
      'sport zone', 'decathlon', 'jd sports', 'nike', 'adidas', 'sportsdirect',
      'ikea', 'leroy merlin', 'aki', 'maxmat', 'conforama', 'jysk',
      'radio popular', 'mediamarkt', 'shein', 'temu', 'wallapop', 'vinted',
      'sapataria', 'perfumaria', 'douglas', 'sephora', 'normal', 'flying tiger',
      // Antigas "Subscrições"
      'netflix', 'spotify', 'hbo', 'max', 'disney', 'youtube', 'prime video',
      'apple.com', 'itunes', 'icloud', 'apple', 'google', 'microsoft',
      'office 365', 'dropbox', 'adobe', 'canva', 'chatgpt', 'openai',
      'meo', 'nos', 'vodafone', 'nowo', 'altice', 'digi', 'mensalidade',
      'subscricao', 'assinatura', 'renovacao',
      // Seguros
      'seguro', 'seguros', 'fidelidade', 'tranquilidade', 'ageas',
      'allianz', 'zurich', 'generali', 'lusitania', 'una seguros',
      // Antigas "Saúde"
      'farmacia', 'hospital', 'clinica', 'medico', 'dentista', 'dentaria',
      'analises', 'laboratorio', 'consulta', 'fisioterapia', 'optica',
      'oculista', 'wells', 'medicina', 'saude', 'cuf', 'luz saude',
      'lusiadas', 'sns', 'multiopticas', 'alain afflelou', 'medis',
      'advancecare',
    ],
  };

  /// Escolhe a categoria pela palavra-chave **mais específica** que
  /// aparecer na descrição, não pela primeira que calhar.
  ///
  /// A diferença importa: `uber eats` e `uber` estão os dois na lista, em
  /// categorias diferentes. Com a regra antiga, quem ganhava dependia da
  /// ordem em que o mapa estivesse escrito — uma ida ao supermercado podia
  /// ir parar a Transporte por causa de uma palavra que calhava vir antes.
  ExpenseCategory? _inferCategory(String description) {
    final normalized = _normalize(description);

    ExpenseCategory? best;
    var bestLength = 0;

    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        // Só vale a pena testar se for mais específica do que a que já temos.
        if (keyword.length <= bestLength) continue;

        if (_containsWord(normalized, keyword)) {
          best = entry.key;
          bestLength = keyword.length;
        }
      }
    }

    return best;
  }

  /// Comprimento a partir do qual a palavra-chave pode ser só o princípio
  /// da palavra. Abaixo disto exigimos a palavra exata.
  static const _prefixMatchMinLength = 4;

  /// Procura a palavra-chave respeitando fronteiras de palavra.
  ///
  /// Sem isto, `bp` apanhava `BPI`, `cp` apanhava `COMPRA` e `nos` apanhava
  /// qualquer descrição com "nossos" — o `contains` simples é demasiado
  /// permissivo para nomes curtos.
  ///
  /// Mas exigir fronteira nos dois lados também falha: `mcdonald` não
  /// apanhava `MCDONALDS`, e os bancos escrevem os comerciantes como lhes
  /// apetece. O meio-termo é exigir fronteira sempre no início e, no fim,
  /// só nas palavras curtas — as que dão falsos positivos.
  bool _containsWord(String haystack, String keyword) {
    final requireEndBoundary = keyword.length < _prefixMatchMinLength;

    var index = haystack.indexOf(keyword);

    while (index != -1) {
      final before = index == 0 ? null : haystack.codeUnitAt(index - 1);
      final afterIndex = index + keyword.length;
      final after = afterIndex >= haystack.length
          ? null
          : haystack.codeUnitAt(afterIndex);

      final startsCleanly = !_isWordChar(before);
      final endsCleanly = !requireEndBoundary || !_isWordChar(after);

      if (startsCleanly && endsCleanly) return true;

      index = haystack.indexOf(keyword, index + 1);
    }

    return false;
  }

  bool _isWordChar(int? code) {
    if (code == null) return false;

    final isDigit = code >= 0x30 && code <= 0x39;
    final isLower = code >= 0x61 && code <= 0x7a;
    final isUpper = code >= 0x41 && code <= 0x5a;

    return isDigit || isLower || isUpper;
  }

  // =====================================================================
  // Limpeza e ruído
  // =====================================================================

  static const _noiseKeywords = [
    'saldo inicial',
    'saldo final',
    'saldo anterior',
    'saldo contabilistico',
    'saldo disponivel',
    'total de',
    'totais',
    'extrato de',
    'extrato n',
    'data valor',
    'data mov',
    'descricao',
    'pagina',
    'iban',
    'nib',
    'swift',
    'bic',
    'titular',
    'periodo de',
    'conta n',
    'numero de conta',
    'limite de credito',
  ];

  bool _isNoise(String line) {
    final normalized = _normalize(line);
    if (normalized.length < 6) return true;
    return _noiseKeywords.any(normalized.contains);
  }

  String _cleanDescription(
    String line,
    _DateMatch? date,
    List<_Amount> amounts,
  ) {

    final cuts = <List<int>>[
      if (date != null) [date.start, date.end],
      for (final amount in amounts) [amount.start, amount.end],
    ]..sort((a, b) => b[0].compareTo(a[0]));

    var result = line;
    for (final cut in cuts) {
      if (cut[0] < 0 || cut[1] > result.length) continue;
      result = result.replaceRange(cut[0], cut[1], ' ');
    }

    return _tidy(result);
  }

  String _tidy(String value) {
    var result = value
        .replaceAll(_isoDateRegex, ' ')
        .replaceAll(_fullDateRegex, ' ')
        .replaceAll(RegExp(r'[€$]|EUR'), ' ')
        .replaceAll(RegExp(r'[|;\t]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .replaceAll(RegExp(r'^[\s\-.,:*#]+'), '')
        .replaceAll(RegExp(r'[\s\-.,:*#]+$'), '')
        .trim();

    if (result.length > 60) result = '${result.substring(0, 60).trim()}…';

    return result;
  }

  double _confidence(_DateMatch? date, String description) {
    var score = 0.4;
    if (date != null) score += date.hasYear ? 0.4 : 0.25;
    if (description.length >= 5) score += 0.2;
    return score.clamp(0.0, 1.0);
  }

  String _normalize(String value) {
    const withAccents = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
    const without = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

    final buffer = StringBuffer();
    for (final char in value.toLowerCase().split('')) {
      final index = withAccents.indexOf(char);
      buffer.write(index == -1 ? char : without[index].toLowerCase());
    }
    return buffer.toString();
  }
}

class _DateMatch {
  final DateTime date;
  final int start;
  final int end;
  final bool hasYear;

  const _DateMatch(this.date, this.start, this.end, {required this.hasYear});
}

class _Amount {
  final double value;
  final bool isNegative;
  final int start;
  final int end;

  const _Amount({
    required this.value,
    required this.isNegative,
    required this.start,
    required this.end,
  });
}

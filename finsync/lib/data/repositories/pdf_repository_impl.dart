import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/data/datasources/pdf_remote_datasource.dart';
import 'package:finsync/data/models/pdf_category_total_model.dart';
import 'package:finsync/domain/repositories/pdf_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfRepositoryImpl implements PdfRepository {
  final PdfRemoteDatasource remoteDatasource;

  PdfRepositoryImpl(this.remoteDatasource);

  @override
  Future<String> createAnalyticsPdf({
    DateTime? referenceDate,
    int upcomingEventsLimit = 10,
    String appName = 'FinSync',
  }) async {
    final payload = await remoteDatasource.fetchAnalyticsPayload(
      referenceDate: referenceDate,
      upcomingEventsLimit: upcomingEventsLimit,
      appName: appName,
    );

    final bytes = await _AnalyticsPdfBuilder(payload).build();

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/relatorio_financeiro_$timestamp.pdf');
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }
}

class _AnalyticsPdfBuilder {
  final PdfAnalyticsPayload payload;

  _AnalyticsPdfBuilder(this.payload);


  static final _primary = PdfColor(15, 23, 42); // AppColors.primary (light)
  static final _secondary = PdfColor(67, 56, 202); // AppColors.secondary
  static final _success = PdfColor(34, 197, 94); // AppColors.success (light)
  static final _error = PdfColor(239, 68, 68); // AppColors.error (light)
  static final _border = PdfColor(226, 232, 240); // AppColors.border (light)
  static final _textSecondary = PdfColor(
    100,
    116,
    139,
  ); // AppColors.textSecondary (light)
  static final _surface = PdfColor(
    248,
    250,
    252,
  ); // AppColors.background (light)

  static final _white = PdfColor(255, 255, 255);

  static final _titleFont = PdfStandardFont(
    PdfFontFamily.helvetica,
    22,
    style: PdfFontStyle.bold,
  );
  static final _subtitleFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
  static final _sectionTitleFont = PdfStandardFont(
    PdfFontFamily.helvetica,
    13,
    style: PdfFontStyle.bold,
  );
  static final _labelFont = PdfStandardFont(PdfFontFamily.helvetica, 8.5);
  static final _valueFont = PdfStandardFont(
    PdfFontFamily.helvetica,
    16,
    style: PdfFontStyle.bold,
  );
  static final _bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 9.5);
  static final _boldBodyFont = PdfStandardFont(
    PdfFontFamily.helvetica,
    9.5,
    style: PdfFontStyle.bold,
  );
  static final _footerFont = PdfStandardFont(PdfFontFamily.helvetica, 8);

  Future<List<int>> build() async {
    final document = PdfDocument();
    _addFooter(document);

    final page = document.pages.add();
    final graphics = page.graphics;
    final size = page.getClientSize();

    final categories = _collapseCategories(payload.pieByCategory, maxSlices: 6);

    var y = _drawHeader(graphics, size);
    y = _drawCashFlowSummary(graphics, size, y);
    y = _drawCategoryBreakdown(graphics, size, y, categories);
    y = _drawFlowDiagram(graphics, size, y, categories);
    _drawUpcomingEvents(page, size, y);

    final bytes = await document.save();
    document.dispose();
    return bytes;
  }

  // ---------------------------------------------------------------------
  // Cabeçalho / rodapé
  // ---------------------------------------------------------------------

  void _addFooter(PdfDocument document) {
    final pageSize = document.pageSettings.size;
    final footer = PdfPageTemplateElement(
      Rect.fromLTWH(0, pageSize.height - 34, pageSize.width, 34),
    );

    footer.graphics.drawLine(
      PdfPen(_border, width: .75),
      Offset(0, 6),
      Offset(pageSize.width, 6),
    );

    final pageNumber = PdfPageNumberField(
      font: _footerFont,
      brush: PdfSolidBrush(_textSecondary),
    );
    final pageCount = PdfPageCountField(
      font: _footerFont,
      brush: PdfSolidBrush(_textSecondary),
    );
    final composite = PdfCompositeField(
      font: _footerFont,
      brush: PdfSolidBrush(_textSecondary),
      text: 'Gerado por ${payload.appName}   •   Página {0} de {1}',
      fields: [pageNumber, pageCount],
    );
    composite.bounds = Rect.fromLTWH(0, 14, pageSize.width, 16);
    
    composite.draw(footer.graphics, const Offset(0, 14));

    document.template.bottom = footer;
  }

  double _drawHeader(PdfGraphics graphics, Size size) {
    graphics.drawRectangle(
      brush: PdfSolidBrush(_primary),
      bounds: Rect.fromLTWH(0, 0, size.width, 64),
    );

    graphics.drawString(
      payload.appName,
      _titleFont,
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(0, 12, size.width, 28),
    );

    graphics.drawString(
      'Relatório financeiro   •   Gerado em ${_formatDateTime(payload.generatedAt)}',
      _subtitleFont,
      brush: PdfSolidBrush(_border),
      bounds: Rect.fromLTWH(0, 40, size.width, 16),
    );

    return 64 + 24;
  }

  double _drawCashFlowSummary(PdfGraphics graphics, Size size, double y) {
    const cardHeight = 96.0;
    final net = payload.totalIncome - payload.totalExpense;

    graphics.drawRectangle(
      pen: PdfPen(_border, width: .75),
      brush: PdfSolidBrush(_surface),
      bounds: Rect.fromLTWH(0, y, size.width, cardHeight),
    );

    graphics.drawString(
      'Resumo de fluxo de caixa',
      _sectionTitleFont,
      brush: PdfSolidBrush(_primary),
      bounds: Rect.fromLTWH(14, y + 10, size.width - 28, 18),
    );

    final colWidth = size.width / 3;
    _drawCashFlowColumn(
      graphics,
      x: 14,
      y: y + 38,
      width: colWidth - 14,
      label: 'SALDO ATUAL',
      value: AppCurrency.format(payload.currentBalance),
      valueColor: _primary,
    );
    _drawCashFlowColumn(
      graphics,
      x: colWidth,
      y: y + 38,
      width: colWidth,
      label: 'RECEITAS',
      value: AppCurrency.format(payload.totalIncome, sign: '+ '),
      valueColor: _success,
    );
    _drawCashFlowColumn(
      graphics,
      x: colWidth * 2,
      y: y + 38,
      width: colWidth - 14,
      label: 'DESPESAS',
      value: AppCurrency.format(payload.totalExpense, sign: '- '),
      valueColor: _error,
    );

    graphics.drawString(
      'Fluxo líquido do período: '
      '${AppCurrency.format(net, sign: net >= 0 ? '+ ' : '- ')}',
      _boldBodyFont,
      brush: PdfSolidBrush(net >= 0 ? _success : _error),
      bounds: Rect.fromLTWH(14, y + cardHeight - 22, size.width - 28, 14),
    );

    return y + cardHeight + 24;
  }

  void _drawCashFlowColumn(
    PdfGraphics graphics, {
    required double x,
    required double y,
    required double width,
    required String label,
    required String value,
    required PdfColor valueColor,
  }) {
    graphics.drawString(
      label,
      _labelFont,
      brush: PdfSolidBrush(_textSecondary),
      bounds: Rect.fromLTWH(x, y, width, 12),
    );
    graphics.drawString(
      value,
      _valueFont,
      brush: PdfSolidBrush(valueColor),
      bounds: Rect.fromLTWH(x, y + 14, width, 22),
    );
  }

  // ---------------------------------------------------------------------
  // Despesas por categoria (gráfico circular + legenda)
  // ---------------------------------------------------------------------

  double _drawCategoryBreakdown(
    PdfGraphics graphics,
    Size size,
    double y,
    List<PdfCategoryTotal> categories,
  ) {
    graphics.drawString(
      'Despesas por categoria',
      _sectionTitleFont,
      brush: PdfSolidBrush(_primary),
      bounds: Rect.fromLTWH(0, y, size.width, 18),
    );
    y += 22;

    if (categories.isEmpty) {
      graphics.drawString(
        'Ainda não existem despesas suficientes para gerar este gráfico.',
        _bodyFont,
        brush: PdfSolidBrush(_textSecondary),
        bounds: Rect.fromLTWH(0, y, size.width, 16),
      );
      return y + 30;
    }

    final total = categories.fold<double>(0, (sum, item) => sum + item.total);

    const pieSize = 130.0;
    final pieY = y;
    var startAngle = -90.0;

    for (var i = 0; i < categories.length; i++) {
      final item = categories[i];
      final sweep = total <= 0 ? 0.0 : (item.total / total) * 360;
      graphics.drawPie(
        Rect.fromLTWH(0, pieY, pieSize, pieSize),
        startAngle,
        sweep <= 0 ? 0.01 : sweep,
        pen: PdfPen(_white, width: 1.5),
        brush: PdfSolidBrush(_palette(i)),
      );
      startAngle += sweep;
    }

    final legendX = pieSize + 28;
    final legendWidth = size.width - legendX;

    for (var i = 0; i < categories.length; i++) {
      final item = categories[i];
      final legendY = pieY + (i * 20);

      graphics.drawRectangle(
        brush: PdfSolidBrush(_palette(i)),
        bounds: Rect.fromLTWH(legendX, legendY + 2, 10, 10),
      );
      graphics.drawString(
        item.category,
        _bodyFont,
        brush: PdfSolidBrush(_primary),
        bounds: Rect.fromLTWH(legendX + 16, legendY, legendWidth - 120, 14),
      );
      graphics.drawString(
        '${AppCurrency.format(item.total)} (${_percent(item.total, total)})',
        _bodyFont,
        brush: PdfSolidBrush(_textSecondary),
        bounds: Rect.fromLTWH(size.width - 110, legendY, 110, 14),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
    }

    final blockHeight = max(pieSize, categories.length * 20.0);
    y = pieY + blockHeight + 14;

    graphics.drawString(
      'Categoria com maior gasto: ${payload.topExpenseCategory}',
      _boldBodyFont,
      brush: PdfSolidBrush(_primary),
      bounds: Rect.fromLTWH(0, y, size.width, 16),
    );

    return y + 30;
  }

  // ---------------------------------------------------------------------
  // Distribuição do fluxo (Receitas -> Categorias)
  // ---------------------------------------------------------------------

  double _drawFlowDiagram(
    PdfGraphics graphics,
    Size size,
    double y,
    List<PdfCategoryTotal> categories,
  ) {
    graphics.drawString(
      'Distribuição do fluxo financeiro',
      _sectionTitleFont,
      brush: PdfSolidBrush(_primary),
      bounds: Rect.fromLTWH(0, y, size.width, 18),
    );
    y += 24;

    if (categories.isEmpty) {
      graphics.drawString(
        'Sem dados suficientes para este gráfico.',
        _bodyFont,
        brush: PdfSolidBrush(_textSecondary),
        bounds: Rect.fromLTWH(0, y, size.width, 16),
      );
      return y + 30;
    }

    const height = 150.0;
    final sourceRect = Rect.fromLTWH(0, y + height / 2 - 22, 90, 44);

    graphics.drawRectangle(
      brush: PdfSolidBrush(_secondary),
      bounds: sourceRect,
    );
    graphics.drawString(
      'Receitas',
      _bodyFont,
      brush: PdfBrushes.white,
      bounds: sourceRect,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );

    final total = categories.fold<double>(0, (sum, item) => sum + item.total);
    final gap = height / categories.length;

    for (var i = 0; i < categories.length; i++) {
      final item = categories[i];
      final targetY = y + (i * gap) + (gap / 2) - 10;
      final targetRect = Rect.fromLTWH(size.width - 150, targetY, 150, 20);
      final color = _palette(i);

      final thickness = total <= 0
          ? 1.0
          : max(1.0, min(10.0, (item.total / total) * 24));

      graphics.drawLine(
        PdfPen(color, width: thickness),
        Offset(sourceRect.right, sourceRect.top + sourceRect.height / 2),
        Offset(targetRect.left, targetRect.top + targetRect.height / 2),
      );

      graphics.drawRectangle(brush: PdfSolidBrush(color), bounds: targetRect);
      graphics.drawString(
        item.category,
        _bodyFont,
        brush: PdfBrushes.white,
        bounds: targetRect,
        format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle,
        ),
      );
    }

    return y + height + 20;
  }

  // ---------------------------------------------------------------------
  // Próximos eventos do calendário (tabela com paginação automática)
  // ---------------------------------------------------------------------

  void _drawUpcomingEvents(PdfPage page, Size size, double y) {
    page.graphics.drawString(
      'Próximos eventos do calendário',
      _sectionTitleFont,
      brush: PdfSolidBrush(_primary),
      bounds: Rect.fromLTWH(0, y, size.width, 18),
    );
    y += 24;

    final grid = _buildEventsGrid(payload.upcomingEvents);
    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, y, size.width, size.height - y),
      // A classe de layout partilhada por todos os elementos do Syncfusion
      // PDF é `PdfLayoutFormat` — não existe uma `PdfGridLayoutFormat`.
      format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
    );
  }

  PdfGrid _buildEventsGrid(List<PdfUpcomingEventData> events) {
    final grid = PdfGrid();
    grid.columns.add(count: 4);

    final header = grid.headers.add(1)[0];
    header.cells[0].value = 'Evento';
    header.cells[1].value = 'Tipo';
    header.cells[2].value = 'Data';
    header.cells[3].value = 'Valor';
    header.style.font = PdfStandardFont(
      PdfFontFamily.helvetica,
      9.5,
      style: PdfFontStyle.bold,
    );
    header.style.backgroundBrush = PdfSolidBrush(_primary);
    header.style.textBrush = PdfBrushes.white;

    if (events.isEmpty) {
      final row = grid.rows.add();
      row.cells[0].value = 'Sem eventos futuros agendados';
      row.cells[1].value = '-';
      row.cells[2].value = '-';
      row.cells[3].value = '-';
    } else {
      for (var i = 0; i < events.length; i++) {
        final event = events[i];
        final isIncome = event.type == 'receita';

        final row = grid.rows.add();
        row.cells[0].value = event.name.isEmpty ? 'Sem nome' : event.name;
        row.cells[1].value = isIncome ? 'Receita' : 'Despesa';
        row.cells[2].value = _formatDate(event.date);
        row.cells[3].value = AppCurrency.format(
          event.price,
          sign: isIncome ? '+ ' : '- ',
        );

        row.style.backgroundBrush = PdfSolidBrush(
          i.isEven ? _white : _surface,
        );
        row.cells[1].style.textBrush = PdfSolidBrush(
          isIncome ? _success : _error,
        );
        row.cells[3].style.textBrush = PdfSolidBrush(
          isIncome ? _success : _error,
        );
      }
    }

    grid.style.cellPadding = PdfPaddings(left: 8, top: 6, right: 8, bottom: 6);
    grid.style.font = _bodyFont;

    return grid;
  }

  // ---------------------------------------------------------------------
  // Auxiliares
  // ---------------------------------------------------------------------

  List<PdfCategoryTotal> _collapseCategories(
    List<PdfCategoryTotal> categories, {
    required int maxSlices,
  }) {
    if (categories.length <= maxSlices) return categories;

    final visible = categories.take(maxSlices - 1).toList();
    final othersTotal = categories
        .skip(maxSlices - 1)
        .fold<double>(0, (sum, item) => sum + item.total);

    return [
      ...visible,
      PdfCategoryTotal(category: 'Outras', total: othersTotal),
    ];
  }

  PdfColor _palette(int index) {
    final colors = [
      PdfColor(67, 56, 202), // indigo (AppColors.secondary)
      PdfColor(34, 197, 94), // verde
      PdfColor(245, 158, 11), // laranja
      PdfColor(239, 68, 68), // vermelho
      PdfColor(14, 165, 233), // azul
      PdfColor(168, 85, 247), // roxo
    ];
    return colors[index % colors.length];
  }

  String _percent(double value, double total) {
    if (total <= 0) return '0%';
    final result = (value / total) * 100;
    return '${result.toStringAsFixed(1)}%';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String _formatDateTime(DateTime date) {
    final datePart = _formatDate(date);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$datePart $hour:$minute';
  }
}

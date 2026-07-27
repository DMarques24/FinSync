import 'dart:io';
import 'dart:math';
import 'dart:ui';

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

    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final PdfGraphics graphics = page.graphics;
    final Size pageSize = page.getClientSize();

    final titleFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      18,
      style: PdfFontStyle.bold,
    );
    final subtitleFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final sectionTitleFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      12,
      style: PdfFontStyle.bold,
    );
    final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 10);

    var y = 20.0;

    graphics.drawString(
      payload.appName,
      titleFont,
      bounds: Rect.fromLTWH(0, y, pageSize.width, 24),
    );
    y += 26;

    graphics.drawString(
      'Gerado em: ${_formatDateTime(payload.generatedAt)}',
      subtitleFont,
      bounds: Rect.fromLTWH(0, y, pageSize.width, 16),
    );
    y += 26;

    _drawSummaryCard(
      graphics: graphics,
      y: y,
      width: pageSize.width,
      bodyFont: bodyFont,
      sectionTitleFont: sectionTitleFont,
      payload: payload,
    );
    y += 108;

    graphics.drawString(
      'Grafico circular por categorias',
      sectionTitleFont,
      bounds: Rect.fromLTWH(0, y, pageSize.width, 18),
    );
    y += 20;

    _drawPieChart(
      graphics: graphics,
      pieByCategory: payload.pieByCategory,
      x: 10,
      y: y,
      size: 150,
      bodyFont: bodyFont,
    );

    graphics.drawString(
      'Grafico Sankey (Receitas -> Categorias)',
      sectionTitleFont,
      bounds: Rect.fromLTWH(210, y, pageSize.width - 210, 18),
    );
    _drawSankey(
      graphics: graphics,
      links: payload.sankeyLinks,
      x: 210,
      y: y + 22,
      width: pageSize.width - 220,
      height: 160,
      bodyFont: bodyFont,
    );

    y += 190;

    graphics.drawString(
      'Proximos eventos do calendario',
      sectionTitleFont,
      bounds: Rect.fromLTWH(0, y, pageSize.width, 18),
    );
    y += 22;

    final eventsGrid = _buildEventsGrid(payload.upcomingEvents, bodyFont);
    eventsGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, y, pageSize.width, pageSize.height - y),
    );

    final bytes = await document.save();
    document.dispose();

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/analytics_report_$timestamp.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  void _drawSummaryCard({
    required PdfGraphics graphics,
    required double y,
    required double width,
    required PdfFont sectionTitleFont,
    required PdfFont bodyFont,
    required PdfAnalyticsPayload payload,
  }) {
    graphics.drawRectangle(
      bounds: Rect.fromLTWH(0, y, width, 96),
      pen: PdfPen(PdfColor(200, 200, 200)),
    );

    graphics.drawString(
      'Resumo financeiro',
      sectionTitleFont,
      bounds: Rect.fromLTWH(10, y + 8, width - 20, 18),
    );

    final left = 10.0;
    final right = width / 2;
    final line1 = y + 30;
    final line2 = y + 48;
    final line3 = y + 66;

    graphics.drawString(
      'Saldo atual: ${_formatMoney(payload.currentBalance)}',
      bodyFont,
      bounds: Rect.fromLTWH(left, line1, width / 2 - 20, 14),
    );
    graphics.drawString(
      'Total receitas: ${_formatMoney(payload.totalIncome)}',
      bodyFont,
      bounds: Rect.fromLTWH(left, line2, width / 2 - 20, 14),
    );
    graphics.drawString(
      'Total despesas: ${_formatMoney(payload.totalExpense)}',
      bodyFont,
      bounds: Rect.fromLTWH(left, line3, width / 2 - 20, 14),
    );
    graphics.drawString(
      'Categoria de maior gasto:',
      bodyFont,
      bounds: Rect.fromLTWH(right, line1, width / 2 - 20, 14),
    );
    graphics.drawString(
      payload.topExpenseCategory,
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(right, line2, width / 2 - 20, 14),
    );
  }

  void _drawPieChart({
    required PdfGraphics graphics,
    required List<PdfCategoryTotal> pieByCategory,
    required double x,
    required double y,
    required double size,
    required PdfFont bodyFont,
  }) {
    if (pieByCategory.isEmpty) {
      graphics.drawString(
        'Sem dados de despesas por categoria.',
        bodyFont,
        bounds: Rect.fromLTWH(x, y + size / 2 - 8, size + 150, 16),
      );
      return;
    }

    final total = pieByCategory.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );
    var startAngle = -90.0;

    for (var i = 0; i < pieByCategory.length; i++) {
      final item = pieByCategory[i];
      final sweep = total <= 0 ? 0.0 : (item.total / total) * 360;
      final color = _palette(i);

      graphics.drawPie(
        Rect.fromLTWH(x, y, size, size),
        startAngle,
        sweep,
        pen: PdfPen(PdfColor(255, 255, 255), width: 1),
        brush: PdfSolidBrush(color),
      );

      final legendY = y + 2 + (i * 16);
      graphics.drawRectangle(
        bounds: Rect.fromLTWH(x + size + 12, legendY, 10, 10),
        brush: PdfSolidBrush(color),
      );
      graphics.drawString(
        '${item.category} (${_percent(item.total, total)})',
        bodyFont,
        bounds: Rect.fromLTWH(x + size + 26, legendY - 1, 170, 12),
      );

      startAngle += sweep;
    }
  }

  void _drawSankey({
    required PdfGraphics graphics,
    required List<PdfSankeyLinkData> links,
    required double x,
    required double y,
    required double width,
    required double height,
    required PdfFont bodyFont,
  }) {
    final sourceRect = Rect.fromLTWH(x, y + 50, 70, 50);
    graphics.drawRectangle(
      bounds: sourceRect,
      brush: PdfSolidBrush(PdfColor(47, 128, 237)),
    );
    graphics.drawString(
      'Receitas',
      bodyFont,
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(sourceRect.left + 8, sourceRect.top + 18, 56, 12),
    );

    if (links.isEmpty) {
      graphics.drawString(
        'Sem dados para Sankey.',
        bodyFont,
        bounds: Rect.fromLTWH(x + 90, y + 68, width - 90, 14),
      );
      return;
    }

    final top = y + 12;
    final gap = max(8.0, (height - 20) / (links.length * 1.5));

    for (var i = 0; i < links.length; i++) {
      final link = links[i];
      final nodeY = top + (i * gap * 1.5);
      final targetRect = Rect.fromLTWH(x + width - 95, nodeY, 85, 16);
      final color = _palette(i);

      graphics.drawRectangle(bounds: targetRect, brush: PdfSolidBrush(color));
      graphics.drawString(
        link.target,
        bodyFont,
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(targetRect.left + 4, targetRect.top + 3, 75, 10),
      );

      final thickness = max(1.5, min(8.0, link.value / 120)).toDouble();
      graphics.drawLine(
        PdfPen(color, width: thickness),
        Offset(sourceRect.right, sourceRect.top + sourceRect.height / 2),
        Offset(targetRect.left, targetRect.top + targetRect.height / 2),
      );
    }
  }

  PdfGrid _buildEventsGrid(
    List<PdfUpcomingEventData> events,
    PdfFont bodyFont,
  ) {
    final grid = PdfGrid();
    grid.columns.add(count: 4);
    final header = grid.headers.add(1)[0];
    header.cells[0].value = 'Evento';
    header.cells[1].value = 'Tipo';
    header.cells[2].value = 'Data';
    header.cells[3].value = 'Valor';
    header.style.font = PdfStandardFont(
      PdfFontFamily.helvetica,
      10,
      style: PdfFontStyle.bold,
    );

    if (events.isEmpty) {
      final row = grid.rows.add();
      row.cells[0].value = 'Sem eventos futuros';
      row.cells[1].value = '-';
      row.cells[2].value = '-';
      row.cells[3].value = '-';
    } else {
      for (final event in events) {
        final row = grid.rows.add();
        row.cells[0].value = event.name;
        row.cells[1].value = event.type;
        row.cells[2].value = _formatDate(event.date);
        row.cells[3].value = _formatMoney(event.price);
      }
    }

    grid.style.cellPadding = PdfPaddings(left: 6, top: 4, right: 6, bottom: 4);
    for (var i = 0; i < grid.rows.count; i++) {
      grid.rows[i].style.font = bodyFont;
    }
    return grid;
  }

  PdfColor _palette(int index) {
    final colors = [
      PdfColor(52, 152, 219),
      PdfColor(46, 204, 113),
      PdfColor(241, 196, 15),
      PdfColor(231, 76, 60),
      PdfColor(155, 89, 182),
      PdfColor(26, 188, 156),
      PdfColor(230, 126, 34),
    ];
    return colors[index % colors.length];
  }

  String _percent(double value, double total) {
    if (total <= 0) return '0%';
    final result = (value / total) * 100;
    return '${result.toStringAsFixed(1)}%';
  }

  String _formatMoney(double value) {
    return '${value.toStringAsFixed(2)} EUR';
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

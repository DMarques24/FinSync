import 'package:finsync/data/models/pdf_category_total_model.dart';

abstract class PdfRemoteDatasource {
  Future<PdfAnalyticsPayload> fetchAnalyticsPayload({
    DateTime? referenceDate,
    int upcomingEventsLimit = 10,
    String appName = 'FinSync',
  });

  Future<PdfAnalyticsPayload> getDataPayload();
}

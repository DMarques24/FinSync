abstract class PdfRepository {
  Future<String> createAnalyticsPdf({
    DateTime? referenceDate,
    int upcomingEventsLimit = 10,
    String appName = 'FinSync',
  });
}

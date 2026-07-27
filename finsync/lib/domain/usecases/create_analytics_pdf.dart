import 'package:finsync/domain/repositories/pdf_repository.dart';

class CreateAnalyticsPdf {
  final PdfRepository repository;

  CreateAnalyticsPdf(this.repository);

  Future<String> call({
    DateTime? referenceDate,
    int upcomingEventsLimit = 10,
    String appName = 'FinSync',
  }) {
    return repository.createAnalyticsPdf(
      referenceDate: referenceDate,
      upcomingEventsLimit: upcomingEventsLimit,
      appName: appName,
    );
  }
}

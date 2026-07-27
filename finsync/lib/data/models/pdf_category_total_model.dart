class PdfCategoryTotal {
  final String category;
  final double total;

  const PdfCategoryTotal({required this.category, required this.total});
}

class PdfSankeyLinkData {
  final String source;
  final String target;
  final double value;

  const PdfSankeyLinkData({
    required this.source,
    required this.target,
    required this.value,
  });
}

class PdfUpcomingEventData {
  final String name;
  final double price;
  final DateTime date;
  final String type;

  const PdfUpcomingEventData({
    required this.name,
    required this.price,
    required this.date,
    required this.type,
  });
}

class PdfAnalyticsPayload {
  final String appName;
  final DateTime generatedAt;
  final double currentBalance;
  final double totalIncome;
  final double totalExpense;
  final String topExpenseCategory;
  final List<PdfCategoryTotal> pieByCategory;
  final List<PdfSankeyLinkData> sankeyLinks;
  final List<PdfUpcomingEventData> upcomingEvents;

  const PdfAnalyticsPayload({
    required this.appName,
    required this.generatedAt,
    required this.currentBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.topExpenseCategory,
    required this.pieByCategory,
    required this.sankeyLinks,
    required this.upcomingEvents,
  });
}

enum AppLocaleType {
  pt(code: 'pt', label: 'Português', flag: '🇵🇹'),
  en(code: 'en', label: 'English', flag: '🇬🇧');

  final String code;
  final String label;
  final String flag;

  const AppLocaleType({
    required this.code,
    required this.label,
    required this.flag,
  });
}

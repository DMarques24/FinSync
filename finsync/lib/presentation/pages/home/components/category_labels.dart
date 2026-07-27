import 'package:finsync/core/i18n/app_translations.dart';

String categoryLabel(String rawCategory) {
  const keysByCategory = {
    'Alimentação': 'home.category_food',
    'Transportes': 'home.category_transport',
    'Compras': 'home.category_shopping',
    'Subscrições': 'home.category_subscriptions',
    'Saúde': 'home.category_health',
    'Lazer': 'home.category_leisure',
  };

  final key = keysByCategory[rawCategory];
  return key == null ? rawCategory : tr(key);
}

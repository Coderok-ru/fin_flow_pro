class AppConstants {
  // Названия категорий расходов
  static const List<String> expenseCategories = [
    'Кредиты',
    'Транспорт',
    'Семья',
    'Жилье',
    'Дом',
    'Кредитные карты',
    'Подписки',
    'Медицина',
    'Образование',
    'Дети',
  ];

  // Периодичность платежей
  static const List<String> frequencyOptions = [
    'Еженедельно',
    'Раз в две недели',
    'Ежемесячно',
    'Раз в два месяца',
    'Раз в три месяца',
    'Раз в полгода',
    'Ежегодно',
    'Разово',
  ];

  // Список российских банков
  static const List<String> russianBanks = [
    'Сбербанк',
    'ВТБ',
    'Газпромбанк',
    'Альфа-Банк',
    'Россельхозбанк',
    'Открытие',
    'Тинькофф Банк',
    'Совкомбанк',
    'Райффайзенбанк',
    'Росбанк',
    'Почта Банк',
    'Московский Кредитный Банк',
    'Промсвязьбанк',
    'Банк Санкт-Петербург',
    'ЮниКредит Банк',
    'Другой',
  ];

  // Ключи для хранения данных
  static const String incomeStorageKey = 'incomes';
  static const String expenseStorageKey = 'expenses';
  static const String settingsStorageKey = 'settings';
  
  // Ключи для хранения темы
  static const String themeKey = 'theme_mode';
  
  // Форматы дат
  static const String dateFormat = 'dd.MM.yyyy';
  static const String monthFormat = 'MMMM yyyy';
  static const String shortDateFormat = 'dd MMM';
}
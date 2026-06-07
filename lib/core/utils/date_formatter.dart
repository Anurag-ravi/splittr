abstract final class DateFormatter {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Returns e.g. "5 Jan"
  static String shortDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]}';

  /// Returns the abbreviated month name, e.g. "Jan"
  static String monthAbbr(DateTime date) => _months[date.month - 1];

  /// Returns e.g. "Jan 2024"
  static String monthYear(DateTime date) =>
      '${_months[date.month - 1]} ${date.year}';
}

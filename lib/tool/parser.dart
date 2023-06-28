abstract class DateTimeParser {
  static String parseDuration(Duration duration) =>
      '$duration'.replaceAll(RegExp(r'\.\d+$'), '');
}

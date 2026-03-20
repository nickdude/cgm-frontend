class DateTimeUtils {
  static String parseDisplayTimeToIso(String value) {
    final parts = value.trim().split(' ');
    if (parts.length != 2) {
      return DateTime.now().toIso8601String();
    }

    final dateParts = parts[0].split('-');
    final timeParts = parts[1].split(':');

    if (dateParts.length != 2 || timeParts.length != 2) {
      return DateTime.now().toIso8601String();
    }

    final day = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);

    if (day == null || month == null || hour == null || minute == null) {
      return DateTime.now().toIso8601String();
    }

    final now = DateTime.now();
    final dt = DateTime(now.year, month, day, hour, minute);
    return dt.toIso8601String();
  }
}

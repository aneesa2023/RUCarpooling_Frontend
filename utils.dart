import 'package:intl/intl.dart';

class Utils {
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty || dateString == "N/A") {
      return "Unknown";
    }
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat("MMM dd, yyyy - hh:mm a").format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }
}

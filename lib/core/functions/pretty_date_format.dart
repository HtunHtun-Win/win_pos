import 'package:intl/intl.dart';

String prettyDate(String datetime) {
  DateTime date = DateTime.parse(datetime);
  var format = DateFormat("yyyy-MM-dd h:m a");
  var finalDate = format.format(date);
  return finalDate;
}

Map daterangeCalculate(String selectedDate) {
  String startDate = "";
  String endDate = "";
  var now = DateTime.now();
  var today = DateTime(now.year, now.month, now.day);
  if (selectedDate == "today") {
    startDate = today.toString();
    endDate = DateTime(now.year, now.month, now.day + 1).toString();
  } else if (selectedDate == "yesterday") {
    startDate = DateTime(now.year, now.month, now.day - 1).toString();
    endDate = DateTime(now.year, now.month, now.day).toString();
  } else if (selectedDate == "thismonth") {
    startDate = DateTime(now.year, now.month, 1).toString();
    endDate = DateTime(now.year, now.month, now.day + 1).toString();
  } else if (selectedDate == "lastmonth") {
    startDate = DateTime(now.year, now.month - 1, 1).toString();
    endDate = DateTime(now.year, now.month, 1).toString();
  } else if (selectedDate == "thisyear") {
    startDate = DateTime(now.year, 1, 1).toString();
    endDate = DateTime(now.year, now.month, now.day + 1).toString();
  } else if (selectedDate == "lastyear") {
    startDate = DateTime(now.year - 1, 1, 1).toString();
    endDate = DateTime(now.year, 1, 1).toString();
  }
  return {'start': startDate, 'end': endDate};
}
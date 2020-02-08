import 'package:flutter/material.dart';

mixin MedicineDataDecoder {
  static TimeOfDay getTimeFromMap(Map<String, dynamic> timeMap) {
    return TimeOfDay(hour: timeMap['hour'], minute: timeMap['minute']);
  }

  static List<DateTime> getDatesFromListOfMaps(List<dynamic> datesStringList) {
    return datesStringList
        .map((dateMap) => MedicineDataDecoder.getDateFromMap(dateMap))
        .toList();
  }

  static DateTime getDateFromMap(Map<String, dynamic> dateMap) {
    return DateTime(
      dateMap['year'],
      dateMap['month'],
      dateMap['day'],
      dateMap['hour'],
      dateMap['minute'],
      0,
      0,
    );
  }
}

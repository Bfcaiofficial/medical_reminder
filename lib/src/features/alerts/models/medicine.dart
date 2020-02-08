import 'package:flutter/material.dart';

import './../mixins/medicine_data_decoder.dart';

class Medicine {
  String id;
  String idOnServer;
  String name;
  DateTime startDate;
  int progress;
  int periodPerDays;
  int period;
  TimeOfDay time;
  String notes;
  List<DateTime> dates;

  Medicine({
    this.id,
    this.name,
    this.startDate,
    this.progress,
    this.periodPerDays,
    this.period,
    this.time,
    this.notes,
    this.dates,
  });

  Medicine.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'],
        name = parsedJson['name'],
        startDate = MedicineDataDecoder.getDateFromMap(parsedJson['startDate']),
        progress = parsedJson['progress'],
        periodPerDays = parsedJson['periodPerDays'],
        period = parsedJson['period'],
        time = MedicineDataDecoder.getTimeFromMap(parsedJson['time']),
        notes = parsedJson['notes'],
        dates = MedicineDataDecoder.getDatesFromListOfMaps(parsedJson['dates']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startDate': {
        'year': startDate.year,
        'month': startDate.month,
        'day': startDate.day,
        'hour': startDate.hour,
        'minute': startDate.minute
      },
      'progress': progress,
      'periodPerDays': periodPerDays,
      'period': period,
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
      'notes': notes,
      'dates': dates
          .map((date) => {
                'year': date.year,
                'month': date.month,
                'day': date.day,
                'hour': date.hour,
                'minute': date.minute
              })
          .toList(),
    };
  }
}

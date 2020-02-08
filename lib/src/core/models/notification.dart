import 'package:flutter/foundation.dart';

import './../../features/alerts/screens/edit_screen.dart';

class AppNotification {
  final String id;
  String idOnServer;
  final String title;
  final String description;
  final bool isHandled;
  final EventType eventType;
  final DateTime date;

  AppNotification({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.isHandled,
    @required this.date,
    @required this.eventType,
  });

  AppNotification.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'],
        title = parsedJson['title'],
        description = parsedJson['description'],
        isHandled = parsedJson['isHandled'],
        eventType = parsedJson['eventType'] == 0
            ? EventType.medicine
            : EventType.booking,
        date = DateTime(
          parsedJson['date']['year'],
          parsedJson['date']['month'],
          parsedJson['date']['day'],
          parsedJson['date']['hour'],
          parsedJson['date']['minute'],
        );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isHandled': isHandled,
      'eventType': eventType.index,
      'date': {
        'year': date.year,
        'month': date.month,
        'day': date.day,
        'hour': date.hour,
        'minute': date.minute,
      }
    };
  }
}

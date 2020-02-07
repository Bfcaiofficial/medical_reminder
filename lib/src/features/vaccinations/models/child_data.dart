import 'package:flutter/foundation.dart';

class ChildData {
  final String id;
  String idOnServer;
  final String name;
  final DateTime birthdate;
  final String gender;
  int progress;

  ChildData({
    @required this.birthdate,
    @required this.gender,
    @required this.id,
    @required this.name,
    @required this.progress,
  });

  ChildData.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'],
        name = parsedJson['name'],
        gender = parsedJson['gender'],
        birthdate = DateTime(
          parsedJson['birthdate']['year'],
          parsedJson['birthdate']['month'],
          parsedJson['birthdate']['day'],
        ),
        progress = parsedJson['progress'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'birthdate': {
        'year': birthdate.year,
        'month': birthdate.month,
        'day': birthdate.day,
      },
      'progress': progress,
    };
  }
}

List<String> get arrangedVaccinationsTitles {
  return [
    'شلل الاطفال',
    'الدفتريا',
    'السعال الديكى',
    'التيتانوس',
    'الالتهاب الكبدى الوبائى B',
    'شلل الاطفال',
    'الدفتريا',
    'السعال الديكى',
    'التيتانوس',
    'الالتهاب الكبدى الوبائى B',
    'شلل الاطفال',
    'الدفتريا',
    'السعال الديكى',
    'التيتانوس',
    'الالتهاب الكبدى الوبائى B',
    'شلل الاطفال',
    'الحصبة',
    'التهاب النكاف',
    'الحصبة الالمانية',
    'شلل الاطفال',
    'الدفتريا',
    'السعال الديكى',
    'التيتانوس',
    'شلل الاطفال',
    'الدفتريا',
    'السعال الديكى',
    'التيتانوس',
  ];
}

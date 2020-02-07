import 'package:flutter/foundation.dart';

class Vaccination {
  final int id;
  final String name;
  final String describtion;

  Vaccination({
    @required this.id,
    @required this.name,
    @required this.describtion,
  });

  Vaccination.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'],
        name = parsedJson['name'],
        describtion = parsedJson['describtion'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'describtion': describtion,
    };
  }
}

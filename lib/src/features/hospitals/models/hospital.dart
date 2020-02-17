import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class Hospital {
  final String id;
  final String name;
  final String cityId;
  final String address;
  final String phoneNumber;
  final bool hasRaysCenter;
  final bool hasSurgeryCenter;
  final Position location;
  final List<String> departments;
  final List<String> raysAndAnalysis;
  final List<String> surgeries;

  Hospital({
    @required this.id,
    @required this.name,
    @required this.cityId,
    @required this.address,
    @required this.phoneNumber,
    @required this.hasRaysCenter,
    @required this.hasSurgeryCenter,
    @required this.location,
    @required this.departments,
    @required this.raysAndAnalysis,
    @required this.surgeries,
  });

  Hospital.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'],
        name = parsedJson['name'],
        cityId = parsedJson['cityId'],
        address = parsedJson['address'],
        phoneNumber = parsedJson['phone'],
        hasRaysCenter = parsedJson['hasRaysCenter'],
        hasSurgeryCenter = parsedJson['hasSurgeryCenter'],
        location = Position(
          latitude: parsedJson['location']['latitude'],
          longitude: parsedJson['location']['longitude'],
        ),
        departments =
            Hospital.getDepatmentsFromListOfMaps(parsedJson['departments']),
        raysAndAnalysis =
            Hospital.getDepatmentsFromListOfMaps(parsedJson['rays']),
        surgeries =
            Hospital.getDepatmentsFromListOfMaps(parsedJson['surgeries']);

  static List<String> getDepatmentsFromListOfMaps(
      List<dynamic> departmentsStringList) {
    if (departmentsStringList != null)
      return departmentsStringList
          .map((valueMap) => Hospital.getDeptNameFromMap(valueMap))
          .toList();
    else
      return null;
  }

  static String getDeptNameFromMap(Map<String, dynamic> departmentMap) {
    return departmentMap['name'];
  }
}

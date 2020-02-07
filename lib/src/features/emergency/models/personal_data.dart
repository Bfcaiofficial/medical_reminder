import 'package:flutter/foundation.dart';

class PersonalData {
  String id;
  final String name;
  final String bloodType;
  final String address;
  final String phoneNumber;
  final String previousDiagnosesAndNotes;
  final double shakeSensitivity;
  final isDeviceShakeFeatureEnabled;

  PersonalData({
    this.id,
    @required this.name,
    @required this.bloodType,
    @required this.address,
    @required this.phoneNumber,
    @required this.previousDiagnosesAndNotes,
    @required this.shakeSensitivity,
    @required this.isDeviceShakeFeatureEnabled,
  });

  PersonalData.fromJson(Map<String, dynamic> parsedJson)
      : name = parsedJson['name'],
        address = parsedJson['address'],
        bloodType = parsedJson['bloodType'],
        phoneNumber = parsedJson['phoneNumber'],
        previousDiagnosesAndNotes = parsedJson['notes'],
        shakeSensitivity = parsedJson['shakeSensitivity'],
        isDeviceShakeFeatureEnabled = parsedJson['deviceShakeEnabled'];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'bloodType': bloodType,
      'phoneNumber': phoneNumber,
      'notes': previousDiagnosesAndNotes,
      'shakeSensitivity': shakeSensitivity,
      'deviceShakeEnabled': isDeviceShakeFeatureEnabled,
    };
  }
}

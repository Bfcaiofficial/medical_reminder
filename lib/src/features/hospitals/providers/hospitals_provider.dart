import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './../models/hospital.dart';
import './../../../core/mixins/internet_connection_status_mixin.dart';

class HospitalsProvider with ChangeNotifier, InternetConnectionStatusMixin {
  List<Hospital> _hospitals = [];
  bool _isDataLoaded = false;
  String _accessToken = '';

  void setAccessToken(String token) {
    _accessToken = token;
  }

  Future<bool> refreshHospitalList() async {
    if (!await checkInternetConnection()) return false;
    String _apiUrl =
        'https://medical-reminder-3e48b.firebaseio.com/hospitals.json?auth=$_accessToken';
    final response = await http.get(_apiUrl);

    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return true;
    }
    final List<Hospital> loadedHospitals = [];
    extractedData.forEach((hospitalId, hospitalData) {
      final hospital = Hospital.fromJson(hospitalData);
      loadedHospitals.add(hospital);
    });

    _hospitals = loadedHospitals;
    setDataLoaded(true);

    notifyListeners();
    return true;
  }

  void clear() {
    _hospitals.clear();
  }

  void setDataLoaded(bool isLoaded) {
    _isDataLoaded = isLoaded;
  }

  bool get isDataLoaded => _isDataLoaded;
  List<Hospital> get hospitalList => [..._hospitals];
}

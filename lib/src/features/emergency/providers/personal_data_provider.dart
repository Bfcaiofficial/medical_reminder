import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import './../../../core/mixins/internet_connection_status_mixin.dart';
import './../models/personal_data.dart';

class PersonalDataProvider with ChangeNotifier, InternetConnectionStatusMixin {
  PersonalData _personalData;
  bool _loaded = false;
  String _accessToken = '';
  bool _isDeviceShakeFeatureEnabled = false;
  SharedPreferences _prefs;
  double _localSensitivity = 20.0;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  Future<String> _getId() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs
        .getString('email')
        .replaceFirst('@', '_')
        .replaceAll('.', '_');
  }

  void savePersonalData(PersonalData data) async {
    final appId = await _getId();
    String _apiUrl =
        'https://medical-reminder-3e48b.firebaseio.com/${appId}-info.json?auth=$_accessToken';

    print('Uploading Personal Data....');

    _personalData = data;
    final response = await http.post(_apiUrl, body: json.encode(data.toMap()));
    data.id = json.decode(response.body)['name'];

    print(_personalData);

    notifyListeners();
  }

  Future<bool> removePersonalData() async {
    if (!await checkInternetConnection()) return false;

    final appId = await _getId();
    final url =
        'https://medical-reminder-3e48b.firebaseio.com/${appId}-info/${_personalData.id}.json?auth=$_accessToken';

    print('Deleting Personal Data...');

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      _personalData = null;
      notifyListeners();
    }

    return true;
  }

  Future<void> updatePersonalData(PersonalData newPersonalData) async {
    final appId = await _getId();

    final url =
        'https://medical-reminder-3e48b.firebaseio.com/${appId}-info/${_personalData.id}.json?auth=$_accessToken';

    _personalData = newPersonalData;

    await http.patch(url, body: json.encode(newPersonalData.toMap()));

    notifyListeners();
  }

  Future<bool> getPersonalData() async {
    _personalData = null;
    if (!await checkInternetConnection()) return false;
    print('token: $_accessToken');
    final appId = await _getId();
    String _apiUrl =
        'https://medical-reminder-3e48b.firebaseio.com/${appId}-info.json?auth=$_accessToken';
    final response = await http.get(_apiUrl);

    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return true;
    }

    extractedData.forEach((personalDataId, personalDataMap) {
      _personalData = PersonalData.fromJson(personalDataMap);
      _personalData.id = personalDataId;
    });

    print(_personalData.toMap());

    _loaded = true;
    notifyListeners();
    return true;
  }

  void setDataLoaded(isLoaded) {
    _loaded = isLoaded;
  }

  void enableDeviceShakeFeature(isEnabled) {
    _isDeviceShakeFeatureEnabled = isEnabled;
    _setIsDeviceShakeEnabledLocaly(isEnabled);
    notifyListeners();
    print('is device shake enabld localy: $isEnabled');
  }

  void _setIsDeviceShakeEnabledLocaly(bool isEnabled) {
    _prefs.setBool('deviceShakeEnabled', isEnabled);
  }

  bool isDeviceShakeEnabledLocaly() {
    return _prefs.getBool('deviceShakeEnabled') ?? false;
  }

  double getLocallyStoredSensitivity() {
    return _prefs.getDouble('sensitivity') ?? 20.0;
  }

  void setLocalSensitivity(double sensitivity) {
    _prefs.setDouble('sensitivity', sensitivity);
    print('local sensitivity is $sensitivity');
  }

  PersonalData get personalData => _personalData;
  bool get isDeviceShakeFeatureEnabled => _isDeviceShakeFeatureEnabled;
  bool get isDataLoaded => _loaded;
}

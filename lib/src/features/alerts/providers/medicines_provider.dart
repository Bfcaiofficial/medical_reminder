import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import './../models/medicine.dart';
import './../../../core/mixins/internet_connection_status_mixin.dart';

class MedicinesProvider with ChangeNotifier, InternetConnectionStatusMixin {
  List<Medicine> _medicines = [];
  bool _loaded = false;
  bool _notificationClickHandled = false;
  String _accessToken = '';

  void setAccessToken(String token) {
    _accessToken = token;
  }

  Future<String> _getId() async {
    // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    // if (Platform.isIOS) {
    //   IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    //   return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    // } else {
    //   AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    //   return androidDeviceInfo.androidId; // unique ID on Android
    // }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email').replaceFirst('@', '_').replaceAll('.', '_');
  }

  void addMedicine(Medicine medicine) async {
    final appId = await _getId();
    String _apiUrl =
        'https://medical-reminder-3e48b.firebaseio.com/${appId}medicines.json?auth=$_accessToken';

    print('Uploading....');

    _medicines.add(medicine);
    final response =
        await http.post(_apiUrl, body: json.encode(medicine.toMap()));
    medicine.idOnServer = json.decode(response.body)['name'];

    print(_medicines.length);
    print(medicine.id);

    notifyListeners();
  }

  Future<bool> removeMedicine(String id) async {
    if (!await checkInternetConnection()) return false;

    final appId = await _getId();
    final url =
        'https://medical-reminder-3e48b.firebaseio.com/${appId}medicines/$id.json?auth=$_accessToken';
    final existingMedicineIndex =
        _medicines.indexWhere((medicine) => medicine.idOnServer == id);
    var existingMedicine = _medicines[existingMedicineIndex];
    _medicines.removeAt(existingMedicineIndex);
    print('Deleting...');
    print('Medicines: $_medicines');
    bool empty = false;
    if (_medicines.isEmpty) empty = true;

    final response = await http.delete(url);

    if (empty) _medicines.clear();
    print('Medicines: $_medicines');

    notifyListeners();

    if (response.statusCode >= 400) {
      _medicines.insert(existingMedicineIndex, existingMedicine);
      notifyListeners();
      throw HttpException('Could not delete medicine.');
    }
    _cancelScheduledNotificationsForMedicine(existingMedicine);
    existingMedicine = null;
    return true;
  }

  void _cancelScheduledNotificationsForMedicine(Medicine medicine) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();

    for (int i = 0; i < 2; i++) {
      if (i < medicine.dates.length) {
        var notificationIdText = medicine.dates[i].toString();
        notificationIdText =
            notificationIdText.replaceAll(RegExp(r"[^0-9]"), '');

        int notificationId =
            (double.parse(notificationIdText) % 2147483647).toInt();

        flutterLocalNotificationsPlugin.cancel(notificationId);
      }
    }
  }

  Future<void> updateMedicine(String id, Medicine newMedicine) async {
    final appId = await _getId();

    final medicineIndex =
        _medicines.indexWhere((medicine) => medicine.idOnServer == id);
    if (medicineIndex >= 0) {
      _medicines[medicineIndex] = newMedicine;
      final url =
          'https://medical-reminder-3e48b.firebaseio.com/${appId}medicines/$id.json?auth=$_accessToken';
      await http.patch(url, body: json.encode(newMedicine.toMap()));
      notifyListeners();
    } else {
      print('index is $medicineIndex');
    }
  }

  void removeOldMedicines(DateTime currentDate) async {
    for (Medicine medicine in _medicines) {
      medicine.dates.removeWhere((date) => date.isBefore(currentDate));
      updateMedicine(medicine.idOnServer, medicine);
    }
  }

  Future<bool> refreshMedicineList() async {
    _medicines = [];
    if (!await checkInternetConnection()) return false;

    final appId = await _getId();
    String _apiUrl =
        'https://medical-reminder-3e48b.firebaseio.com/${appId}medicines.json?auth=$_accessToken';
    final response = await http.get(_apiUrl);

    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return true;
    }
    final List<Medicine> loadedMedicines = [];
    extractedData.forEach((medicineId, medicineData) {
      final medicine = Medicine.fromJson(medicineData);
      medicine.idOnServer = medicineId;
      loadedMedicines.add(medicine);
    });

    _medicines = loadedMedicines;
    _scheduleMedicinesNotifications(_medicines);
    _loaded = true;
    notifyListeners();
    return true;
  }

  void _scheduleMedicinesNotifications(List<Medicine> medicines) {
    for (Medicine medicine in medicines) {
      _cancelScheduledNotificationsForMedicine(medicine);
      for (int i = 0; i < 2; i++) {
        if (i < medicine.dates.length &&
            medicine.dates[i].isAfter(DateTime.now())) {
          _scheduleNotificationByDate(medicine.dates[i], medicine);
        }
      }
    }
  }

  void _scheduleNotificationByDate(DateTime date, Medicine medicine) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (_, __, ___, ____) {});
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (_) {});

    var scheduledNotificationDateTime = date;
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      medicine.id,
      medicine.name,
      medicine.notes,
      sound: 'notification_sound',
      importance: Importance.Max,
      priority: Priority.High,
      autoCancel: true,
      groupKey: medicine.id,
      enableVibration: true,
    );

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails(
      sound: 'notification_sound.aiff',
    );

    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    var notificationIdText = date.toString();
    notificationIdText = notificationIdText.replaceAll(RegExp(r"[^0-9]"), '');

    int notificationId =
        (double.parse(notificationIdText) % 2147483647).toInt();

    print('Notification Id: $notificationId');

    flutterLocalNotificationsPlugin.schedule(
      notificationId,
      medicine.name,
      medicine.notes,
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      payload: medicine.id + '\$\$' + 'Medicine',
      androidAllowWhileIdle: true,
    );
  }

  void setNotificationClickHandled(bool isClickHandled) {
    _notificationClickHandled = isClickHandled;
  }

  void setDataLoaded(isLoaded) {
    _loaded = isLoaded;
  }

  List<Medicine> get medicineList => [..._medicines];
  bool get isActivitiesLoaded => _loaded;
  bool get isNotificationClickHandled => _notificationClickHandled;
}

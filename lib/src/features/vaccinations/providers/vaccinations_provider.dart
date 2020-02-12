import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:medical_reminder/src/features/vaccinations/models/child_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './../../../core/mixins/internet_connection_status_mixin.dart';
import './../models/vaccination.dart';

class VaccinationsProvider with ChangeNotifier, InternetConnectionStatusMixin {
  List<Vaccination> _vaccinations = [];
  List<ChildData> _children = [];
  bool _isVacinationsDataLoaded = false;
  bool _isChildrenDataLoaded = false;
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

  Future<bool> refreshVaccinationsList() async {
    if (!await checkInternetConnection()) return false;

    String _apiUrl =
        'https://medical-reminder-3e48b.firebaseio.com/Vaccinations.json?auth=$_accessToken';
    final response = await http.get(_apiUrl);

    print(response.body);

    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return true;
    }
    final List<Vaccination> loadedVaccinations = [];
    extractedData.forEach((vaccinationId, vaccinationData) {
      final vaccination = Vaccination.fromJson(vaccinationData);
      print('Vacination: ${vaccination.toMap()}');
      loadedVaccinations.add(vaccination);
    });

    _vaccinations = loadedVaccinations;
    setVaccinationsDataLoaded(true);

    notifyListeners();
    return true;
  }

  Future<bool> refreshChildrenList() async {
    if (!await checkInternetConnection()) return false;

    final appId = await _getId();

    String _apiUrl =
        'https://medical-reminder-3e48b.firebaseio.com/$appId-children.json?auth=$_accessToken';
    final response = await http.get(_apiUrl);

    print(response.body);

    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return true;
    }
    final List<ChildData> loadedChildren = [];
    extractedData.forEach((childId, child) {
      final childData = ChildData.fromJson(child);
      childData.idOnServer = childId;
      print('Child Data: ${childData.toMap()}');
      loadedChildren.add(childData);
    });

    _children = loadedChildren;
    _scheduleChildrenVaccinationsNotifications(_children);
    setChildrenDataLoaded(true);

    notifyListeners();
    return true;
  }

  void addChild(ChildData child) async {
    final appId = await _getId();

    String _apiUrl =
        'https://medical-reminder-3e48b.firebaseio.com/$appId-children.json?auth=$_accessToken';

    print('Uploading....');

    _children.add(child);
    final response = await http.post(_apiUrl, body: json.encode(child.toMap()));
    child.idOnServer = json.decode(response.body)['name'];

    _scheduleChildrenVaccinationsNotifications([child]);

    print(_children.length);
    print(child.id);

    notifyListeners();
  }

  Future<void> updateChildData(String id, ChildData newChildData) async {
    final appId = await _getId();

    final childIndex = _children.indexWhere((child) => child.idOnServer == id);
    if (childIndex >= 0) {
      _children[childIndex] = newChildData;
      print(newChildData);
      final url =
          'https://medical-reminder-3e48b.firebaseio.com/$appId-children/$id.json?auth=$_accessToken';
      await http.patch(url, body: json.encode(newChildData.toMap()));
      notifyListeners();
      _scheduleChildrenVaccinationsNotifications([newChildData]);
    } else {
      print('index is $childIndex');
    }
  }

  Future<bool> removeChild(String id) async {
    if (!await checkInternetConnection()) return false;

    final appId = await _getId();

    final url =
        'https://medical-reminder-3e48b.firebaseio.com/$appId-children/$id.json?auth=$_accessToken';

    final existingChildIndex =
        _children.indexWhere((child) => child.idOnServer == id);
    var existingChild = _children[existingChildIndex];
    _children.removeAt(existingChildIndex);
    print('Deleting...');
    print('Children: $_children');
    bool empty = false;
    if (_children.isEmpty) empty = true;

    final response = await http.delete(url);

    if (empty) _children.clear();
    print('Children: $_children');

    notifyListeners();

    _cancelScheduledNotificationsForChild(existingChild);

    if (response.statusCode >= 400) {
      _children.insert(existingChildIndex, existingChild);
      notifyListeners();
      throw HttpException('Could not delete medicine.');
    }

    existingChild = null;
    return true;
  }

  void _scheduleChildrenVaccinationsNotifications(List<ChildData> children) {
    for (ChildData child in children) {
      _cancelScheduledNotificationsForChild(child);

      final dateNow = DateTime.now();

      switch (child.progress) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
          {
            _scheduleNotificationsForPeriod(
              days: 30,
              dateNow: dateNow,
              child: child,
            );
            break;
          }
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
          {
            _scheduleNotificationsForPeriod(
              days: 60,
              dateNow: dateNow,
              child: child,
            );
            break;
          }
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
          {
            _scheduleNotificationsForPeriod(
              days: 90,
              dateNow: dateNow,
              child: child,
            );
            break;
          }
        case 15:
          {
            _scheduleNotificationsForPeriod(
              days: 120,
              dateNow: dateNow,
              child: child,
            );
            break;
          }
        case 16:
        case 17:
        case 18:
          {
            _scheduleNotificationsForPeriod(
              days: 150,
              dateNow: dateNow,
              child: child,
            );
            break;
          }
        case 19:
        case 20:
        case 21:
        case 22:
          {
            _scheduleNotificationsForPeriod(
              days: 180,
              dateNow: dateNow,
              child: child,
            );
            break;
          }
        case 23:
        case 24:
        case 25:
        case 26:
          {
            _scheduleNotificationsForPeriod(
              days: 210,
              dateNow: dateNow,
              child: child,
            );
            break;
          }
      }
    }
  }

  void _scheduleNotificationsForPeriod({
    int days,
    DateTime dateNow,
    ChildData child,
  }) {
    if (dateNow.difference(child.birthdate).inDays >= days) {
      _scheduleNotificationByDate(
        dateNow.add(Duration(seconds: 3)),
        child,
        'قم بالتأكد من اعطاءه التطعيمات لهذا الشهر.',
      );
    } else {
      _scheduleNotificationByDate(
        child.birthdate.add(Duration(days: days - 15, hours: 12, seconds: 5)),
        child,
        'قم بالتأكد من اعطاءه التطعيمات لهذا الشهر.',
      );
      _scheduleNotificationByDate(
        child.birthdate.add(Duration(days: days, hours: 12, seconds: 5)),
        child,
        'قم بالتأكد من اعطاءه التطعيمات لهذا الشهر.',
      );
    }
  }

  void _scheduleNotificationByDate(
    DateTime date,
    ChildData childData,
    String describtion,
  ) {
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
      childData.id,
      childData.name,
      describtion,
      sound: 'notification_sound',
      importance: Importance.Max,
      priority: Priority.High,
      autoCancel: true,
      groupKey: childData.id,
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
      childData.name + ' - ' + childData.gender,
      describtion,
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      payload: childData.id + '\$\$' + 'Child',
    );
  }

  void _cancelScheduledNotificationsForChild(ChildData child) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();

    for (int i = 15; i <= 210; i += 15) {
      var notificationIdText = child.birthdate
          .add(Duration(days: i, hours: 12, seconds: 5))
          .toString();
      notificationIdText = notificationIdText.replaceAll(RegExp(r"[^0-9]"), '');

      int notificationId =
          (double.parse(notificationIdText) % 2147483647).toInt();

      flutterLocalNotificationsPlugin.cancel(notificationId);
    }
  }

  void clear() {
    _children.clear();
  }

  void setVaccinationsDataLoaded(bool isLoaded) {
    _isVacinationsDataLoaded = isLoaded;
  }

  void setChildrenDataLoaded(bool isLoaded) {
    _isChildrenDataLoaded = isLoaded;
  }

  bool get isVaccinationsDataLoaded => _isVacinationsDataLoaded;
  bool get isChildrenDataLoaded => _isChildrenDataLoaded;
  List<Vaccination> get vaccinationList => [..._vaccinations];
  List<ChildData> get childrenList => [..._children];
}

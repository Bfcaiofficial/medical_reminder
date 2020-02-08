import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import './../models/notification.dart';
import './../mixins/internet_connection_status_mixin.dart';

class NotificationProvider with ChangeNotifier, InternetConnectionStatusMixin {
  List<AppNotification> _notifications = [];
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

  void addNotification(AppNotification notification) async {
    final appId = await _getId();
    String _apiUrl =
        'https://medical-reminder-3e48b.firebaseio.com/${appId}notifications.json?auth=$_accessToken';

    print('Uploading notification data....');

    _notifications.add(notification);
    final response =
        await http.post(_apiUrl, body: json.encode(notification.toMap()));
    notification.idOnServer = json.decode(response.body)['name'];

    print(_notifications.length);
    print(notification.id);

    notifyListeners();
  }

  Future<bool> removeNotification(String id) async {
    if (!await checkInternetConnection()) return false;

    final appId = await _getId();
    final url =
        'https://medical-reminder-3e48b.firebaseio.com/${appId}notifications/$id.json?auth=$_accessToken';
    final existingNotificationIndex = _notifications
        .indexWhere((notification) => notification.idOnServer == id);
    var existingNotification = _notifications[existingNotificationIndex];
    _notifications.removeAt(existingNotificationIndex);
    print('Deleting...');
    print('Notifications: $_notifications');
    bool empty = false;
    if (_notifications.isEmpty) empty = true;

    final response = await http.delete(url);

    if (empty) _notifications.clear();
    print('Notifications: $_notifications');

    notifyListeners();

    if (response.statusCode >= 400) {
      _notifications.insert(existingNotificationIndex, existingNotification);
      notifyListeners();
      //throw HttpException('Could not delete medicine.');
      return false;
    }
    existingNotification = null;
    return true;
  }

  Future<bool> refreshNotificationList() async {
    _notifications = [];
    if (!await checkInternetConnection()) return false;

    final appId = await _getId();
    String _apiUrl =
        'https://medical-reminder-3e48b.firebaseio.com/${appId}notifications.json?auth=$_accessToken';
    final response = await http.get(_apiUrl);

    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return true;
    }
    final List<AppNotification> loadedNotifications = [];
    extractedData.forEach((notificationId, notificationData) {
      final notification = AppNotification.fromJson(notificationData);
      notification.idOnServer = notificationId;
      loadedNotifications.add(notification);
    });

    _notifications = loadedNotifications;
    notifyListeners();
    return true;
  }

  List<AppNotification> getTodayNotifications() {
    _notifications.sort((a, b) {
      return a.date.compareTo(b.date);
    });
    return _notifications
        .where(
          (notification) =>
              notification.date.isBefore(DateTime.now()) &&
              !notification.isHandled,
        )
        .toList();
  }

  void removeNotificationsOf(String id) {
    final tempNotifications =
        _notifications.where((notification) => notification.id == id);
    for (AppNotification notification in tempNotifications) {
      removeNotification(notification.idOnServer);
    }
  }

  void clearNotificationsOfUser() {
    _notifications = [];
  }

  List<AppNotification> get notificationList => [..._notifications];
}

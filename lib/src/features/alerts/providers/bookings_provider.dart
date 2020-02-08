import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import './../../../core/mixins/internet_connection_status_mixin.dart';
import './../models/booking.dart';

class BookingsProvider with ChangeNotifier, InternetConnectionStatusMixin {
  List<Booking> _bookings = [];
  String _accessToken = '';
  SharedPreferences prefs;

  void setAccessToken(String token) async {
    _accessToken = token;

    prefs = await SharedPreferences.getInstance();
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
    return prefs.getString('email').replaceFirst('@', '_').replaceAll('.', '_');
  }

  Future<void> addNewAppointment(Booking booking) async {
    final appId = await _getId();
    String _apiUrl =
        'https://medical-reminder-3e48b.firebaseio.com/${appId}bookings.json?auth=$_accessToken';

    print('Uploading....');

    _bookings.add(booking);
    final response =
        await http.post(_apiUrl, body: json.encode(booking.toMap()));
    booking.idOnServer = json.decode(response.body)['name'];

    print(_bookings.length);
    print(booking.doctorName);
    notifyListeners();
  }

  Future<bool> removeBooking(String id) async {
    if (!await checkInternetConnection()) return false;

    final appId = await _getId();
    final url =
        'https://medical-reminder-3e48b.firebaseio.com/${appId}bookings/$id.json?auth=$_accessToken';
    final existingBookingIndex =
        _bookings.indexWhere((booking) => booking.idOnServer == id);
    var existingBooking = _bookings[existingBookingIndex];
    _bookings.removeAt(existingBookingIndex);

    print('Deleting...');
    print('Bookings: $_bookings');
    bool empty = false;
    if (_bookings.isEmpty) empty = true;

    final response = await http.delete(url);

    if (empty) _bookings.clear();
    print('Bookings: $_bookings');

    notifyListeners();
    if (response.statusCode >= 400) {
      _bookings.insert(existingBookingIndex, existingBooking);
      notifyListeners();
      //throw HttpException('Could not delete medicine.');
      return false;
    }

    _cancelNotificationForBooking(existingBooking);

    existingBooking = null;
    return true;
  }

  void _cancelNotificationForBooking(Booking booking) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();

    for (int i = 0; i < 2; i++) {
      var notificationIdText =
          booking.dateAndTime.add(Duration(seconds: 5)).toString();
      notificationIdText = notificationIdText.replaceAll(RegExp(r"[^0-9]"), '');

      int notificationId =
          (double.parse(notificationIdText) % 2147483647).toInt();

      flutterLocalNotificationsPlugin.cancel(notificationId);
    }
  }

  void updateBooking(String id, Booking booking) async {
    final appId = await _getId();

    final bookingIndex =
        _bookings.indexWhere((bookingData) => bookingData.idOnServer == id);
    if (bookingIndex >= 0) {
      _bookings[bookingIndex] = booking;
      final url =
          'https://medical-reminder-3e48b.firebaseio.com/${appId}bookings/$id.json?auth=$_accessToken';
      await http.patch(url, body: json.encode(booking.toMap()));
      notifyListeners();
    } else {
      print('index is $bookingIndex');
    }
  }

  Future<bool> refreshBookingList() async {
    _bookings = [];
    if (!await checkInternetConnection()) return false;

    final appId = await _getId();

    String _apiUrl =
        'https://medical-reminder-3e48b.firebaseio.com/${appId}bookings.json?auth=$_accessToken';
    final response = await http.get(_apiUrl);

    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return true;
    }
    final List<Booking> loadedBookings = [];
    extractedData.forEach((bookingId, bookingDataData) {
      final booking = Booking.fromJson(bookingDataData);
      booking.idOnServer = bookingId;
      loadedBookings.add(booking);
    });

    _bookings = loadedBookings;
    notifyListeners();
    return true;
  }

  void removeOldBookings(DateTime currentDate) {
    _bookings
        .removeWhere((booking) => booking.dateAndTime.isBefore(currentDate));
  }

  List<Booking> get bookingList => [..._bookings];
}

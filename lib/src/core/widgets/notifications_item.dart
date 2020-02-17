import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import './../../core/providers/language_provider.dart';
import './../../features/alerts/providers/bookings_provider.dart';
import './../../features/alerts/providers/medicines_provider.dart';
import './../../features/alerts/screens/edit_screen.dart';
import './../providers/notifications_provider.dart';
import './../models/notification.dart';

class NotificationItem extends StatelessWidget {
  final String id;
  final String idOnServer;
  final String title;
  final String description;
  final EventType eventType;
  final DateTime date;

  NotificationItem({
    this.id,
    this.idOnServer,
    this.title,
    this.description,
    this.eventType,
    this.date,
  });

  NotificationProvider notificationsProvider;

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    notificationsProvider = Provider.of<NotificationProvider>(context);

    final bookingsProvider =
        Provider.of<BookingsProvider>(context, listen: false);

    return Directionality(
      textDirection:
          langProvider.langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,
        ),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              blurRadius: 10.0,
              color: Colors.grey[200],
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (ctx, constraints) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.display2.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: MaterialButton(
                      onPressed: () async {
                        _cancelScheduledNotificationOf(date);
                        switch (eventType) {
                          case EventType.booking:
                            {
                              final booking = bookingsProvider.bookingList
                                  .firstWhere((booking) => booking.id == id);

                              notificationsProvider
                                  .removeNotification(idOnServer);
                              bookingsProvider
                                  .removeBooking(booking.idOnServer);
                              break;
                            }
                          case EventType.medicine:
                            {
                              await _handleMedicineNotification(context);
                              break;
                            }
                        }
                      },
                      child: Row(
                        children: <Widget>[
                          Text(
                            langProvider.labelsProvider.markAsDone,
                            style: Theme.of(context)
                                .textTheme
                                .display2
                                .copyWith(color: Theme.of(context).accentColor),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Icon(
                            Icons.done,
                            color: Theme.of(context).accentColor,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Text('$description EG',
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context)
                      .textTheme
                      .display2
                      .copyWith(fontWeight: FontWeight.bold)),
              SizedBox(
                height: 10.0,
              ),
              Text(
                _formatDate(),
                textDirection: TextDirection.ltr,
                style: Theme.of(context).textTheme.display2.copyWith(
                      color: Colors.grey[600],
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleMedicineNotification(context) async {
    final medicinesProvider =
        Provider.of<MedicinesProvider>(context, listen: false);
    final medicine = medicinesProvider.medicineList
        .firstWhere((medicine) => medicine.id == id);

    medicine.progress += 1;

    if (medicine.progress == medicine.periodPerDays) {
      await medicinesProvider.removeMedicine(medicine.idOnServer);
      notificationsProvider.removeNotificationsOf(medicine.id);
    }

    final startDate = DateTime(
      medicine.startDate.year,
      medicine.startDate.month,
      medicine.startDate.day,
      medicine.time.hour,
      medicine.time.minute,
      0,
      0,
      0,
    );

    medicine.dates.removeWhere((date) => date.isBefore(
        startDate.add(Duration(days: medicine.period * medicine.progress))));

    await medicinesProvider.updateMedicine(medicine.idOnServer, medicine);

    final notificationIdOnServer =
        notificationsProvider.getTodayNotifications().firstWhere(
      (notification) {
        return notification.id == medicine.id;
      },
    ).idOnServer;

    notificationsProvider.removeNotification(notificationIdOnServer);

    if ((medicine.progress * medicine.period) < medicine.periodPerDays) {
      _scheduleNotificationByDate(
          startDate.add(Duration(days: medicine.period * medicine.progress)),
          medicine);
    }
  }

  String _formatDate() {
    final hour = date.hour;
    final minute = date.minute;
    final formattedDate = intl.DateFormat.yMd().format(date);
    String formatedHour;
    String formatedMinute;
    String timeCode;

    if (hour > 12) {
      formatedHour = '0' + (hour - 12).toString();
      timeCode = 'PM';
    } else {
      formatedHour = hour.toString();
      timeCode = 'AM';
    }

    if (minute < 10) {
      formatedMinute = '0' + minute.toString();
    } else {
      formatedMinute = minute.toString();
    }

    return formattedDate +
        ' - ' +
        formatedHour +
        ':' +
        formatedMinute +
        ' ' +
        timeCode;
  }

  void _scheduleNotificationByDate(DateTime date, medicine) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();

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

    notificationsProvider.addNotification(AppNotification(
      id: medicine.id,
      isHandled: false,
      date: scheduledNotificationDateTime,
      eventType: EventType.medicine,
      title: medicine.name,
      description: medicine.notes,
    ));
  }

  void _cancelScheduledNotificationOf(DateTime date) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();

    var notificationIdText = date.toString();
    notificationIdText = notificationIdText.replaceAll(RegExp(r"[^0-9]"), '');

    int notificationId =
        (double.parse(notificationIdText) % 2147483647).toInt();

    print('Notification Id: $notificationId');

    flutterLocalNotificationsPlugin.cancel(notificationId);
  }
}

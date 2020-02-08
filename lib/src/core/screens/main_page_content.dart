import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import './../../core/resources/assets_constants.dart';
import './../../core/resources/labels.dart';
import './../../features/alerts/providers/bookings_provider.dart';
import './../../features/alerts/providers/medicines_provider.dart';
import './../../features/alerts/screens/alerts_screen/alerts_page.dart';
import './../../features/alerts/screens/edit_screen.dart';
import './../../features/alerts/widgets/category_item.dart';
import './../../features/emergency/screens/emargancy.dart';
import './../../features/hospitals/screens/hospitals_screen.dart';
import './../../reminder_app.dart';
import './../models/notification.dart';
import './../providers/language_provider.dart';
import './../providers/notifications_provider.dart';
import './../../features/vaccinations/screens/vaccinations_screen.dart';

class MainPageContent extends StatelessWidget {
  var labelsProvider;

  void _initializeLabelsProvider(context) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;
  }

  @override
  Widget build(BuildContext context) {
    _initializeLabelsProvider(context);

    final medicineProvider =
        Provider.of<MedicinesProvider>(context, listen: false);
    final bookingsProvider =
        Provider.of<BookingsProvider>(context, listen: false);
    final notificationsProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    if (!medicineProvider.isActivitiesLoaded) {
      medicineProvider.refreshMedicineList();

      bookingsProvider.refreshBookingList();
      print('Activites Loaded');
    }

    if (!medicineProvider.isNotificationClickHandled) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails()
          .then((notificationDetails) {
        if (notificationDetails.payload != null) {
          final type = notificationDetails.payload.split('\$\$')[1];
          if (type == 'Booking') {
            _removeEndedBooking(
              bookingsProvider,
              notificationDetails.payload.split('\$\$')[0],
              medicineProvider,
              notificationsProvider,
            );
          } else if (type == 'Medicine') {
            _incrementProgressForMedicine(
              medicineProvider,
              notificationDetails.payload.split('\$\$')[0],
              notificationsProvider,
            );
          }
          print('NOTIFICATION HANDLED');
        }
      });
    }

    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: <Widget>[
            Text(
              labelsProvider.mainPageLabel,
              style: Theme.of(context).textTheme.title,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(
                  top: 20.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: GridView(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 2 / 2.4,
                    crossAxisCount: 2,
                    mainAxisSpacing: 30.0,
                    crossAxisSpacing: 50.0,
                  ),
                  children: <Widget>[
                    CategoryItem(
                      title: labelsProvider.hospitals,
                      imageUrl: Assets.hospitalsIcon,
                      onCategoryTappedCallback: _onHospitalsCategoryTapped,
                      isPng: false,
                    ),
                    CategoryItem(
                      title: labelsProvider.alerts,
                      imageUrl: Assets.alertsIcon,
                      onCategoryTappedCallback: _onAlertsCategoryTapped,
                      isPng: true,
                    ),
                    CategoryItem(
                      title: labelsProvider.emergency,
                      imageUrl: Assets.emergencyIcon,
                      onCategoryTappedCallback: _onEmergencyCategoryTapped,
                      isPng: true,
                    ),
                    CategoryItem(
                      title: labelsProvider.vaccinations,
                      imageUrl: Assets.vaccinationsIcon,
                      onCategoryTappedCallback: _onVaccinationsCategoryTapped,
                      isPng: true,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onHospitalsCategoryTapped() {
    Routes.sailor.navigate(HospitalsScreen.routeName);
  }

  void _onAlertsCategoryTapped() {
    Routes.sailor.navigate(AlertsPage.routeName);
  }

  void _onEmergencyCategoryTapped() {
    Routes.sailor.navigate(Emergancy.routeName);
  }

  void _onVaccinationsCategoryTapped() {
    Routes.sailor.navigate(VaccinationsScreen.routeName);
  }

  Future<void> _removeEndedBooking(
    bookingsProvider,
    String id,
    medicinesProvider,
    NotificationProvider notificationsProvider,
  ) async {
    final bookingData = bookingsProvider.bookingList
        .firstWhere((booking) => booking.id == id, orElse: () => null);

    if (bookingData != null) {
      await bookingsProvider.removeBooking(bookingData.idOnServer);
      medicinesProvider.setNotificationClickHandled(true);

      final notificationIdOnServer =
          notificationsProvider.getTodayNotifications().firstWhere(
        (notification) {
          return notification.id == bookingData.id;
        },
      ).idOnServer;

      notificationsProvider.removeNotification(notificationIdOnServer);
    }
  }

  Future<void> _incrementProgressForMedicine(
    MedicinesProvider medicinesProvider,
    String id,
    NotificationProvider notificationsProvider,
  ) async {
    final medicine = medicinesProvider.medicineList.firstWhere(
      (medicine) => medicine.id == id,
      orElse: () => null,
    );

    if (medicine != null) {
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

      medicine.progress += 1;

      if (medicine.progress == medicine.periodPerDays) {
        await medicinesProvider.removeMedicine(medicine.idOnServer);
        notificationsProvider.removeNotificationsOf(medicine.id);
      }

      medicine.dates.removeWhere((date) => date.isBefore(
          startDate.add(Duration(days: medicine.period * medicine.progress))));

      await medicinesProvider.updateMedicine(medicine.idOnServer, medicine);

      print(medicine.dates);

      if ((medicine.period * medicine.progress) < medicine.periodPerDays) {
        _scheduleNotificationByDate(
            startDate.add(Duration(days: medicine.period * medicine.progress)),
            medicine);
        print(startDate
            .add(Duration(days: medicine.period * medicine.progress))
            .toString());

        notificationsProvider.addNotification(AppNotification(
          id: medicine.id,
          title: medicine.name,
          description: medicine.notes,
          date: startDate.add(
            Duration(days: medicine.period * medicine.progress),
          ),
          eventType: EventType.medicine,
          isHandled: false,
        ));
      }

      medicinesProvider.setNotificationClickHandled(true);

      final notificationIdOnServer =
          notificationsProvider.getTodayNotifications().firstWhere(
        (notification) {
          return notification.id == medicine.id;
        },
      ).idOnServer;

      notificationsProvider.removeNotification(notificationIdOnServer);
    }
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
  }
}

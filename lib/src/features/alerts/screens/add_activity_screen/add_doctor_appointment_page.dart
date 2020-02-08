import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import './../../../../core/mixins/internet_connection_status_mixin.dart';
import './../../../../core/providers/language_provider.dart';
import './../../../../core/providers/notifications_provider.dart';
import './../../../../core/resources/labels.dart';
import './../../models/booking.dart';
import './../../providers/bookings_provider.dart';
import './../../widgets/custom_radio_group.dart';
import '../../../../core/models/notification.dart';
import './../edit_screen.dart';

class AddDoctorAppointmentPage extends StatefulWidget {
  final String id;

  AddDoctorAppointmentPage({this.id});

  @override
  _AddDoctorAppointmentPageState createState() =>
      _AddDoctorAppointmentPageState();
}

class _AddDoctorAppointmentPageState extends State<AddDoctorAppointmentPage>
    with InternetConnectionStatusMixin {
  final TextEditingController doctorNameFieldController =
      TextEditingController();
  final TextEditingController costFieldController = TextEditingController();
  final TextEditingController notesFieldController = TextEditingController();
  final TextEditingController dateAndTimeFieldController =
      TextEditingController();
  final TextEditingController bookingTypeFieldController =
      TextEditingController();
  int _currentChosenType;
  DateTime _currentChosenDate;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var labelsProvider;

  void _initializeLabelsProvider() {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;
  }

  @override
  void initState() {
    _initializeLabelsProvider();

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id != null && _currentChosenDate == null) {
      final bookingData = Provider.of<BookingsProvider>(context, listen: false)
          .bookingList
          .firstWhere((booking) => booking.id == widget.id);

      doctorNameFieldController.text = bookingData.doctorName;
      dateAndTimeFieldController.text =
          DateFormat.yMd().format(bookingData.dateAndTime);
      bookingTypeFieldController.text = bookingData.bookingType;
      costFieldController.text = bookingData.cost.toString();
      notesFieldController.text = bookingData.notes;
    }

    return Container(
      margin: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              blurRadius: 20.0,
              color: Colors.grey[200],
            ),
          ]),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          return Container(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            padding: const EdgeInsets.all(15.0),
            child: ListView(
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _openDatePicker(context).then((chosenDate) {
                      if (chosenDate == null) {
                        dateAndTimeFieldController.text = '';
                        return null;
                      }
                      dateAndTimeFieldController.text =
                          DateFormat.yMd().format(chosenDate);
                      setState(() {
                        _currentChosenDate = chosenDate;
                      });
                    });
                  },
                  child: TextField(
                    enabled: false,
                    controller: dateAndTimeFieldController,
                    style: Theme.of(context)
                        .textTheme
                        .display2
                        .copyWith(color: Colors.black),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      labelText: labelsProvider.dateAndTime,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .display1
                          .copyWith(color: Colors.grey[400]),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _openBookingTypeDialog(context).then((chosenType) {
                      _currentChosenType = chosenType;
                      switch (chosenType) {
                        case 1:
                          print(labelsProvider.examine);
                          bookingTypeFieldController.text =
                              labelsProvider.examine;
                          break;
                        case 2:
                          bookingTypeFieldController.text =
                              labelsProvider.consultation;
                          break;
                        case 3:
                          bookingTypeFieldController.text =
                              labelsProvider.followUp;
                          break;
                        default:
                          bookingTypeFieldController.text = '';
                      }
                    });
                  },
                  child: TextField(
                    controller: bookingTypeFieldController,
                    enabled: false,
                    style: Theme.of(context)
                        .textTheme
                        .display2
                        .copyWith(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: labelsProvider.bookingType,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .display1
                          .copyWith(color: Colors.grey[400]),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextField(
                  controller: doctorNameFieldController,
                  style: Theme.of(context)
                      .textTheme
                      .display2
                      .copyWith(color: Colors.black),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: labelsProvider.doctorName,
                    labelStyle: Theme.of(context)
                        .textTheme
                        .display1
                        .copyWith(color: Colors.grey[400]),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextField(
                  controller: costFieldController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: Theme.of(context)
                      .textTheme
                      .display2
                      .copyWith(color: Colors.black),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: labelsProvider.cost,
                    labelStyle: Theme.of(context)
                        .textTheme
                        .display1
                        .copyWith(color: Colors.grey[400]),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextField(
                  controller: notesFieldController,
                  style: Theme.of(context)
                      .textTheme
                      .display2
                      .copyWith(color: Colors.black),
                  minLines: 5,
                  maxLines: 20,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: labelsProvider.note,
                    labelStyle: Theme.of(context)
                        .textTheme
                        .display1
                        .copyWith(color: Colors.grey[400]),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  color: Theme.of(context).accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  onPressed: _saveNewAppointment,
                  child: Text(
                    labelsProvider.save,
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _validateInputs() {
    String message = '';

    if (dateAndTimeFieldController.text.isEmpty) {
      message += labelsProvider.dateAndTimeRequired;
    }

    if (bookingTypeFieldController.text.isEmpty) {
      message += labelsProvider.bookingTypeRequired;
    }

    if (doctorNameFieldController.text.isEmpty) {
      message += labelsProvider.doctorNameRequired;
    }

    if (costFieldController.text.isEmpty) {
      message += labelsProvider.costFieldRequired;
    }

    if (notesFieldController.text.isEmpty) {
      message += labelsProvider.bookingNotesRequired;
    }

    if (message != '') {
      Flushbar(
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ),
        messageText: Text(
          message,
          style: Theme.of(context)
              .textTheme
              .display1
              .copyWith(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
      )..show(context);
      return false;
    }
    return true;
  }

  Future<bool> _isConnected() async {
    if (!(await checkInternetConnection())) {
      Flushbar(
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ),
        messageText: Text(
          labelsProvider.internetConnectionFailed,
          style: Theme.of(context)
              .textTheme
              .display1
              .copyWith(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
      )..show(context);
      return false;
    }
    return true;
  }

  void _saveNewAppointment() async {
    if (!_validateInputs()) return;

    if (!await _isConnected()) return;

    String bookingType = '';
    switch (_currentChosenType) {
      case 1:
        bookingType = labelsProvider.examine;
        break;
      case 2:
        bookingType = labelsProvider.consultation;
        break;
      case 3:
        bookingType = labelsProvider.followUp;
        break;
    }

    double bookingCost;
    try {
      bookingCost = double.parse(costFieldController.text);
    } on Exception catch (error) {
      Flushbar(
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ),
        messageText: Text(
          labelsProvider.invalidCostValue,
          style: Theme.of(context)
              .textTheme
              .display1
              .copyWith(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
      )..show(context);
      return;
    }

    final newBooking = Booking(
      dateAndTime: _currentChosenDate,
      doctorName: doctorNameFieldController.text,
      cost: bookingCost,
      bookingType: bookingType,
      notes: notesFieldController.text,
    );

    bookingsProvider = Provider.of<BookingsProvider>(context, listen: false);

    if (widget.id != null) {
      final bookingData = Provider.of<BookingsProvider>(context, listen: false)
          .bookingList
          .firstWhere((booking) => booking.id == widget.id);

      newBooking.id = bookingData.id;
      newBooking.idOnServer = bookingData.idOnServer;

      if (_currentChosenDate == null) {
        newBooking.dateAndTime = bookingData.dateAndTime;
      } else {
        final newDateAndTime = DateTime(
          _currentChosenDate.year,
          _currentChosenDate.month,
          _currentChosenDate.day,
          TimeOfDay.now().hour,
          TimeOfDay.now().minute,
          0,
          0,
        );
        newBooking.dateAndTime = newDateAndTime;
        _cancelNotification(bookingData.dateAndTime);
        _scheduleNotificationByDate(newBooking.dateAndTime, newBooking);
      }

      if (newBooking.bookingType.isEmpty) {
        newBooking.bookingType = bookingData.bookingType;
      }

      bookingsProvider.updateBooking(newBooking.idOnServer, newBooking);
    } else {
      final newDateAndTime = DateTime(
        _currentChosenDate.year,
        _currentChosenDate.month,
        _currentChosenDate.day,
        TimeOfDay.now().hour,
        TimeOfDay.now().minute,
        0,
        0,
      );
      newBooking.id = _currentChosenDate.toString();
      newBooking.dateAndTime = newDateAndTime;
      _scheduleNotificationByDate(newBooking.dateAndTime, newBooking);
      bookingsProvider.addNewAppointment(newBooking);
    }

    Navigator.of(context).pop();
  }

  BookingsProvider bookingsProvider;
  void _cancelNotification(DateTime date) {
    var notificationIdText = date.toString();
    notificationIdText = notificationIdText.replaceAll(RegExp(r"[^0-9]"), '');

    int notificationId =
        (double.parse(notificationIdText) % 2147483647).toInt();

    flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  NotificationProvider notificationsProvider;

  void _scheduleNotificationByDate(DateTime date, Booking booking) {
    var scheduledNotificationDateTime = date.add(Duration(seconds: 5));
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      booking.id,
      booking.bookingType + ' - ' + booking.doctorName,
      booking.notes,
      sound: 'notification_sound',
      importance: Importance.Max,
      priority: Priority.High,
      autoCancel: true,
      groupKey: booking.id,
    );

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails(
      sound: 'notification_sound.aiff',
    );

    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    var notificationIdText = date.add(Duration(seconds: 5)).toString();
    notificationIdText = notificationIdText.replaceAll(RegExp(r"[^0-9]"), '');

    int notificationId =
        (double.parse(notificationIdText) % 2147483647).toInt();

    print('Notification Id: $notificationId');

    flutterLocalNotificationsPlugin.schedule(
      notificationId,
      booking.bookingType + ' - ' + booking.doctorName,
      booking.notes,
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      payload: booking.id + '\$\$' + 'Booking',
    );

    notificationsProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    notificationsProvider.addNotification(AppNotification(
      id: booking.id,
      isHandled: false,
      date: scheduledNotificationDateTime,
      eventType: EventType.booking,
      title: booking.bookingType + ' - ' + booking.doctorName,
      description: booking.notes,
    ));
  }

  int i = 1;
  Future onSelectNotification(String payload) async {
    if (payload != null && i == 1) {
      debugPrint('notification payload: ' + payload);

      final booking = bookingsProvider.bookingList.firstWhere(
          (bookingData) => bookingData.id == payload.split('\$\$')[0]);

      if (await _isConnected()) {
        debugPrint('Removing Booking ${booking.id} ...');
        await bookingsProvider.removeBooking(booking.idOnServer);

        final notificationIdOnServer =
            notificationsProvider.getTodayNotifications().firstWhere(
          (notification) {
            return notification.id == booking.id;
          },
        ).idOnServer;

        notificationsProvider.removeNotification(notificationIdOnServer);
      }

      debugPrint('Booking Deleted');
      i++;
    } else {
      i = 1;
    }
  }

  Future onDidReceiveLocalNotification(
    int id,
    String title,
    String body,
    String payload,
  ) async {}

  Future<int> _openBookingTypeDialog(context) {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Align(
            alignment: Alignment.topCenter,
            child: Text(
              labelsProvider.bookingType,
              style: Theme.of(context)
                  .textTheme
                  .display1
                  .copyWith(color: Colors.grey[400]),
            ),
          ),
          content: SingleChildScrollView(
            child: CustomRadioGroup(
              chosenType: _currentChosenType,
              onDialogDismissed: _onChoosingBookingTypeCanceled,
              onDialogDone: _onChoosingBookingTypeDone,
            ),
          ),
        );
      },
    );
  }

  void _onChoosingBookingTypeCanceled() {
    Navigator.of(context).pop(-1);
  }

  void _onChoosingBookingTypeDone(int currentValue) {
    Navigator.of(context).pop(currentValue);
  }

  Future<DateTime> _openDatePicker(context) {
    return showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      initialDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(),
          child: child,
        );
      },
    );
  }
}

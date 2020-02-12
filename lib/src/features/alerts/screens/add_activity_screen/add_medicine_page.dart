import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import './../../../../core/mixins/internet_connection_status_mixin.dart';
import './../../../../core/models/notification.dart';
import './../../../../core/providers/language_provider.dart';
import './../../../../core/providers/notifications_provider.dart';
import './../../../../core/resources/labels.dart';
import './../../models/medicine.dart';
import './../../providers/medicines_provider.dart';
import './../../widgets/medicine_period_radio_group.dart';
import '../edit_screen.dart';

class AddMedicinePage extends StatefulWidget {
  final String id;

  AddMedicinePage({this.id});

  @override
  _AddMedicinePageState createState() => _AddMedicinePageState();
}

bool _isLoading = false;

class _AddMedicinePageState extends State<AddMedicinePage>
    with InternetConnectionStatusMixin {
  final TextEditingController medicineNameFieldController =
      TextEditingController();
  final TextEditingController medicinePeriodPerDayFieldController =
      TextEditingController();
  final TextEditingController notesFieldController = TextEditingController();
  final TextEditingController startDateFieldController =
      TextEditingController();
  final TextEditingController medicinePeriodFieldController =
      TextEditingController();
  final TextEditingController medicineTimeFieldController =
      TextEditingController();

  DateTime _currentChosenStartDate;
  TimeOfDay _currentChosenMedicineTime;
  int _currentPeriodOptionChosen;
  int _currentMedicinePeriod;
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
    notificationsProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    if (widget.id != null &&
        _currentChosenStartDate == null &&
        _currentChosenMedicineTime == null) {
      final medicineData =
          Provider.of<MedicinesProvider>(context, listen: false)
              .medicineList
              .firstWhere((medicine) => medicine.id == widget.id);

      medicineNameFieldController.text = medicineData.name;
      startDateFieldController.text =
          DateFormat.yMd().format(medicineData.startDate);
      medicinePeriodPerDayFieldController.text =
          medicineData.periodPerDays.toString();
      medicinePeriodFieldController.text = medicineData.period > 1
          ? '${labelsProvider.every} ${medicineData.period} ${labelsProvider.days}'
          : labelsProvider.daily;
      medicineTimeFieldController.text = medicineData.time.format(context);

      notesFieldController.text = medicineData.notes;
    }

    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Container(
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
                  TextField(
                    controller: medicineNameFieldController,
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
                      labelText: labelsProvider.medicineName,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .display1
                          .copyWith(color: Colors.grey[400]),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _openDatePicker(context).then((chosenDate) {
                        if (chosenDate == null) {
                          startDateFieldController.text = '';
                          return null;
                        }
                        startDateFieldController.text =
                            DateFormat.yMd().format(chosenDate);
                        setState(() {
                          _currentChosenStartDate = chosenDate;
                        });
                      });
                    },
                    child: TextField(
                      enabled: false,
                      controller: startDateFieldController,
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
                        labelText: labelsProvider.startDate,
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
                    controller: medicinePeriodPerDayFieldController,
                    keyboardType: TextInputType.number,
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
                      labelText: labelsProvider.medicinePeriodPerDays,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .display1
                          .copyWith(color: Colors.grey[400]),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _openMedicinePeriodDialog(context).then((result) {
                        if (result == null) {
                          medicinePeriodFieldController.text = '';
                          return;
                        }

                        _currentPeriodOptionChosen = result['selectedValue'];
                        _currentMedicinePeriod = result['days'];

                        switch (result['selectedValue']) {
                          case 1:
                            medicinePeriodFieldController.text =
                                labelsProvider.daily;
                            break;
                          case 2:
                            medicinePeriodFieldController.text =
                                '${labelsProvider.every} $_currentMedicinePeriod ${labelsProvider.days}';
                            break;
                          default:
                            medicinePeriodFieldController.text = '';
                        }
                      });
                    },
                    child: TextField(
                      controller: medicinePeriodFieldController,
                      enabled: false,
                      style: Theme.of(context)
                          .textTheme
                          .display2
                          .copyWith(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: labelsProvider.medicinePeriod,
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
                      _openTimePicker(context).then((chosenTime) {
                        if (chosenTime == null) {
                          medicineTimeFieldController.text = '';
                          return null;
                        }
                        medicineTimeFieldController.text =
                            chosenTime.format(context);
                        setState(() {
                          _currentChosenMedicineTime = chosenTime;
                          print('\nChosen Time: $_currentChosenMedicineTime\n');
                        });
                      });
                    },
                    child: TextField(
                      enabled: false,
                      controller: medicineTimeFieldController,
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
                        labelText: labelsProvider.medicineTime,
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
                    onPressed: _saveNewMedicine,
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
      ),
    );
  }

  Future<Map<String, int>> _openMedicinePeriodDialog(context) {
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
              labelsProvider.medicinePeriod,
              style: Theme.of(context)
                  .textTheme
                  .display1
                  .copyWith(color: Colors.grey[400]),
            ),
          ),
          content: SingleChildScrollView(
            child: MedicinePeriodRadioGroup(
              chosenPeriod: _currentPeriodOptionChosen,
              cuurentPeriod: _currentMedicinePeriod,
              onDialogDismissed: _onChoosingMedicinePeriodCanceled,
              onDialogDone: _onChoosingMedicinePeriodDone,
            ),
          ),
        );
      },
    );
  }

  bool _validateInputs() {
    String message = '';

    if (medicineNameFieldController.text.isEmpty) {
      message += labelsProvider.medicineNameRequired;
    }

    if (startDateFieldController.text.isEmpty) {
      message += labelsProvider.startDateRequired;
    }

    if (medicinePeriodPerDayFieldController.text.isEmpty) {
      message += labelsProvider.periodPerDaysRequired;
    } else if (int.parse(medicinePeriodPerDayFieldController.text.trim()) ==
        0) {
      message += labelsProvider.medicinePeriodPerDaysMustBeGreaterThanZero;
    }

    if (medicinePeriodFieldController.text.isEmpty) {
      message += labelsProvider.medicinePeriodRequired;
    }

    if (medicineTimeFieldController.text.isEmpty) {
      message += labelsProvider.medicineTimeRequired;
    }

    if (notesFieldController.text.isEmpty) {
      message += labelsProvider.medicineNotesRequired;
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
        duration: Duration(seconds: 3),
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

  void _saveNewMedicine() async {
    if (!_validateInputs()) return;
    if (!await _isConnected()) return;

    int daysOfMedicine;
    try {
      daysOfMedicine =
          int.parse(medicinePeriodPerDayFieldController.text.trim());
    } on Exception catch (error) {
      Flushbar(
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ),
        messageText: Text(
          labelsProvider.invalidPeriodPerDaysValue,
          style: Theme.of(context)
              .textTheme
              .display1
              .copyWith(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
      )..show(context);
      return;
    }
    final newMedicine = Medicine(
      name: medicineNameFieldController.text,
      startDate: _currentChosenStartDate,
      progress: 0,
      periodPerDays: daysOfMedicine,
      period: _currentMedicinePeriod,
      time: _currentChosenMedicineTime,
      notes: notesFieldController.text,
    );

    medicinesProvider = Provider.of<MedicinesProvider>(context, listen: false);

    if (widget.id != null) {
      final medicineData = medicinesProvider.medicineList
          .firstWhere((medicine) => medicine.id == widget.id);

      newMedicine.id = medicineData.id;

      newMedicine.idOnServer = medicineData.idOnServer;
      newMedicine.progress = medicineData.progress;

      if (newMedicine.startDate == null) {
        newMedicine.startDate = medicineData.startDate;
        newMedicine.dates = medicineData.dates;
      }

      if (newMedicine.time == null) {
        newMedicine.time = medicineData.time;
      }

      if (newMedicine.period == null) {
        newMedicine.period = medicineData.period;
      }

      if (newMedicine.periodPerDays == null) {
        newMedicine.periodPerDays = medicineData.periodPerDays;
      }

      if (_currentMedicinePeriod != null ||
          daysOfMedicine != medicineData.periodPerDays ||
          _currentChosenMedicineTime != null ||
          _currentChosenStartDate != null) {
        if (_currentChosenMedicineTime == null) {
          _currentChosenMedicineTime = medicineData.time;
        }

        if (_currentChosenStartDate == null) {
          _currentChosenStartDate = medicineData.startDate;
        }

        if (_currentMedicinePeriod == null) {
          _currentMedicinePeriod = medicineData.period;
        }

        setState(() {
          _isLoading = true;
        });
        await notificationsProvider.removeNotificationsOf(widget.id);
        setState(() {
          _isLoading = false;
        });
        newMedicine.dates = _getMedicineDayes(
          newMedicine,
          previousNumberOfDays: medicineData.periodPerDays,
          previousMedPeriod: medicineData.period,
          previousStartDate: medicineData.startDate,
          previousMedTime: medicineData.time,
        );
      }

      medicinesProvider.updateMedicine(newMedicine.idOnServer, newMedicine);
    } else {
      newMedicine.id = _currentChosenStartDate.toString();
      newMedicine.dates = _getMedicineDayes(newMedicine);
      medicinesProvider.addMedicine(newMedicine);
    }

    Navigator.of(context).pop();
  }

  MedicinesProvider medicinesProvider;
  List<DateTime> _getMedicineDayes(
    Medicine medicine, {
    int previousNumberOfDays,
    int previousMedPeriod,
    DateTime previousStartDate,
    TimeOfDay previousMedTime,
  }) {
    final numberOfDays =
        int.parse(medicinePeriodPerDayFieldController.text.trim());
    final startDate = DateTime(
      _currentChosenStartDate.year,
      _currentChosenStartDate.month,
      _currentChosenStartDate.day,
      _currentChosenMedicineTime.hour,
      _currentChosenMedicineTime.minute,
      0,
      0,
      0,
    );
    List<DateTime> medicineDates = [];

    if (startDate.isAfter(DateTime.now())) {
      medicineDates.add(startDate);
      _scheduleNotificationByDate(startDate, medicine);
      if (_currentMedicinePeriod < medicine.periodPerDays) {
        _scheduleNotificationByDate(
            startDate.add(Duration(days: _currentMedicinePeriod)), medicine);
      }
    } else {
      if (medicine.progress == 0)
        _scheduleNotificationByDate(
            startDate.add(Duration(seconds: 5)), medicine);

      _scheduleNotificationByDate(
          startDate.add(Duration(days: _currentMedicinePeriod)), medicine);
      if (2 * _currentMedicinePeriod < numberOfDays) {
        _scheduleNotificationByDate(
            startDate.add(Duration(days: 2 * _currentMedicinePeriod)),
            medicine);
      }
    }
    int x = 1;

    if (previousNumberOfDays != null) {
      final date = DateTime(
        previousStartDate.year,
        previousStartDate.month,
        previousStartDate.day,
        previousMedTime.hour,
        previousMedTime.minute,
        0,
        0,
        0,
      );
      //notificationsProvider.removeNotificationsOf(medicine.id);
      _cancelNotification(date);
      _cancelNotification(date.add(Duration(days: previousMedPeriod)));
      _cancelNotification(date.add(Duration(days: 2 * previousMedPeriod)));
      // for (int days = previousMedPeriod;
      //     x < previousNumberOfDays;
      //     x += 1, days += previousMedPeriod) {
      //   _cancelNotification(date.add(Duration(days: days)));
      // }

      if (medicine.progress > 1) x = medicine.progress;
    }

    for (int days = _currentMedicinePeriod;
        x < numberOfDays;
        x += 1, days += _currentMedicinePeriod) {
      medicineDates.add(startDate.add(Duration(days: days)));
      // if (startDate.add(Duration(days: days)).isAfter(DateTime.now()))
      //   _scheduleNotificationByDate(
      //     startDate.add(Duration(days: days)),
      //     medicine,
      //   );
    }

    print(medicineDates);
    return medicineDates;
  }

  void _cancelNotification(DateTime date) {
    var notificationIdText = date.toString();
    notificationIdText = notificationIdText.replaceAll(RegExp(r"[^0-9]"), '');

    int notificationId =
        (double.parse(notificationIdText) % 2147483647).toInt();

    flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  NotificationProvider notificationsProvider;

  void _scheduleNotificationByDate(DateTime date, Medicine medicine) {
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

  int i = 1;
  Future onSelectNotification(String payload) async {
    if (payload != null && i == 1) {
      i++;
      debugPrint('notification payload: ' + payload);

      final medicine = medicinesProvider.medicineList.firstWhere(
          (medicine) => medicine.id == payload.split('\$\$')[0],
          orElse: () => null);
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

        final notificationIdOnServer =
            notificationsProvider.getTodayNotifications().firstWhere(
          (notification) {
            return notification.id == medicine.id;
          },
        ).idOnServer;

        if (medicine.progress == medicine.periodPerDays) {
          await medicinesProvider.removeMedicine(medicine.idOnServer);
          notificationsProvider.removeNotificationsOf(medicine.id);
        }

        medicine.dates.removeWhere((date) => date.isBefore(startDate
            .add(Duration(days: medicine.period * medicine.progress))));

        await medicinesProvider.updateMedicine(medicine.idOnServer, medicine);

        notificationsProvider.removeNotification(notificationIdOnServer);

        print(medicine.dates);

        if ((medicine.period * medicine.progress) < medicine.periodPerDays) {
          _scheduleNotificationByDate(
              startDate
                  .add(Duration(days: medicine.period * medicine.progress)),
              medicine);
          print(startDate
              .add(Duration(days: medicine.period * medicine.progress))
              .toString());
        }
      }
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

  void _onChoosingMedicinePeriodCanceled() {
    Navigator.of(context).pop(null);
  }

  void _onChoosingMedicinePeriodDone(int currentValue, int newPeriod) {
    Navigator.of(context)
        .pop({'selectedValue': currentValue, 'days': newPeriod});
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

  Future<TimeOfDay> _openTimePicker(context) {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(),
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    medicineNameFieldController.dispose();
    startDateFieldController.dispose();
    medicinePeriodFieldController.dispose();
    medicinePeriodPerDayFieldController.dispose();
    medicineTimeFieldController.dispose();
    notesFieldController.dispose();
    super.dispose();
  }
}

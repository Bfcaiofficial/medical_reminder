import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

import './../../../../core/resources/labels.dart';
import './../../models/booking.dart';
import './../../models/medicine.dart';
import './../../providers/bookings_provider.dart';
import './../../providers/medicines_provider.dart';
import './../../screens/edit_screen.dart';
import './../../widgets/activity_item_banner.dart';
import './../../../../core/providers/language_provider.dart';

class AgendaPageContent extends StatefulWidget {
  final double appBarHeight;

  const AgendaPageContent({this.appBarHeight});

  @override
  _AgendaPageContentState createState() => _AgendaPageContentState();
}

class _AgendaPageContentState extends State<AgendaPageContent> {
  DateTime _selectedDate;
  var labelsProvider;
  var langProvider;

  void _initializeLabelsProvider() {
    langProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;
  }

  @override
  void initState() {
    _selectedDate = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initializeLabelsProvider();

    final mediaQuery = MediaQuery.of(context);
    return LiquidPullToRefresh(
      showChildOpacityTransition: false,
      onRefresh: () async {
        Provider.of<MedicinesProvider>(context, listen: false)
            .refreshMedicineList();
        final isConnected =
            await Provider.of<BookingsProvider>(context, listen: false)
                .refreshBookingList();
        if (!isConnected) {
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
        }

        return isConnected;
      },
      child: ListView(shrinkWrap: false, children: [
        Container(
          height: mediaQuery.size.height - widget.appBarHeight - 35,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _buildTableCalendar(mediaQuery),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildTableCalendar(mediaQuery) {
    final medicinesProvider = Provider.of<MedicinesProvider>(context);
    final medicines = medicinesProvider.medicineList.where((medicine) {
      final index = medicine.dates.indexWhere(
        (date) =>
            date.day == _selectedDate.day &&
            date.month == _selectedDate.month &&
            date.year == _selectedDate.year,
      );
      return index != -1;

      // return medicine.startTime.day == _selectedDate.day &&
      //     medicine.startTime.month == _selectedDate.month &&
      //     medicine.startTime.year == _selectedDate.year;
    }).toList();
    final bookingsProvider = Provider.of<BookingsProvider>(context);
    final bookings = bookingsProvider.bookingList
        .where((booking) =>
            booking.dateAndTime.day == _selectedDate.day &&
            booking.dateAndTime.month == _selectedDate.month &&
            booking.dateAndTime.year == _selectedDate.year)
        .toList();

    List<Map<String, dynamic>> helperMap = [];
    print('\n\n$bookings\n\n');

    if (bookings != null && bookings.isNotEmpty) {
      helperMap = bookings
          .map((booking) => {
                'id': booking.id,
                'date': booking.dateAndTime,
              })
          .toList();
    }
    if (medicines != null && medicines.isNotEmpty) {
      helperMap.addAll(medicines.map((medicine) => {
            'id': medicine.id,
            'date': medicine.startDate,
          }));
    }

    print(helperMap);

    helperMap.sort(
      (a, b) => (a['date'] as DateTime).compareTo((b['date'] as DateTime)),
    );

    print(helperMap);

    return Container(
      height: mediaQuery.size.height - widget.appBarHeight - 35,
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        children: <Widget>[
          Material(
            elevation: 1.0,
            child: Row(
              children: <Widget>[
                Container(
                  width: 80.0,
                  height: 100.0,
                  color: Colors.blueAccent.withOpacity(0.1),
                  child: Center(
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.primaries[4],
                      size: 45.0,
                    ),
                  ),
                ),
                DatePickerTimeline(
                  _selectedDate,
                  locale: langProvider.langCode == 'ar' ? "ar_EG" : "en_US",
                  monthTextStyle: Theme.of(context).textTheme.display2,
                  dateTextStyle: Theme.of(context)
                      .textTheme
                      .body2
                      .copyWith(fontSize: 20.0, color: Colors.primaries[4]),
                  dayTextStyle: Theme.of(context)
                      .textTheme
                      .display2
                      .copyWith(fontSize: 14.0, color: Colors.black87),
                  height: 100.0,
                  width: mediaQuery.size.width - 80.0,
                  daysCount: 30,
                  selectionColor: Colors.blue,
                  onDateChange: _onDaySelected,
                ),
              ],
            ),
          ),
          helperMap != null && helperMap.isNotEmpty
              ? Expanded(
                  child: Stepper(
                    controlsBuilder: (BuildContext context,
                            {VoidCallback onStepContinue,
                            VoidCallback onStepCancel}) =>
                        Container(),
                    steps: helperMap
                        .map(
                          (med) => _generateActivites(med, medicines, bookings),
                        )
                        .toList(),
                  ),
                )
              : Expanded(
                  child: Center(
                      child: Text(labelsProvider.noActivitiesForThisDay)),
                )
        ],
      ),
    );
  }

  Step _generateActivites(
    Map<String, dynamic> helperMap,
    List<Medicine> medicines,
    List<Booking> bookings,
  ) {
    Object eventData = medicines.firstWhere(
        (medicine) => medicine.id == helperMap['id'],
        orElse: () => null);

    if (eventData == null) {
      eventData = bookings.firstWhere(
          (booking) => booking.id == helperMap['id'],
          orElse: () => null);
    }

    return Step(
      title: Text(
        eventData is Medicine
            ? _formattedTime(time: eventData.time)
            : _formattedTime(date: (eventData as Booking).dateAndTime),
        style:
            Theme.of(context).textTheme.display2.copyWith(color: Colors.black),
        textDirection: TextDirection.ltr,
      ),
      isActive: false,
      state: StepState.disabled,
      content: ActivityItemBanner(
        id: helperMap['id'],
        title: eventData is Medicine
            ? eventData.name
            : (eventData as Booking).bookingType +
                ' - ' +
                (eventData as Booking).doctorName,
        eventType:
            eventData is Medicine ? EventType.medicine : EventType.booking,
        description: eventData is Medicine
            ? eventData.notes
            : (eventData as Booking).notes,
      ),
    );
  }

  String _formattedTime({DateTime date, TimeOfDay time}) {
    int hour;
    int minute;
    String formattedHour;
    String formattedMinute;
    String timeCode;

    if (date == null) {
      hour = time.hour;
      minute = time.minute;
    }

    if (time == null) {
      hour = date.hour;
      minute = date.minute;
    }

    if (hour > 12) {
      formattedHour = '0' + (hour - 12).toString();
      timeCode = 'PM';
    } else {
      formattedHour = hour.toString();
      timeCode = 'AM';
    }

    if (minute < 10) {
      formattedMinute = '0' + minute.toString();
    } else {
      formattedMinute = minute.toString();
    }

    return '$formattedHour:$formattedMinute $timeCode';
  }

  void _onDaySelected(DateTime selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
    });
  }
}

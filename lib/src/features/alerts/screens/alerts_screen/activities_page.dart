import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

import './../../../../core/resources/labels.dart';
import './../../../../reminder_app.dart';
import './../../providers/bookings_provider.dart';
import './../../providers/medicines_provider.dart';
import './../../screens/add_activity_screen/add_activity_screen.dart';
import './../../widgets/booking_item.dart';
import './../../widgets/medicine_item.dart';
import './../../../../core/providers/language_provider.dart';

class ActivitiesPageContent extends StatelessWidget {
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

    final mediaQuery = MediaQuery.of(context);
    final medicineList = Provider.of<MedicinesProvider>(context).medicineList;
    final bookingList = Provider.of<BookingsProvider>(context).bookingList;

    return LayoutBuilder(
      builder: (ctx, constraints) => Container(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        child: Stack(
          children: [
            Container(
                height: mediaQuery.size.height,
                width: mediaQuery.size.width,
                child: LiquidPullToRefresh(
                  showChildOpacityTransition: false,
                  onRefresh: () async {
                    Provider.of<MedicinesProvider>(context, listen: false)
                        .refreshMedicineList();
                    final isConnected = await Provider.of<BookingsProvider>(
                            context,
                            listen: false)
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
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 20.0,
                          top: 20.0,
                          left: 20.0,
                          bottom: 15.0,
                        ),
                        child: Text(
                          labelsProvider.medicines,
                          style: Theme.of(context).textTheme.title,
                        ),
                      ),
                      medicineList.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(labelsProvider.noMedicinesFound),
                            )
                          : Column(
                              children: medicineList
                                  .map(
                                    (medicine) => MedicineItem(
                                      id: medicine.id,
                                      name: medicine.name,
                                      progress: medicine.progress,
                                      periodPerDays: medicine.periodPerDays,
                                    ),
                                  )
                                  .toList(),
                            ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 20.0,
                          top: 20.0,
                          left: 20.0,
                          bottom: 15.0,
                        ),
                        child: Text(
                          labelsProvider.bookings,
                          style: Theme.of(context).textTheme.title,
                        ),
                      ),
                      bookingList.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(labelsProvider.noBookingsFound),
                            )
                          : Column(
                              children: bookingList
                                  .map(
                                    (booking) => BookingItem(
                                      id: booking.id,
                                      doctorName: booking.doctorName,
                                      cost: booking.cost,
                                      date: booking.dateAndTime,
                                      bookingType: booking.bookingType,
                                    ),
                                  )
                                  .toList(),
                            ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                )),
            Container(
              margin: const EdgeInsets.only(right: 20.0, bottom: 20.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: _addNewActivityCallback,
                  child: Icon(Icons.add),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewActivityCallback() {
    Routes.sailor.navigate(AddActivityScreen.routeName);
  }
}

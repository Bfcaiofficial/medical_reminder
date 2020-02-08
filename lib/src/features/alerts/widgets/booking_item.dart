import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import './../../../core/providers/language_provider.dart';
import './../../../reminder_app.dart';
import './../providers/bookings_provider.dart';
import './../screens/edit_screen.dart';
import './../../../core/providers/notifications_provider.dart';

class BookingItem extends StatefulWidget {
  final String id;
  final String doctorName;
  final String bookingType;
  final double cost;
  final DateTime date;

  BookingItem({
    this.id,
    this.doctorName,
    this.cost,
    this.bookingType,
    this.date,
  });

  @override
  _BookingItemState createState() => _BookingItemState();
}

class _BookingItemState extends State<BookingItem> {
  bool isLoading = false;
  var labelsProvider;

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    labelsProvider = langProvider.labelsProvider;

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
                      widget.bookingType + ' - ' + widget.doctorName,
                      style: Theme.of(context).textTheme.display2.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  isLoading
                      ? CircularProgressIndicator()
                      : DropdownButton(
                          icon: Icon(Icons.more_vert),
                          underline: Container(),
                          items: [
                            DropdownMenuItem(
                              value: 'edit',
                              child: Text(
                                labelsProvider.edit,
                                style: Theme.of(context).textTheme.body2,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'del',
                              child: Text(
                                labelsProvider.delete,
                                style: Theme.of(context)
                                    .textTheme
                                    .body2
                                    .copyWith(color: Colors.red),
                              ),
                            ),
                          ],
                          onChanged: (String value) {
                            switch (value) {
                              case 'edit':
                                Routes.sailor
                                    .navigate(EditScreen.routeName, params: {
                                  'id': widget.id,
                                  'eventType': EventType.booking,
                                });
                                break;
                              case 'del':
                                _handleBookingDeleting();
                                break;
                            }
                          },
                        ),
                ],
              ),
              Text('${widget.cost} EG',
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

  void _handleBookingDeleting() {
    try {
      final bookingProvider = Provider.of<BookingsProvider>(
        context,
        listen: false,
      );

      final booking = bookingProvider.bookingList.firstWhere(
        (bookingData) => bookingData.id == widget.id,
      );
      isLoading = true;
      setState(() {});

      final notificationsProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      notificationsProvider.removeNotificationsOf(booking.id);

      bookingProvider.removeBooking(booking.idOnServer).then((isConnected) {
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
        stopLoading();
      });
    } on HttpException catch (error) {
      Flushbar(
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ),
        messageText: Text(
          error.message,
          style: Theme.of(context)
              .textTheme
              .display1
              .copyWith(color: Colors.white),
        ),
        duration: Duration(seconds: 3),
      )..show(context);
    }
  }

  String _formatDate() {
    final hour = widget.date.hour;
    final minute = widget.date.minute;
    final formattedDate = intl.DateFormat.yMd().format(widget.date);
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

  void stopLoading() {
    setState(() {
      isLoading = false;
    });
  }
}

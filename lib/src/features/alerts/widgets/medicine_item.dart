import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../../../core/providers/language_provider.dart';
import './../../../core/resources/labels.dart';
import './../../../reminder_app.dart';
import './../providers/medicines_provider.dart';
import './../screens/edit_screen.dart';
import './../../../core/providers/notifications_provider.dart';

class MedicineItem extends StatefulWidget {
  final String id;
  final String name;
  final int progress;
  final int periodPerDays;

  MedicineItem({this.id, this.name, this.progress, this.periodPerDays});

  @override
  _MedicineItemState createState() => _MedicineItemState();
}

class _MedicineItemState extends State<MedicineItem> {
  bool isLoading = false;
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
  Widget build(BuildContext context) {
    _initializeLabelsProvider();

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
                        widget.name,
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
                                    'eventType': EventType.medicine,
                                  });
                                  break;
                                case 'del':
                                  _handleMedicineDeleting();
                                  break;
                              }
                            },
                          ),
                  ],
                ),
                Container(
                  height: 8.0,
                  width: constraints.maxWidth * 0.85,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.grey[200],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                        ),
                      ]),
                  alignment: Alignment.centerRight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: FractionallySizedBox(
                      widthFactor: widget.progress / widget.periodPerDays,
                      child: Container(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      labelsProvider.progress,
                      style: Theme.of(context).textTheme.body1.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    Text(
                      '  ${widget.periodPerDays}/${widget.progress}  ',
                      style: Theme.of(context).textTheme.body1.copyWith(
                            color: Colors.grey[600],
                          ),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }

  void _handleMedicineDeleting() {
    try {
      final medicineProvider = Provider.of<MedicinesProvider>(
        context,
        listen: false,
      );
      isLoading = true;
      setState(() {});

      final medicine = medicineProvider.medicineList.firstWhere(
        (med) => med.id == widget.id,
      );

      final notificationsProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      notificationsProvider.removeNotificationsOf(medicine.id);

      medicineProvider.removeMedicine(medicine.idOnServer).then((isConnected) {
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

  void stopLoading() {
    setState(() {
      isLoading = false;
    });
  }
}

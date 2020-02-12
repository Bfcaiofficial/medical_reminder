import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../../../core/resources/labels.dart';
import './../screens/add_activity_screen/add_doctor_appointment_page.dart';
import './../screens/add_activity_screen/add_medicine_page.dart';
import './../../../core/providers/language_provider.dart';

class EditScreen extends StatelessWidget {
  static const String routeName = '/edit-activity';
  final EventType eventType;
  final String id;
  var labelsProvider;
  var langProvider;

  EditScreen({this.eventType, this.id});

  void _initializeLabelsProvider(context) {
    langProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;
  }

  @override
  Widget build(BuildContext context) {
    _initializeLabelsProvider(context);

    return Directionality(
      textDirection:
          langProvider.langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            labelsProvider.editActivity,
            style: Theme.of(context).textTheme.title,
          ),
        ),
        body: eventType == EventType.medicine
            ? AddMedicinePage(id: id)
            : AddDoctorAppointmentPage(id: id),
      ),
    );
  }
}

enum EventType {
  medicine,
  booking,
}

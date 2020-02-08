import 'package:flutter/material.dart';
import 'package:medical_reminder/src/core/providers/language_provider.dart';
import 'package:provider/provider.dart';

import './../../../../core/resources/labels.dart';
import './add_medicine_page.dart';
import './add_doctor_appointment_page.dart';

class AddActivityScreen extends StatelessWidget {
  static const String routeName = '/add_activity';
  var labelsProvider;
  var langProvider;

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
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              labelsProvider.addActivity,
              style: Theme.of(context).textTheme.title,
            ),
            bottom: TabBar(
              unselectedLabelColor: Colors.grey[300],
              labelColor: Theme.of(context).accentColor,
              unselectedLabelStyle: Theme.of(context).textTheme.display1,
              labelStyle: Theme.of(context).textTheme.display1,
              tabs: <Widget>[
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      labelsProvider.medicine,
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      labelsProvider.doctorAppointment,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              AddMedicinePage(),
              AddDoctorAppointmentPage(),
            ],
          ),
        ),
      ),
    );
  }
}

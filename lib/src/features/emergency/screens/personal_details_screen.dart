import 'package:flutter/material.dart';
import 'package:medical_reminder/src/features/emergency/providers/personal_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import './../../../core/providers/language_provider.dart';
import './../../../core/resources/labels.dart';

class PersonalDetailsScreen extends StatelessWidget {
  static const String routeName = '/personal-details';
  LanguageProvider langProvider;
  var labelsProvider;
  PersonalDataProvider dataProvider;

  void _initializeLabelsProvider(context) {
    langProvider = Provider.of<LanguageProvider>(context, listen: false);
    dataProvider = Provider.of<PersonalDataProvider>(context, listen: false);

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;
  }

  @override
  Widget build(BuildContext context) {
    _initializeLabelsProvider(context);

    final personalData = dataProvider.personalData;

    return Directionality(
      textDirection:
          langProvider.langCode == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            labelsProvider.personalData,
            style: Theme.of(context).textTheme.title,
          ),
        ),
        body: Center(
          child: personalData == null
              ? Text(labelsProvider.noPersonalDataAdded)
              : SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          labelsProvider.theName,
                          style: Theme.of(context).textTheme.title,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          personalData.name,
                          style: Theme.of(context).textTheme.display2,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          labelsProvider.address,
                          style: Theme.of(context).textTheme.title,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          personalData.address,
                          style: Theme.of(context).textTheme.display2,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          labelsProvider.bloodType,
                          style: Theme.of(context).textTheme.title,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          personalData.bloodType.toUpperCase(),
                          style: Theme.of(context).textTheme.display2,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          labelsProvider.phoneNumbersForEmergencyCases,
                          style: Theme.of(context).textTheme.title,
                          textAlign: TextAlign.center,
                        ),
                        InkWell(
                          onTap: () async {
                            if (await canLaunch(
                                'tel: ${personalData.phoneNumber}')) {
                              launch('tel: ${personalData.phoneNumber}');
                            }
                          },
                          child: Text(
                            personalData.phoneNumber,
                            style: Theme.of(context).textTheme.display2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          labelsProvider.previousNotes,
                          style: Theme.of(context).textTheme.title,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          personalData.previousDiagnosesAndNotes,
                          style: Theme.of(context).textTheme.display2,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../../../core/providers/language_provider.dart';
import './../../../core/resources/labels.dart';
import './../providers/personal_data_provider.dart';
import './../screens/add_emergency_data_screen.dart';

class PersonalDataAddedCard extends StatelessWidget {
  var labelsProvider;
  var langProvider;
  final String id;
  final bool enabled;
  final Function() refreshEmergencyScreen;

  PersonalDataAddedCard({
    this.id,
    @required this.enabled,
    this.refreshEmergencyScreen,
  });

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

    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
      child: Card(
        child: enabled
            ? Padding(
                padding: EdgeInsets.only(
                  left: isArabic ? 5.0 : 15.0,
                  right: isArabic ? 15.0 : 0.5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      labelsProvider.youHaveAddedYourInfo,
                      style: TextStyle(color: Colors.blue),
                    ),
                    DropdownButton(
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return AddEmergencyDataScreen(
                                    id: id,
                                  );
                                },
                              ),
                            );
                            break;
                          case 'del':
                            final dataPtovider =
                                Provider.of<PersonalDataProvider>(context,
                                    listen: false);
                            dataPtovider.removePersonalData();

                            refreshEmergencyScreen();

                            break;
                        }
                      },
                    ),
                  ],
                ),
              )
            : Container(
                color: Colors.grey,
                height: 40.0,
              ),
      ),
    );
  }

  bool get isArabic => langProvider.langCode == 'ar';
}

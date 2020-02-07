import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:medical_reminder/src/features/vaccinations/models/child_data.dart';
import 'package:medical_reminder/src/features/vaccinations/providers/vaccinations_provider.dart';
import 'package:provider/provider.dart';

import './../../../core/providers/language_provider.dart';
import './../../../core/resources/labels.dart';
import './../widgets/vaccination_radio_row.dart';
import './../models/child_data.dart';

class VaccinationsProgressDetails extends StatelessWidget {
  static const String routeName = '/vaccinations-details';

  final String id;

  VaccinationsProgressDetails({@required this.id});

  LanguageProvider langProvider;
  var labelsProvider;
  VaccinationsProvider childrenDataProvider;
  ChildData childData;

  void _initializeLabelsProvider(context) {
    this.context = context;
    langProvider = Provider.of<LanguageProvider>(context, listen: false);

    childrenDataProvider = Provider.of<VaccinationsProvider>(context);

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;
  }

  BuildContext context;
  @override
  Widget build(BuildContext context) {
    _initializeLabelsProvider(context);

    childData =
        childrenDataProvider.childrenList.firstWhere((child) => child.id == id);

    int childAge = DateTime.now().difference(childData.birthdate).inDays;
    String agePostfix;
    final childGender = childData.gender.toLowerCase() == 'male'
        ? labelsProvider.male
        : labelsProvider.female;

    if (childAge < 365) {
      agePostfix = childAge < 11 ? labelsProvider.days : labelsProvider.day;
    } else {
      childAge ~/= 365;
      agePostfix = labelsProvider.years;
    }

    return Directionality(
      textDirection:
          langProvider.langCode == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            labelsProvider.vaccinations,
            style: Theme.of(context).textTheme.title,
          ),
          // actions: <Widget>[
          //   IconButton(
          //       icon: Icon(Icons.mode_edit),
          //       onPressed: () => debugPrint('Alarm')),
          // ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "${labelsProvider.theName} :  ${childData.name}",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.title,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "${labelsProvider.age}  : $childAge $agePostfix",
                        style: Theme.of(context).textTheme.title,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "${labelsProvider.gender} :  ${childGender}",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.title,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 30, 5, 0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            labelsProvider.progress,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.title,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 8.0,
                              width: MediaQuery.of(context).size.width * 0.85,
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
                                  widthFactor: childData.progress / 27,
                                  child: Container(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  labelsProvider.vaccinations,
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _generateVaccinationList,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> get _generateVaccinationList {
    List<Widget> vaccinationsList = List.generate(27, (index) {
      return VaccinationRadioRow(
        title: arrangedVaccinationsTitles[index],
        radioValue: index,
        onValueChanged: _onVaccinationTaked,
        isClicked: childData.progress > index,
      ) as Widget;
    }).toList();

    vaccinationsList.insert(
      0,
      _builVaccinationPerioddTitle(labelsProvider.afterOneMonth),
    );

    vaccinationsList.insert(
      6,
      _builVaccinationPerioddTitle(labelsProvider.afterTwoMonths),
    );

    vaccinationsList.insert(
      12,
      _builVaccinationPerioddTitle(labelsProvider.afterThreeMonths),
    );

    vaccinationsList.insert(
      18,
      _builVaccinationPerioddTitle(labelsProvider.afterFourMonths),
    );

    vaccinationsList.insert(
      20,
      _builVaccinationPerioddTitle(labelsProvider.afterFiveMonths),
    );

    vaccinationsList.insert(
      24,
      _builVaccinationPerioddTitle(labelsProvider.afterSixMonths),
    );

    vaccinationsList.insert(
      29,
      _builVaccinationPerioddTitle(labelsProvider.afterSevenMonths),
    );

    return vaccinationsList;
  }

  bool _onVaccinationTaked(int count) {
    if (count == (childData.progress)) {
      childData.progress += 1;
      childrenDataProvider.updateChildData(childData.idOnServer, childData);
      return true;
    } else {
      Flushbar(
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ),
        messageText: Text(
          labelsProvider.mustTakePreviousVaccinationsFirst,
          style: Theme.of(context)
              .textTheme
              .display1
              .copyWith(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
      )..show(context);
      return false;
    }
  }

  Widget _builVaccinationPerioddTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Text(
        title,
        textAlign: TextAlign.start,
        style:
            Theme.of(context).textTheme.display2.copyWith(color: Colors.black),
      ),
    );
  }
}

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/resources/labels.dart';
import './../models/personal_data.dart';
import './../providers/personal_data_provider.dart';

class AddEmergencyDataScreen extends StatelessWidget {
  double sensitivity;
  final String id;

  AddEmergencyDataScreen({
    this.sensitivity,
    this.id,
  });

  var langProvider;
  var labelsProvider;
  final TextEditingController nameFieldController = TextEditingController();
  final TextEditingController addressFieldController = TextEditingController();
  final TextEditingController bloodTypeFieldController =
      TextEditingController();
  final TextEditingController phoneFieldController = TextEditingController();
  final TextEditingController notesFieldController = TextEditingController();

  void _initializeLabelsProvider(context) {
    langProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;
  }

  bool dataLoaded = false;
  @override
  Widget build(BuildContext context) {
    _initializeLabelsProvider(context);

    if (id != null && !dataLoaded) {
      final data = Provider.of<PersonalDataProvider>(context, listen: false)
          .personalData;
      sensitivity = data.shakeSensitivity;
      nameFieldController.text = data.name;
      addressFieldController.text = data.address;
      bloodTypeFieldController.text = data.bloodType;
      phoneFieldController.text = data.phoneNumber;
      notesFieldController.text = data.previousDiagnosesAndNotes;
      dataLoaded = true;
    }

    return Directionality(
      textDirection:
          langProvider.langCode == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            labelsProvider.emergencyData,
            style: Theme.of(context).textTheme.title,
          ),
          backgroundColor: Colors.white,
          elevation: 3,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Theme(
                      data: ThemeData(primaryColor: Colors.blueAccent),
                      child: TextField(
                        controller: nameFieldController,
                        decoration: InputDecoration(
                          labelText: labelsProvider.theName,
                          labelStyle: Theme.of(context).textTheme.display1,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Theme(
                      data: ThemeData(primaryColor: Colors.blueAccent),
                      child: TextField(
                        controller: addressFieldController,
                        decoration: InputDecoration(
                          labelText: labelsProvider.address,
                          labelStyle: Theme.of(context).textTheme.display1,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Theme(
                      data: ThemeData(primaryColor: Colors.blueAccent),
                      child: TextField(
                        controller: bloodTypeFieldController,
                        decoration: InputDecoration(
                          labelText: labelsProvider.bloodType,
                          labelStyle: Theme.of(context).textTheme.display1,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Theme(
                      data: ThemeData(primaryColor: Colors.blueAccent),
                      child: TextField(
                        controller: phoneFieldController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText:
                              labelsProvider.phoneNumbersForEmergencyCases,
                          labelStyle: Theme.of(context).textTheme.display1,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                            ),
                          ),
                          icon: Icon(Icons.add),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Theme(
                      data: ThemeData(primaryColor: Colors.blueAccent),
                      child: TextField(
                        controller: notesFieldController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: labelsProvider.previousNotes,
                          labelStyle: Theme.of(context).textTheme.display1,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
                RaisedButton(
                  onPressed: () {
                    _savePersonalData(context);
                  },
                  color: Color(0xFF001737),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      labelsProvider.save,
                      style: Theme.of(context)
                          .textTheme
                          .title
                          .copyWith(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _savePersonalData(context) {
    if (nameFieldController.text.trim().isEmpty ||
        addressFieldController.text.trim().isEmpty ||
        bloodTypeFieldController.text.trim().isEmpty ||
        phoneFieldController.text.trim().isEmpty ||
        notesFieldController.text.trim().isEmpty) {
      Flushbar(
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ),
        messageText: Text(
          labelsProvider.fieldsMustBeFilled,
          style: Theme.of(context)
              .textTheme
              .display1
              .copyWith(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
      )..show(context);
      return;
    }

    final newPersonalData = PersonalData(
      name: nameFieldController.text.trim(),
      bloodType: bloodTypeFieldController.text.trim(),
      address: addressFieldController.text.trim(),
      phoneNumber: phoneFieldController.text.trim(),
      previousDiagnosesAndNotes: notesFieldController.text.trim(),
      shakeSensitivity: sensitivity,
      isDeviceShakeFeatureEnabled: true,
    );
    final dataProvider =
        Provider.of<PersonalDataProvider>(context, listen: false);

    if (id != null) {
      dataProvider.updatePersonalData(newPersonalData);
    } else {
      dataProvider.savePersonalData(newPersonalData);
    }

    dataProvider.enableDeviceShakeFeature(
      newPersonalData.isDeviceShakeFeatureEnabled,
    );

    Navigator.pop(context);
  }
}

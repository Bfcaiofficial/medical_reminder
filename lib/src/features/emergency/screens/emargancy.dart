import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import './../../../core/providers/language_provider.dart';
import './../../../core/resources/labels.dart';
import './../providers/personal_data_provider.dart';
import './../widgets/personal_data_added_card.dart';
import '../models/personal_data.dart';
import './add_emergency_data_screen.dart';

class Emergancy extends StatefulWidget {
  static const String routeName = '/emergency-screen';
  @override
  _EmergancyState createState() => _EmergancyState();
}

class _EmergancyState extends State<Emergancy>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  bool isDeviceShakeEnabled;
  double deviceShakeSensitivity;
  List<Map<String, String>> _emergencNumbers;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    tabController.dispose();

    super.dispose();
  }

  var labelsProvider;
  LanguageProvider langProvider;
  PersonalDataProvider dataProvider;

  _refreshScreen() {
    setState(() {
      deviceShakeSensitivity = dataProvider.getLocallyStoredSensitivity();
    });
  }

  int count = 0;
  void _initializeLabelsProvider() {
    langProvider = Provider.of<LanguageProvider>(context, listen: false);
    dataProvider = Provider.of<PersonalDataProvider>(context, listen: false);

    if (count == 0) {
      isDeviceShakeEnabled = dataProvider.isDeviceShakeFeatureEnabled;
      if (dataProvider.personalData != null) {
        deviceShakeSensitivity = dataProvider.personalData.shakeSensitivity;
      } else {
        deviceShakeSensitivity =
            dataProvider.getLocallyStoredSensitivity() ?? 20.0;
      }
      count++;
    }

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;

    _emergencNumbers = [
      {
        'name': labelsProvider.ambulance,
        'phoneNumber': labelsProvider.ambulanceNumber,
      },
      {
        'name': labelsProvider.amortization,
        'phoneNumber': labelsProvider.amortizationNumber,
      },
      {
        'name': labelsProvider.police,
        'phoneNumber': labelsProvider.policeNumber,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    _initializeLabelsProvider();

    return Directionality(
      textDirection:
          langProvider.langCode == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: tabController,
            unselectedLabelColor: Colors.grey[300],
            labelColor: Theme.of(context).accentColor,
            unselectedLabelStyle: Theme.of(context).textTheme.display1,
            labelStyle: Theme.of(context).textTheme.display1,
            tabs: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  labelsProvider.emergencyData,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  labelsProvider.emergencyPhoneNumbers,
                ),
              ),
            ],
          ),
          title: Text(labelsProvider.emergency,
              style: Theme.of(context).textTheme.title),
        ),
        body: TabBarView(
          controller: tabController,
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SwitchListTile(
                    value: isDeviceShakeEnabled,
                    onChanged: (value) async {
                      // if (value) {
                      //   final permissionResult = await PermissionHandler()
                      //       .requestPermissions([PermissionGroup.phone]);
                      //   if (permissionResult[PermissionGroup.phone] !=
                      //       PermissionStatus.granted) {
                      //     Flushbar(
                      //       icon: Icon(
                      //         Icons.error,
                      //         color: Colors.red,
                      //       ),
                      //       messageText: Text(
                      //         labelsProvider.phonePermissionRequired,
                      //         style: Theme.of(context)
                      //             .textTheme
                      //             .display1
                      //             .copyWith(color: Colors.white),
                      //       ),
                      //       duration: Duration(seconds: 2),
                      //     )..show(context);
                      //     return;
                      //   }
                      // }
                      setState(() {
                        isDeviceShakeEnabled = value;
                      });

                      final personalData = dataProvider.personalData;

                      dataProvider.enableDeviceShakeFeature(value);

                      if (personalData != null) {
                        dataProvider.updatePersonalData(
                          PersonalData(
                            id: personalData.id,
                            name: personalData.name,
                            bloodType: personalData.bloodType,
                            address: personalData.address,
                            phoneNumber: personalData.phoneNumber,
                            previousDiagnosesAndNotes:
                                personalData.previousDiagnosesAndNotes,
                            shakeSensitivity: personalData.shakeSensitivity,
                            isDeviceShakeFeatureEnabled: value,
                          ),
                        );
                      }
                    },
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        labelsProvider.activateEmergencyDataFeature,
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(labelsProvider.emergencyDataDescription),
                    ),
                  ),
                  Consumer<PersonalDataProvider>(
                    builder: (ctx, provider, child) {
                      if (provider.personalData == null) {
                        return Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: RaisedButton(
                            child: Text(
                              labelsProvider.addYourInfo,
                              style: Theme.of(context).textTheme.body1.copyWith(
                                    color: isDeviceShakeEnabled
                                        ? Theme.of(context).accentColor
                                        : Colors.black,
                                  ),
                            ),
                            onPressed: isDeviceShakeEnabled
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AddEmergencyDataScreen(
                                            sensitivity: deviceShakeSensitivity,
                                          );
                                        },
                                      ),
                                    );
                                  }
                                : null,
                            color: Colors.white,
                          ),
                        );
                      }
                      return PersonalDataAddedCard(
                        id: 'id',
                        enabled: isDeviceShakeEnabled,
                        refreshEmergencyScreen: _refreshScreen,
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: isArabic ? 18.0 : 0.0,
                      left: isArabic ? 0.0 : 18.0,
                    ),
                    child: Text(
                      labelsProvider.appVibrationSensitivity,
                      style: Theme.of(context).textTheme.body1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      labelsProvider.vibrationSensitivityRangeDescription,
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.grey),
                    ),
                  ),
                  Slider(
                    value: deviceShakeSensitivity,
                    min: 0.0,
                    max: 20.0,
                    activeColor: isDeviceShakeEnabled
                        ? Theme.of(context).accentColor
                        : Colors.grey,
                    inactiveColor: Colors.grey,
                    divisions: 4,
                    onChanged: (double newvalue) {
                      if (isDeviceShakeEnabled) {
                        setState(() {
                          deviceShakeSensitivity = newvalue;
                        });
                        final personalData = dataProvider.personalData;

                        if (personalData != null) {
                          dataProvider.updatePersonalData(
                            PersonalData(
                              id: personalData.id,
                              name: personalData.name,
                              bloodType: personalData.bloodType,
                              address: personalData.address,
                              phoneNumber: personalData.phoneNumber,
                              previousDiagnosesAndNotes:
                                  personalData.previousDiagnosesAndNotes,
                              shakeSensitivity: deviceShakeSensitivity,
                              isDeviceShakeFeatureEnabled: isDeviceShakeEnabled,
                            ),
                          );
                        } else {
                          dataProvider
                              .setLocalSensitivity(deviceShakeSensitivity);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            Container(
              child: ListView.builder(
                itemCount: _emergencNumbers.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(18.0),
                          child: Text(_emergencNumbers[index]['name']),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.phone,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            _callEmergencyNumber(context,
                                _emergencNumbers[index]['phoneNumber']);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _callEmergencyNumber(context, String phoneNumber) async {
    if (await canLaunch('tel://$phoneNumber')) {
      launch('tel://$phoneNumber');
    } else {
      Flushbar(
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ),
        messageText: Text(
          'Could not call $phoneNumber',
          style: Theme.of(context)
              .textTheme
              .display1
              .copyWith(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
      )..show(context);
    }
  }

  bool get isArabic => langProvider.langCode == 'ar';
}

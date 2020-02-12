import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:medical_reminder/src/core/screens/profile.dart';
import 'package:provider/provider.dart';
import 'package:shake_event/shake_event.dart';

import './../../core/resources/labels.dart';
import './../providers/language_provider.dart';
import './../providers/notifications_provider.dart';
import './main_page_content.dart';
import './more_page_content.dart';
import './notifications_screen.dart';
import './../../features/emergency/providers/personal_data_provider.dart';
import './../../features/emergency/screens/personal_details_screen.dart';
import './../../reminder_app.dart';
import './../providers/auth_access_token_provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with ShakeHandler {
  int _selectedItemIndex = 0;
  var labelsProvider;
  var notifications;
  PersonalDataProvider personalDataProvider;
  List<Map<String, dynamic>> _pages;
  int loginOption;

  NotificationDetails platformChannelSpecifics;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void didChangeDependencies() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (_, __, ___, ____) {});
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (_) {
      // Routes.sailor
      //     .navigate(PersonalDetailsScreen.routeName)
      //     .then((_) => isEmergencyCaseHandled = false);
    });

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      DateTime.now().toString(),
      'WARNNING: Emergency Case',
      'Press to open emergency data',
      sound: 'notification_sound',
      importance: Importance.Max,
      priority: Priority.High,
      autoCancel: true,
      groupKey: DateTime.now().toString(),
      enableVibration: true,
    );

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails(
      sound: 'notification_sound.aiff',
    );

    platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    super.didChangeDependencies();
  }

  void _initializeLabelsProvider() {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    final notificationsProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    final accesTokenProvider =
        Provider.of<AuthAccessTokenProvider>(context, listen: false);
    accesTokenProvider.getLoginOption().then((option) => loginOption = option);

    notificationsProvider.refreshNotificationList().then((_) {
      notifications = notificationsProvider.getTodayNotifications();
    });

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;

    _pages = [
      {
        'title': labelsProvider.mainPageLabel,
        'icon': Icons.home,
        'pageContent': MainPageContent(),
      },
      {
        'title': labelsProvider.notificationsPageLabel,
        'icon': Icons.notifications,
        'pageContent': NotificationsScreen(),
      },
      {
        'title': labelsProvider.profilePageLabel,
        'icon': Icons.person_pin,
        'pageContent': loginOption == 0
            ? Profile()
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).accentColor,
                        radius: 30.0,
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      accesTokenProvider.getEmailAddress(),
                      style: Theme.of(context).textTheme.display2,
                    ),
                  ],
                ),
              ),
      },
      {
        'title': labelsProvider.morePageLabel,
        'icon': Icons.more_horiz,
        'pageContent': Center(child: MorePageContent(
          refreshUiWithNewLanguage: () {
            setState(() {});
          },
        )),
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    _initializeLabelsProvider();
    personalDataProvider =
        Provider.of<PersonalDataProvider>(context, listen: false);

    if (!personalDataProvider.isDataLoaded) {
      personalDataProvider.getPersonalData().then((_) {
        if (personalDataProvider.personalData != null) {
          personalDataProvider.enableDeviceShakeFeature(
            personalDataProvider.personalData.isDeviceShakeFeatureEnabled,
          );

          final sensitivty = personalDataProvider.personalData.shakeSensitivity;

          if (personalDataProvider.personalData.isDeviceShakeFeatureEnabled)
            startListeningShake(120.0 - sensitivty);
          else {
            resetShakeListeners();
          }
        } else {
          final isEnabledLocally =
              personalDataProvider.isDeviceShakeEnabledLocaly();
          personalDataProvider.enableDeviceShakeFeature(isEnabledLocally);
          if (personalDataProvider.isDeviceShakeFeatureEnabled) {
            startListeningShake(
                120 - personalDataProvider.getLocallyStoredSensitivity());
            print('Device shake feature enabled');
          } else {
            resetShakeListeners();
            print('Device shake feature disabled');
          }
        }
      });
    } else {
      if (personalDataProvider.personalData != null) {
        if (personalDataProvider.personalData.isDeviceShakeFeatureEnabled) {
          resetShakeListeners();
          startListeningShake(
            120.0 - personalDataProvider.personalData.shakeSensitivity,
          );

          print('Device shake feature enabled');
        } else {
          resetShakeListeners();
          print('Device shake feature disabled');
        }
      } else {
        final isEnabledLocally =
            personalDataProvider.isDeviceShakeEnabledLocaly();
        personalDataProvider.enableDeviceShakeFeature(isEnabledLocally);
        if (personalDataProvider.isDeviceShakeFeatureEnabled) {
          startListeningShake(
              120 - personalDataProvider.getLocallyStoredSensitivity());
          print('Device shake feature enabled');
        } else {
          resetShakeListeners();
          print('Device shake feature disabled');
        }
      }
    }

    return Scaffold(
      bottomNavigationBar: _buildBottomAppBar(),
      body: _generateCurrentBodyContent(),
    );
  }

  Widget _generateCurrentBodyContent() {
    return _pages[_selectedItemIndex]['pageContent'];
  }

  Widget _buildBottomAppBar() {
    return BottomNavigationBar(
      elevation: 15.0,
      backgroundColor: Theme.of(context).primaryColor,
      currentIndex: _selectedItemIndex,
      selectedItemColor: Theme.of(context).accentColor,
      unselectedItemColor: Colors.grey[700],
      showUnselectedLabels: true,
      items: _pages
          .map(
            (page) => BottomNavigationBarItem(
              title: Text(
                page['title'],
              ),
              icon: Consumer<NotificationProvider>(
                builder: (ctx, provider, child) {
                  return Icons.notifications == page['icon']
                      ? Stack(
                          children: <Widget>[
                            Align(
                                alignment: Alignment.center,
                                child: Icon(page['icon'])),
                            notifications != null && notifications.isNotEmpty
                                ? Align(
                                    alignment: Alignment.center,
                                    child: CircleAvatar(
                                      radius: 6,
                                      backgroundColor: Colors.red,
                                    ),
                                  )
                                : Container(),
                          ],
                        )
                      : Icon(page['icon']);
                },
              ),
            ),
          )
          .toList(),
      onTap: _changePageContent,
    );
  }

  void _changePageContent(int index) {
    setState(() {
      _selectedItemIndex = index;
    });
  }

  bool isEmergencyCaseHandled = false;

  @override
  shakeEventListener() async {
    print('Device Shakes');

    // intents.Intent()
    //   ..setAction(intent_actions.Action.ACTION_CALL)
    //   ..setData(Uri(scheme: 'tel', path: '0123456789'))
    //   ..startActivity().catchError((e) => print(e));

    if (!isEmergencyCaseHandled) {
      final emergencyData = personalDataProvider.personalData;
      if (emergencyData != null && emergencyData.phoneNumber.isNotEmpty) {
        final location = await Geolocator().getCurrentPosition();
        String locationUrl =
            'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
        final emergencyMessage = """
          \n\nEMERGENCY MESSAGE - HELP NEEDDED!!
          \n\n${emergencyData.name} needs help from you, He is in danger now.
          \n\nHis Data:
          \nname: ${emergencyData.name},
          \naddress: ${emergencyData.address},
          \nbloodType: ${emergencyData.bloodType},
          \nprevoius Diagnoses: ${emergencyData.previousDiagnosesAndNotes},
          \n\n
          \n\nرسالة طوارئ - المساعدة مطلوبة
          \n\n${emergencyData.name} يحتاج مساعدتك انه فى خطر الان.
          \n\nبياناته:
          \nname: ${emergencyData.name},
          \naddress: ${emergencyData.address},
          \nbloodType: ${emergencyData.bloodType},
          \nprevoius Diagnoses: ${emergencyData.previousDiagnosesAndNotes},

          Location: $locationUrl
          """;

        personalDataProvider
            .sendEmergencyMessage(
          emergencyMessage,
          emergencyData.phoneNumber,
        )
            .then((responseMessage) {
          Flushbar(
            icon: Icon(
              responseMessage.startsWith('Emergency')
                  ? Icons.done
                  : Icons.error,
              color: responseMessage.startsWith('Emergency')
                  ? Colors.green
                  : Colors.red,
            ),
            messageText: Text(
              responseMessage,
              style: Theme.of(context)
                  .textTheme
                  .display1
                  .copyWith(color: Colors.white),
            ),
            duration: Duration(seconds: 5),
          )..show(context);
        }).catchError((error) => print(error.message));
      }

      Routes.sailor
          .navigate(PersonalDetailsScreen.routeName)
          .then((_) => isEmergencyCaseHandled = false);

      flutterLocalNotificationsPlugin.show(
        1111111,
        'WARNNING: Emergency Case',
        'Press to open emergency data',
        platformChannelSpecifics,
        payload: 'emergency',
      );

      isEmergencyCaseHandled = true;
    }

    return super.shakeEventListener();
  }

  @override
  void dispose() {
    resetShakeListeners();
    super.dispose();
  }
}

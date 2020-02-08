import 'package:flutter/material.dart';
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
  List<Map<String, dynamic>> _pages;

  void _initializeLabelsProvider() {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    final notificationsProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    final accesTokenProvider =
        Provider.of<AuthAccessTokenProvider>(context, listen: false);

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
        'pageContent': Profile(),
        // 'pageContent': Center(
        //     child: Column(
        //   mainAxisSize: MainAxisSize.min,
        //   children: <Widget>[
        //     Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: CircleAvatar(
        //         backgroundColor: Theme.of(context).accentColor,
        //         radius: 30.0,
        //         child: Center(
        //           child: Icon(
        //             Icons.person,
        //             size: 40,
        //           ),
        //         ),
        //       ),
        //     ),
        //     SizedBox(
        //       height: 10.0,
        //     ),
        //     Text(
        //       accesTokenProvider.getEmailAddress(),
        //       style: Theme.of(context).textTheme.display2,
        //     ),
        //   ],
        // )),
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
    final personalDataProvider =
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
      isEmergencyCaseHandled = true;
      Routes.sailor
          .navigate(PersonalDetailsScreen.routeName)
          .then((_) => isEmergencyCaseHandled = false);
    }

    return super.shakeEventListener();
  }

  @override
  void dispose() {
    resetShakeListeners();
    super.dispose();
  }
}

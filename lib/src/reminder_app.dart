import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sailor/sailor.dart';

import './core/providers/auth_access_token_provider.dart';
import './core/providers/language_provider.dart';
import './core/providers/notifications_provider.dart';
import './core/screens/home_screen.dart';
import './features/alerts/providers/bookings_provider.dart';
import './features/alerts/providers/medicines_provider.dart';
import './features/alerts/screens/add_activity_screen/add_activity_screen.dart';
import './features/alerts/screens/alerts_screen/alerts_page.dart';
import './features/alerts/screens/edit_screen.dart';
import './features/emergency/providers/personal_data_provider.dart';
import './features/emergency/screens/emargancy.dart';
import './features/emergency/screens/personal_details_screen.dart';
import './features/hospitals/providers/hospitals_provider.dart';
import './features/hospitals/screens/hospital_details_screen.dart';
import './features/hospitals/screens/hospitals_screen.dart';
import './features/login/screens/login.dart';
import './features/vaccinations/screens/vaccinations_screen.dart';
import './features/vaccinations/providers/vaccinations_provider.dart';
import './features/vaccinations/screens/vaccinations_progress_details.dart';

class MedicalReminderApp extends StatelessWidget {
  final MaterialColor primaryWhite = MaterialColor(
    _blackPrimaryValue,
    <int, Color>{
      50: Color(0xFFFFFFFF),
      100: Color(0xFFFFFFFF),
      200: Color(0xFFFFFFFF),
      300: Color(0xFFFFFFFF),
      400: Color(0xFFFFFFFF),
      500: Color(_blackPrimaryValue),
      600: Color(0xFFFFFFFF),
      700: Color(0xFFFFFFFF),
      800: Color(0xFFFFFFFF),
      900: Color(0xFFFFFFFF),
    },
  );
  static const int _blackPrimaryValue = 0xFFFFFFFF;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VaccinationsProvider>(
      create: (_) => VaccinationsProvider(),
      child: ChangeNotifierProvider<PersonalDataProvider>(
        create: (_) => PersonalDataProvider(),
        child: ChangeNotifierProvider<AuthAccessTokenProvider>(
          create: (_) => AuthAccessTokenProvider(),
          child: ChangeNotifierProvider<NotificationProvider>(
            create: (_) => NotificationProvider(),
            child: ChangeNotifierProvider<LanguageProvider>(
              create: (_) => LanguageProvider(),
              child: ChangeNotifierProvider<HospitalsProvider>(
                create: (_) => HospitalsProvider(),
                child: ChangeNotifierProvider<BookingsProvider>(
                  create: (_) => BookingsProvider(),
                  child: ChangeNotifierProvider<MedicinesProvider>(
                    create: (_) => MedicinesProvider(),
                    child: MaterialApp(
                      debugShowCheckedModeBanner: false,
                      home: Login(),
                      onGenerateRoute: Routes.sailor.generator(),
                      navigatorKey: Routes.sailor.navigatorKey,
                      theme: ThemeData(
                        primarySwatch: primaryWhite,
                        accentColor: Colors.blue,
                        textTheme: ThemeData.light().textTheme.copyWith(
                              display2: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 18.0,
                              ),
                              display1: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                              body1: TextStyle(
                                color: Color.fromRGBO(20, 51, 51, 1),
                                fontFamily: 'Tajawal',
                              ),
                              body2: TextStyle(
                                color: Color.fromRGBO(20, 51, 51, 1),
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.bold,
                              ),
                              title: TextStyle(
                                fontSize: 20,
                                color: Color.fromRGBO(20, 51, 51, 1),
                                fontFamily: 'ElMessiri',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Routes {
  static final Sailor sailor = Sailor();

  static void createRoutes() {
    sailor.addRoutes([
      SailorRoute(
        name: Login.routeName,
        builder: (context, args, params) {
          return Login();
        },
      ),
      SailorRoute(
        name: HomeScreen.routeName,
        builder: (context, args, params) {
          return HomeScreen();
        },
      ),
      SailorRoute(
        name: AlertsPage.routeName,
        builder: (context, args, params) {
          return AlertsPage();
        },
      ),
      SailorRoute(
        name: AddActivityScreen.routeName,
        builder: (context, args, params) {
          return AddActivityScreen();
        },
      ),
      SailorRoute(
        name: EditScreen.routeName,
        builder: (context, args, params) {
          return EditScreen(
            eventType: params.param('eventType'),
            id: params.param('id'),
          );
        },
        params: [
          SailorParam(
            name: 'id',
            isRequired: true,
          ),
          SailorParam(
            name: 'eventType',
            isRequired: true,
          ),
        ],
      ),
      SailorRoute(
        name: HospitalsScreen.routeName,
        builder: (context, args, params) {
          return HospitalsScreen();
        },
      ),
      SailorRoute(
        name: HospitalDetailsScreen.routeName,
        builder: (context, args, params) {
          return HospitalDetailsScreen(
            title: params.param('title'),
            hospitalData: params.param('data'),
          );
        },
        params: [
          SailorParam(
            name: 'title',
            isRequired: true,
          ),
          SailorParam(
            name: 'data',
            isRequired: true,
          ),
        ],
      ),
      SailorRoute(
        name: Emergancy.routeName,
        builder: (context, args, params) {
          return Emergancy();
        },
      ),
      SailorRoute(
        name: PersonalDetailsScreen.routeName,
        builder: (context, args, params) {
          return PersonalDetailsScreen();
        },
      ),
      SailorRoute(
        name: VaccinationsScreen.routeName,
        builder: (context, args, params) {
          return VaccinationsScreen();
        },
      ),
      SailorRoute(
        name: VaccinationsProgressDetails.routeName,
        builder: (ctext, args, params) {
          return VaccinationsProgressDetails(
            id: params.param('id'),
          );
        },
        params: [
          SailorParam(name: 'id', isRequired: true),
        ],
      ),
    ]);
  }
}

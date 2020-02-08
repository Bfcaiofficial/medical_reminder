import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../features/vaccinations/providers/vaccinations_provider.dart';
import 'package:provider/provider.dart';
import 'package:sailor/sailor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './../providers/auth_access_token_provider.dart';
import './../providers/language_provider.dart';
import './../../features/alerts/providers/medicines_provider.dart';
import './../../features/login/screens/login.dart';
import './../../reminder_app.dart';
import './../providers/notifications_provider.dart';

class MorePageContent extends StatefulWidget {
  final Function() refreshUiWithNewLanguage;

  MorePageContent({this.refreshUiWithNewLanguage});
  @override
  _MorePageContentState createState() => _MorePageContentState();
}

class _MorePageContentState extends State<MorePageContent> {
  var langProvider;
  final _auth = FirebaseAuth.instance;
  final _googleSingIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    langProvider = Provider.of<LanguageProvider>(context, listen: false);

    return Center(
      child: Directionality(
        textDirection: langProvider.langCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: 60.0,
              margin: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                  width: 1.0,
                  color: Colors.grey[200],
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8.0,
                    color: Colors.grey[200],
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _changeAppLanguage,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 15.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.settings,
                          ),
                          SizedBox(
                            width: 15.0,
                          ),
                          Text(
                            langProvider.labelsProvider.changeLanguageLabel,
                            style: Theme.of(context).textTheme.title,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 60.0,
              margin: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                  width: 1.0,
                  color: Colors.grey[200],
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8.0,
                    color: Colors.grey[200],
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final authProvider = Provider.of<AuthAccessTokenProvider>(
                          context,
                          listen: false);
                      final loginOption = await authProvider.getLoginOption();

                      Provider.of<MedicinesProvider>(context, listen: false)
                          .setDataLoaded(false);
                      Provider.of<NotificationProvider>(context, listen: false)
                          .clearNotificationsOfUser();

                      Provider.of<VaccinationsProvider>(context, listen: false)
                        ..clear()
                        ..setChildrenDataLoaded(false);

                      switch (loginOption) {
                        case 0:
                          {
                            _auth.signOut().then((_) {
                              authProvider.clearAuthenticationData();
                            });
                            break;
                          }
                        case 1:
                          {
                            _googleSingIn.signOut().then((_) {
                              authProvider.clearAuthenticationData();
                            });
                            break;
                          }
                        case 2:
                          {
                            FacebookLogin().logOut().then((_) {
                              authProvider.clearAuthenticationData();
                            });
                            break;
                          }
                      }

                      FlutterLocalNotificationsPlugin().cancelAll();

                      Routes.sailor.navigate(
                        Login.routeName,
                        navigationType: NavigationType.pushAndRemoveUntil,
                        removeUntilPredicate: (_) => false,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 15.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.arrow_back,
                          ),
                          SizedBox(
                            width: 15.0,
                          ),
                          Text(
                            langProvider.labelsProvider.logout,
                            style: Theme.of(context).textTheme.title,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _changeAppLanguage() {
    if (langProvider.langCode == 'ar') {
      langProvider.setLanguage('en');
    } else {
      langProvider.setLanguage('ar');
    }
    _storeLangCodeToPreferences(langProvider.langCode).then((_) {
      print('language changed');
    });
    widget.refreshUiWithNewLanguage();
  }

  Future<bool> _storeLangCodeToPreferences(String langCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString('langCode', langCode);
  }
}

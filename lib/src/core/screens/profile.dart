import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import "package:flutter/material.dart";
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:sailor/sailor.dart';

import './../../features/alerts/providers/medicines_provider.dart';
import './../../features/emergency/providers/personal_data_provider.dart';
import './../../features/login/screens/login.dart';
import './../../features/vaccinations/providers/vaccinations_provider.dart';
import './../../reminder_app.dart';
import './../providers/auth_access_token_provider.dart';
import './../providers/notifications_provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool email = false;
  bool password = false;
  String emailT = 'Your Email';
  String passwordT = 'Your Password';
  final usercontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthAccessTokenProvider>(context, listen: false);

    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  //backgroundImage: AssetImage("assets/images/guest.bmp"),
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
                height: 15.0,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  authProvider.getEmailAddress() ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(fontSize: 18.0),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              password == false
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  '****************',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .copyWith(fontSize: 18.0),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                setState(
                                  () {
                                    password = true;
                                  },
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    )
                  : Theme(
                      data: ThemeData(
                        primaryColor: Colors.blueAccent,
                      ),
                      child: Container(
                        height: 50.0,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 10.0,
                        ),
                        child: TextField(
                          style: Theme.of(context)
                              .textTheme
                              .body1
                              .copyWith(fontSize: 18.0),
                          controller: passwordcontroller,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
              SizedBox(
                height: 20.0,
              ),
              password
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          padding: const EdgeInsets.all(10.0),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });

                            (await _auth.currentUser())
                                .updatePassword(passwordcontroller.text)
                                .then((_) async {
                              Flushbar(
                                icon: Icon(
                                  Icons.done,
                                  color: Colors.green,
                                ),
                                messageText: Text(
                                  'Password Updated successfuly. You need to login again.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .display1
                                      .copyWith(color: Colors.white),
                                ),
                                duration: Duration(seconds: 5),
                              )..show(context);

                              await Future.delayed(Duration(seconds: 2));

                              Provider.of<MedicinesProvider>(context,
                                      listen: false)
                                  .setDataLoaded(false);

                              Provider.of<PersonalDataProvider>(context,
                                      listen: false)
                                  .setDataLoaded(false);

                              Provider.of<NotificationProvider>(context,
                                      listen: false)
                                  .clearNotificationsOfUser();

                              Provider.of<VaccinationsProvider>(context,
                                  listen: false)
                                ..clear()
                                ..setChildrenDataLoaded(false);

                              _auth.signOut().then((_) {
                                authProvider.clearAuthenticationData();
                              });

                              FlutterLocalNotificationsPlugin().cancelAll();

                              setState(() {
                                _isLoading = false;
                              });

                              Routes.sailor.navigate(
                                Login.routeName,
                                navigationType:
                                    NavigationType.pushAndRemoveUntil,
                                removeUntilPredicate: (_) => false,
                              );
                            }).catchError((error) {
                              Flushbar(
                                icon: Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                                messageText: Text(
                                  error.message,
                                  style: Theme.of(context)
                                      .textTheme
                                      .display1
                                      .copyWith(color: Colors.white),
                                ),
                                duration: Duration(seconds: 5),
                              )..show(context);
                              setState(() {
                                _isLoading = false;
                              });
                            });
                          },
                          color: Colors.blue,
                          child: Text(
                            'Change Password',
                            style: Theme.of(context).textTheme.body1.copyWith(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        RaisedButton(
                          padding: const EdgeInsets.all(10.0),
                          color: Colors.blue,
                          onPressed: () {
                            setState(() {
                              password = false;
                            });
                          },
                          child: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.body1.copyWith(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

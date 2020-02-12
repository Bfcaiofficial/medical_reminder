import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:sailor/sailor.dart';

import './../../../core/providers/auth_access_token_provider.dart';
import './../../../core/providers/language_provider.dart';
import './../../../core/providers/notifications_provider.dart';
import './../../../core/resources/assets_constants.dart';
import './../../../core/resources/labels.dart';
import './../../../core/screens/home_screen.dart';
import './../../../reminder_app.dart';
import './../../alerts/providers/bookings_provider.dart';
import './../../alerts/providers/medicines_provider.dart';
import './../../hospitals/providers/hospitals_provider.dart';
import './../../emergency/providers/personal_data_provider.dart';
import './../../vaccinations/providers/vaccinations_provider.dart';

class Login extends StatefulWidget {
  static const String routeName = '/login-screen';
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _facebookSignIn = FacebookLogin();
  final emailFieldController = TextEditingController();
  final passwordFieldController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;
  var labelsProvider;
  LanguageProvider langProvider;
  AuthAccessTokenProvider authenticationProvider;

  void autoLoginIfAutherized() {
    authenticationProvider.getLoginOption().then((loginOption) {
      if (loginOption != null) {
        switch (loginOption) {
          case 0:
            {
              emailFieldController.text =
                  authenticationProvider.getEmailAddress();
              passwordFieldController.text =
                  authenticationProvider.getUserPassword();
              _loginWithEmailAndPassword();
              break;
            }
          case 1:
            {
              _signInWithGoogle();
              break;
            }
          case 2:
            {
              String fbAccesToken =
                  authenticationProvider.getFacebookAccessToken();
              _loginAgainWithFacebookToken(fbAccesToken);
              break;
            }
        }
      }
    });
  }

  void _initializeLabelsProvider() {
    langProvider = Provider.of<LanguageProvider>(context, listen: false);

    authenticationProvider =
        Provider.of<AuthAccessTokenProvider>(context, listen: false);

    if (!langProvider.isLanguageLoaded) {
      final deviceLocale = Localizations.localeOf(context);
      print(deviceLocale.languageCode);
      if (deviceLocale.languageCode == 'ar') {
        langProvider.setLanguage(deviceLocale.languageCode);
      } else {
        langProvider.setLanguage('en');
      }

      String currentLangCode;
      langProvider.getLangCode.then((_) {
        currentLangCode = _;
        if (currentLangCode != null)
          langProvider.setLanguage(currentLangCode);
        else {
          langProvider.setLanguage(deviceLocale.languageCode);
        }
        setState(() {
          print('language restored');
        });
      });

      langProvider.setLanguageLoaded();
    }

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;
  }

  @override
  Widget build(BuildContext context) {
    _initializeLabelsProvider();

    if (!authenticationProvider.authenticationLoaded) autoLoginIfAutherized();

    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Directionality(
        textDirection: langProvider.langCode == 'en'
            ? TextDirection.ltr
            : TextDirection.rtl,
        child: ModalProgressHUD(
          inAsyncCall: _isLoading,
          child: SingleChildScrollView(
            child: Container(
              height: screenSize.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF01D0FE), Color(0XFF0D47A1)],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 1.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
                image: DecorationImage(
                  image: AssetImage(Assets.backgroudPattern),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(height: 100.0, child: Image.asset(Assets.logo)),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      height: 400,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 20.0),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  TextField(
                                    controller: emailFieldController,
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(fontSize: 18.0),
                                    decoration: InputDecoration(
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(fontSize: 18.0),
                                      hintText: labelsProvider.email,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextField(
                                    onSubmitted: (_) =>
                                        _loginWithEmailAndPassword(),
                                    controller: passwordFieldController,
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(fontSize: 18.0),
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: labelsProvider.password,
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(fontSize: 18.0),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isRegistering = !_isRegistering;
                                      });
                                    },
                                    child: Text(
                                      _isRegistering
                                          ? labelsProvider.login
                                          : labelsProvider.register,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: RaisedButton(
                                      onPressed: _loginWithEmailAndPassword,
                                      color: Color(0xFF001737),
                                      child: Text(
                                        _isRegistering
                                            ? labelsProvider.register
                                            : labelsProvider.login,
                                        style: Theme.of(context)
                                            .textTheme
                                            .body1
                                            .copyWith(
                                              fontSize: 18.0,
                                              color: Colors.white,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: SizedBox(
                                      height: 30,
                                      width: 200,
                                      child: Divider(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text(
                                    labelsProvider.orYouCanLoginWith,
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        RaisedButton(
                                          onPressed: _loginWithFacebook,
                                          child: Text(
                                            labelsProvider.facebook,
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2
                                                .copyWith(
                                                  fontSize: 18.0,
                                                  color: Colors.white,
                                                ),
                                          ),
                                          color: Color(0xFF3B5998),
                                        ),
                                        RaisedButton(
                                          onPressed: _signInWithGoogle,
                                          child: Text(
                                            labelsProvider.google,
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2
                                                .copyWith(fontSize: 18.0),
                                          ),
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _loginWithEmailAndPassword() {
    setState(() {
      _isLoading = true;
    });

    final email = emailFieldController.text.trim();
    final password = passwordFieldController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
      });
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

    Future<AuthResult> resultFuture;

    if (_isRegistering) {
      resultFuture = _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } else {
      resultFuture = _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }

    var authResult;

    resultFuture.then((result) async {
      authResult = result;
      setState(() {
        _isLoading = false;
      });
      if (authResult != null) {
        authenticationProvider.saveEmailAndPassword(
          email: email,
          password: password,
          loginOption: 0,
        );
        final token = (await authResult.user.getIdToken()).token;
        authenticationProvider.accessToken = token;

        Provider.of<HospitalsProvider>(context, listen: false)
            .setAccessToken(token);

        Provider.of<MedicinesProvider>(context, listen: false)
            .setAccessToken(token);

        Provider.of<BookingsProvider>(context, listen: false)
            .setAccessToken(token);

        Provider.of<NotificationProvider>(context, listen: false)
            .setAccessToken(token);

        Provider.of<PersonalDataProvider>(context, listen: false)
            .setAccessToken(token);

        Provider.of<VaccinationsProvider>(context, listen: false)
            .setAccessToken(token);

        //_googleSignIn.signOut();

        Routes.sailor.navigate(
          HomeScreen.routeName,
          navigationType: NavigationType.pushAndRemoveUntil,
          removeUntilPredicate: (_) => false,
        );
      }
    }).catchError((error) {
      print(error.message);

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
        duration: Duration(seconds: 2),
      )..show(context);
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    final googleSignInAccount =
        await _googleSignIn.signIn().catchError((error) {
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
        duration: Duration(seconds: 2),
      )..show(context);
      setState(() {
        _isLoading = false;
      });

      return;
    });

    if (googleSignInAccount == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final googleAuthentication = await googleSignInAccount.authentication;

    final authCredential = GoogleAuthProvider.getCredential(
      idToken: googleAuthentication.idToken,
      accessToken: googleAuthentication.accessToken,
    );

    _auth.signInWithCredential(authCredential).then((authResult) async {
      authResult = authResult;

      setState(() {
        _isLoading = false;
      });
      if (authResult != null) {
        emailFieldController.clear();
        passwordFieldController.clear();
        authenticationProvider.saveEmailAndPassword(
          email: authResult.user.email,
          password: '',
          loginOption: 1,
        );
        final token = (await authResult.user.getIdToken()).token;

        authenticationProvider.accessToken = token;

        Provider.of<HospitalsProvider>(context, listen: false)
            .setAccessToken(token);

        Provider.of<MedicinesProvider>(context, listen: false)
            .setAccessToken(token);

        Provider.of<BookingsProvider>(context, listen: false)
            .setAccessToken(token);

        Provider.of<NotificationProvider>(context, listen: false)
            .setAccessToken(token);

        Provider.of<PersonalDataProvider>(context, listen: false)
            .setAccessToken(token);

        Provider.of<VaccinationsProvider>(context, listen: false)
            .setAccessToken(token);

        Routes.sailor.navigate(
          HomeScreen.routeName,
          navigationType: NavigationType.pushAndRemoveUntil,
          removeUntilPredicate: (_) => false,
        );
      }
    }).catchError((error) {
      print(error.message);
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
        duration: Duration(seconds: 2),
      )..show(context);
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _loginWithFacebook() async {
    setState(() {
      _isLoading = true;
    });
    final facebookLoginResult =
        await _facebookSignIn.logIn(['email']).catchError((error) {
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
        duration: Duration(seconds: 2),
      )..show(context);
      setState(() {
        _isLoading = false;
      });
      return;
    });

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.cancelledByUser:
        {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      case FacebookLoginStatus.error:
        {
          Flushbar(
            icon: Icon(
              Icons.error,
              color: Colors.red,
            ),
            messageText: Text(
              facebookLoginResult.errorMessage,
              style: Theme.of(context)
                  .textTheme
                  .display1
                  .copyWith(color: Colors.white),
            ),
            duration: Duration(seconds: 2),
          )..show(context);
          break;
        }

      case FacebookLoginStatus.loggedIn:
        {
          final authCredential = FacebookAuthProvider.getCredential(
            accessToken: facebookLoginResult.accessToken.token,
          );

          _auth.signInWithCredential(authCredential).then((authResult) async {
            authResult = authResult;

            setState(() {
              _isLoading = false;
            });
            if (authResult != null) {
              emailFieldController.clear();
              passwordFieldController.clear();
              authenticationProvider.saveEmailAndPassword(
                email: authResult.user.email,
                password: '',
                loginOption: 2,
                facebookResultToken: facebookLoginResult.accessToken.token,
              );
              final token = (await authResult.user.getIdToken()).token;

              authenticationProvider.accessToken = token;

              Provider.of<HospitalsProvider>(context, listen: false)
                  .setAccessToken(token);

              Provider.of<MedicinesProvider>(context, listen: false)
                  .setAccessToken(token);

              Provider.of<BookingsProvider>(context, listen: false)
                  .setAccessToken(token);

              Provider.of<NotificationProvider>(context, listen: false)
                  .setAccessToken(token);

              Provider.of<PersonalDataProvider>(context, listen: false)
                  .setAccessToken(token);

              Provider.of<VaccinationsProvider>(context, listen: false)
                  .setAccessToken(token);

              Routes.sailor.navigate(
                HomeScreen.routeName,
                navigationType: NavigationType.pushAndRemoveUntil,
                removeUntilPredicate: (_) => false,
              );
            }
          }).catchError((error) {
            print(error.message);
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
              duration: Duration(seconds: 2),
            )..show(context);
            setState(() {
              _isLoading = false;
            });
          });
          break;
        }
    }
  }

  void _loginAgainWithFacebookToken(String fbAccessToken) {
    setState(() {
      _isLoading = true;
    });
    final authCredential = FacebookAuthProvider.getCredential(
      accessToken: fbAccessToken,
    );

    _auth.signInWithCredential(authCredential).then((authResult) async {
      authResult = authResult;

      setState(() {
        _isLoading = false;
      });
      if (authResult != null) {
        emailFieldController.clear();
        passwordFieldController.clear();
        authenticationProvider.saveEmailAndPassword(
          email: authResult.user.email,
          password: '',
          loginOption: 2,
          facebookResultToken: fbAccessToken,
        );
        final token = (await authResult.user.getIdToken()).token;

        authenticationProvider.accessToken = token;

        Provider.of<HospitalsProvider>(context, listen: false)
            .setAccessToken(token);

        Provider.of<MedicinesProvider>(context, listen: false)
            .setAccessToken(token);

        Provider.of<BookingsProvider>(context, listen: false)
            .setAccessToken(token);

        Provider.of<NotificationProvider>(context, listen: false)
            .setAccessToken(token);

        Provider.of<PersonalDataProvider>(context, listen: false)
            .setAccessToken(token);

        Provider.of<VaccinationsProvider>(context, listen: false)
            .setAccessToken(token);

        Routes.sailor.navigate(
          HomeScreen.routeName,
          navigationType: NavigationType.pushAndRemoveUntil,
          removeUntilPredicate: (_) => false,
        );
      }
    }).catchError((error) {
      print(error.message);
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
        duration: Duration(seconds: 2),
      )..show(context);
      setState(() {
        _isLoading = false;
      });
    });
  }
}

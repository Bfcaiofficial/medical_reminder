import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthAccessTokenProvider with ChangeNotifier {
  String _accessToken;
  String _emailAddress;
  String _password;
  bool _authenticationLoaded = false;

  set accessToken(String token) {
    _accessToken = token;
  }

  Future<void> saveEmailAndPassword(
      {String email,
      String password,
      int loginOption,
      String facebookResultToken}) async {
    _emailAddress = email;
    _password = password;

    prefs.setString('email', email);
    prefs.setInt('loginOption', loginOption);
    if (facebookResultToken != null)
      prefs.setString('fb_token', facebookResultToken);
    prefs.setString('password', password).then(
          (_) => print('user data stored'),
        );
  }

  SharedPreferences prefs;

  String getEmailAddress() {
    return prefs.getString('email');
  }

  String getFacebookAccessToken() {
    return prefs.getString('fb_token');
  }

  String getUserPassword() {
    return prefs.getString('password');
  }

  Future<int> getLoginOption() async {
    prefs = await SharedPreferences.getInstance();

    _authenticationLoaded = true;

    return prefs.getInt('loginOption');
  }

  void clearAuthenticationData() {
    prefs.clear();
  }

  bool get authenticationLoaded => _authenticationLoaded;
  String get accessToken => _accessToken;
}

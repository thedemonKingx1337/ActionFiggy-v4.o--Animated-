import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/httpException.dart';

class Authentication with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _tokenTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticationMethod(
      String email, String password, String urlRoute) async {
    String API_KEY = "AIzaSyBQ60g36wKUVxgbhulRAsKnc4UVabRLHxI";
    final String firebaseUrl =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlRoute?key=$API_KEY";
    Uri url = Uri.parse(firebaseUrl);
    try {
      final response = await http.post(
        url,
        body: json.encode(
            {"email": email, "password": password, "returnSecureToken": true}),
      );
      print(json.decode(response.body));
      final responseData = json.decode(response.body);

      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      _token = responseData["idToken"];
      _userId = responseData["localId"];
      int expiresIn = int.parse(responseData["expiresIn"]);
      print("Expppp: $expiresIn");
      _expiryDate = DateTime.now().add(Duration(seconds: expiresIn));
      print("Exppppyyyyy: $_expiryDate");

      _autoLogOut();

      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": _token,
        "userId": _userId,
        "expDate": _expiryDate!.toIso8601String()
      });
      prefs.setString("userData", userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticationMethod(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    return _authenticationMethod(email, password, "signInWithPassword");
  }

  Future<bool> autoLoginMethod() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("userData")) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString("userData")!) as Map<String, dynamic>;

    final expiryDate = DateTime.parse(extractedUserData["expDate"].toString());
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData["token"];
    _userId = extractedUserData["userId"];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogOut();
    return true;
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_tokenTimer != null) {
      _tokenTimer!.cancel();
      _tokenTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove("userData");
    prefs.clear();
  }

  void _autoLogOut() async {
    if (_tokenTimer != null) {
      _tokenTimer!.cancel();
    }
    final timeOfExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _tokenTimer = Timer(Duration(seconds: timeOfExpiry), logout);
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}

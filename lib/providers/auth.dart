import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  late String? _userId;
  Timer? _authTimer;

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

  Future<void> _authenticate(
      String? email, String? password, String? urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBh6XWXP7l0Bb29MHXUTW-OFg1egOZH3nQ');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      final pref = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      pref.setString('userData', userData);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final pref = await SharedPreferences.getInstance();
    if (!pref.containsKey('userData')) {
      return false;
    }
    final extractedData =
        jsonDecode(pref.getString('userData')!) as Map<String, String>;
    final expiryDate = DateTime.parse(extractedData['expiryDate']!);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> login(String? email, String? password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> signup(String? email, String? password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> logout() async {
    _expiryDate = null;
    _token = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final pref = await SharedPreferences.getInstance();
    pref.clear();
    // pref.remove('userData');
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final _timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: _timeToExpiry), logout);
  }
}

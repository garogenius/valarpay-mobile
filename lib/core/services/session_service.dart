import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valarpay/core/routing/app_router.dart';
import 'package:valarpay/core/services/local_storage_service.dart';
import 'package:valarpay/features/models/login.dart';
import 'package:valarpay/features/models/user.dart';

class SessionService {
  late BuildContext context;
  SessionService(BuildContext incomingBuildContext) {
    context = incomingBuildContext;
  }

  static const String _userDetailsKey = 'user_details';
  static const String _userAccessToken = 'user_access_token';
  static const String _usernameKey = 'username';
  static const String _userFullnameKey = 'user_fullname';
  static const String _userActualUsernameKey = 'user_actual_username';
  static const String _userPhoneNumberKey = 'user_phone_number';

  // Save login session
  static Future<void> saveSession(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDetailsKey, jsonEncode(response.user.toJson()));
    await prefs.setString(_usernameKey, response.user.email);
    await prefs.setString(_userFullnameKey, response.user.fullname);
    await prefs.setString(_userActualUsernameKey, response.user.username);
    await prefs.setString(_userPhoneNumberKey, response.user.phoneNumber ?? '');
    //save token if any
    if (response.accessToken != null) {
      await prefs.setString(_userAccessToken, response.accessToken!);
    }
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_userAccessToken);
    if (accessToken == null) return null;
    return accessToken;
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_usernameKey);
    if (username == null) return null;
    return username;
  }

  static Future<String?> getUserFullname() async {
    final prefs = await SharedPreferences.getInstance();
    final userFullname = prefs.getString(_userFullnameKey);
    if (userFullname == null) return null;
    return userFullname;
  }

  static Future<String?> getActualUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_userActualUsernameKey);
    if (username == null) return null;
    return username;
  }

  static Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString(_userPhoneNumberKey);
    if (phoneNumber == null) return null;
    return phoneNumber;
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userDetailsKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }

  static Future<bool> isLoggedIn() async {
    bool isLogged = await getAccessToken() != null && await getUser() != null;
    return isLogged;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDetailsKey);
    await prefs.remove(_userAccessToken);

    final fpEnabled = await LocalStorageService.getBool(
      'pref_biometric_fingerprint',
    );
    final faceEnabled = await LocalStorageService.getBool(
      'pref_biometric_faceid',
    );
    if (await SessionService.getUsername() != null &&
        (fpEnabled == true || faceEnabled == true)) {
      context.pushReplacement('/biometric-login');
    } else {
      context.pushReplacement('/signin');
    }
  }

  Future<void> logout2() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDetailsKey);
    await prefs.remove(_userAccessToken);

    final fpEnabled = await LocalStorageService.getBool(
      'pref_biometric_fingerprint',
    );
    final faceEnabled = await LocalStorageService.getBool(
      'pref_biometric_faceid',
    );
    if (await SessionService.getUsername() != null &&
        (fpEnabled == true || faceEnabled == true)) {
      router.go('/biometric-login');
    } else {
      router.go('/signin');
    }
  }

  Future<void> checkSession() async {
    final loggedIn = await SessionService.isLoggedIn();
    if (loggedIn) {
      context.pushReplacement('/');
    } else {
      logout();
    }
  }

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDetailsKey, jsonEncode(user.toJson()));
    await prefs.setString(_userFullnameKey, user.fullname);
    await prefs.setString(_userPhoneNumberKey, user.phoneNumber ?? '');
  }
}

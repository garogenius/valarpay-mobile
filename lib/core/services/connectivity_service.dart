import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:valarpay/core/widgets/no_internet_dialogue.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isDialogShowing = false;
  bool _hasConnection = true;

  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });

    // Check initial connectivity after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      _checkInitialConnectivity();
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _handleConnectivityChange(results);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final hasConnection = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);

    if (!hasConnection && !_isDialogShowing) {
      _hasConnection = false;
      _showDialog();
    } else if (hasConnection && !_hasConnection) {
      _hasConnection = true;
      if (_isDialogShowing) {
        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          _isDialogShowing = false;
        }
      }
    }
  }

  void _showDialog() async {
    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    final result = await showNoInternetDialog(
      context,
      onRetry: () {
        // Try re-checking connectivity, refresh data, etc
      },
      onOpenSettings: () {
        // Optional behavior when user taps Open Settings
      },
    );

    if (result == true) {
      // user tapped retry
      final results = await _connectivity.checkConnectivity();
      final hasConnection = results.any((result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet);

      if (hasConnection) {
        _hasConnection = true;
        _isDialogShowing = false;
      } else {
        // still no connection, show dialog again
        _showDialog();
      }
    } else if (result == false) {
      // user tapped Open Settings
    } else {
      // dismissed
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}

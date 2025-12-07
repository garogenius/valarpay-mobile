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
  Timer? _debounceTimer;

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
    // Cancel any pending debounce timer
    _debounceTimer?.cancel();

    // Debounce connectivity changes to avoid rapid dialog shows
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      final hasConnection = results.any(
        (result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet,
      );

      // Only show dialog if we lost connection and dialog isn't already showing
      if (!hasConnection && !_isDialogShowing && _hasConnection) {
        _hasConnection = false;
        _showDialog();
      } else if (hasConnection && !_hasConnection) {
        // Connection restored
        _hasConnection = true;
        if (_isDialogShowing) {
          _dismissDialog();
        }
      }
    });
  }

  void _dismissDialog() {
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted && _isDialogShowing) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogShowing = false;
    }
  }

  void _showDialog() async {
    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted || _isDialogShowing) return;

    _isDialogShowing = true;

    final result = await showNoInternetDialog(
      context,
      onRetry: () {
        // Try re-checking connectivity, refresh data, etc
      },
      onOpenSettings: () {
        // Optional behavior when user taps Open Settings
      },
    );

    _isDialogShowing = false;

    if (result == true) {
      // user tapped retry
      final results = await _connectivity.checkConnectivity();
      final hasConnection = results.any(
        (result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet,
      );

      if (hasConnection) {
        _hasConnection = true;
      } else {
        // still no connection, show dialog again after a delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!_hasConnection && !_isDialogShowing) {
            _showDialog();
          }
        });
      }
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
  }
}

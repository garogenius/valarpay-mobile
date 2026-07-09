import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/features/models/notification_preference.dart';
import 'package:valarpay/features/notifiers/notification_notifier.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _isLoading = true;
  Map<String, NotificationPreference> _preferences = {};

  final List<String> _categories = [
    'TRANSACTIONS',
    'SERVICES',
    'UPDATES',
    'MESSAGES',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(notificationRepositoryProvider);
      final prefsData = await repository.getNotificationPreferences();

      final Map<String, NotificationPreference> prefsMap = {};
      for (var data in prefsData) {
        final pref = NotificationPreference.fromJson(data);
        prefsMap[pref.category] = pref;
      }

      // Initialize missing categories with default values
      for (var category in _categories) {
        if (!prefsMap.containsKey(category)) {
          prefsMap[category] = NotificationPreference(
            id: '',
            userId: '',
            category: category,
            email: true,
            sms: true,
            push: true,
            inApp: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }

      setState(() {
        _preferences = prefsMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppMessenger.show(
          context,
          message: 'Failed to load preferences: ${e.toString()}',
          type: MessageType.error,
        );
      }
    }
  }

  Future<void> _updatePreference(
    String category,
    String type,
    bool value,
  ) async {
    final currentPref = _preferences[category];
    if (currentPref == null) return;

    // Optimistically update UI
    setState(() {
      _preferences[category] = currentPref.copyWith(
        email: type == 'email' ? value : currentPref.email,
        sms: type == 'sms' ? value : currentPref.sms,
        push: type == 'push' ? value : currentPref.push,
        inApp: type == 'inApp' ? value : currentPref.inApp,
      );
    });

    try {
      final repository = ref.read(notificationRepositoryProvider);
      final updatedPref = _preferences[category]!;

      await repository.updateNotificationPreference(
        category: category,
        email: updatedPref.email,
        sms: updatedPref.sms,
        push: updatedPref.push,
        inApp: updatedPref.inApp,
      );

      // Refresh preferences notifier to update downstream UI observers
      ref.read(notificationPreferencesProvider.notifier).fetchPreferences();

      if (mounted) {
        AppMessenger.show(
          context,
          message: 'Preference updated successfully',
          type: MessageType.success,
        );
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _preferences[category] = currentPref;
      });

      if (mounted) {
        AppMessenger.show(
          context,
          message: 'Failed to update preference',
          type: MessageType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadPreferences,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Manage Notification Preferences',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose how you want to receive notifications for each category',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    _buildCategorySection(
                      'TRANSACTIONS',
                      Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildCategorySection('SERVICES', Icons.business_outlined),
                    const SizedBox(height: 16),
                    _buildCategorySection(
                      'UPDATES',
                      Icons.system_update_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildCategorySection('MESSAGES', Icons.message_outlined),
                  ],
                ),
              ),
    );
  }

  Widget _buildCategorySection(String category, IconData icon) {
    final pref = _preferences[category];
    if (pref == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  _getCategoryDisplayName(category),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Preference toggles
          _buildPreferenceToggle(
            'Email Notifications',
            'Receive notifications via email (Free)',
            Icons.email_outlined,
            pref.email,
            (value) => _updatePreference(category, 'email', value),
          ),
          _buildPreferenceToggle(
            'SMS Notifications',
            'Receive notifications via SMS (Charges ₦6/transaction)',
            Icons.sms_outlined,
            pref.sms,
            (value) => _updatePreference(category, 'sms', value),
          ),
          _buildPreferenceToggle(
            'Push Notifications',
            'Receive push notifications on your device (Free)',
            Icons.notifications_outlined,
            pref.push,
            (value) => _updatePreference(category, 'push', value),
          ),
          _buildPreferenceToggle(
            'In-App Notifications',
            'Show notifications within the app',
            Icons.app_settings_alt_outlined,
            pref.inApp,
            (value) => _updatePreference(category, 'inApp', value),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.grey),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'TRANSACTIONS':
        return 'Transactions';
      case 'SERVICES':
        return 'Services';
      case 'UPDATES':
        return 'Updates';
      case 'MESSAGES':
        return 'Messages';
      default:
        return category;
    }
  }
}

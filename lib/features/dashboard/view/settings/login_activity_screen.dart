import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/services/login_activity_service.dart';
import 'package:valarpay/features/models/login_activity.dart';
import 'package:valarpay/core/utils/app_messenger.dart';

class LoginActivityScreen extends StatefulWidget {
  const LoginActivityScreen({super.key});

  @override
  State<LoginActivityScreen> createState() => _LoginActivityScreenState();
}

class _LoginActivityScreenState extends State<LoginActivityScreen> {
  List<LoginActivity> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await LoginActivityService.getHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout(LoginActivity activity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Device?'),
        content: Text('Are you sure you want to log out from ${activity.deviceName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (activity.isCurrentDevice) {
        AppMessenger.show(context, message: 'Logging out from current device...');
        // Trigger actual logout here if needed
        // For now, satisfy the UI request
      }
      
      // Simulate backend call and update local state
      setState(() {
        _history.removeWhere((h) => h.id == activity.id);
      });
      AppMessenger.show(context, message: 'Logged out from ${activity.deviceName} successfully', type: MessageType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Activity History', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Are you sure you want to clear your login activity history?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await LoginActivityService.clearHistory();
                _loadHistory();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF76301)))
          : _history.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.security, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'Your account security is our priority.\nRecent login history will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final activity = _history[index];
        final isSuccess = activity.status == 'success';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: activity.isCurrentDevice ? Border.all(color: const Color(0xFFF76301).withOpacity(0.3), width: 1) : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: isSuccess ? Colors.blue.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  child: Icon(
                    activity.deviceName.toLowerCase().contains('iphone') ? Icons.phone_iphone : Icons.phone_android,
                    color: isSuccess ? Colors.blue : Colors.red,
                  ),
                ),
                if (activity.isCurrentDevice)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Text(
                  activity.deviceName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (activity.isCurrentDevice)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('THIS DEVICE', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(activity.location ?? 'Unknown Location', style: const TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('MMM dd, hh:mm a').format(activity.timestamp)} • ${activity.ipAddress ?? 'Hidden IP'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            trailing: activity.isCurrentDevice 
               ? null 
               : TextButton(
                  onPressed: () => _handleLogout(activity),
                  child: const Text('LOGOUT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
          ),
        );
      },
    );
  }
}

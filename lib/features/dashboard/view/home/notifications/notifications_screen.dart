import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/features/models/notification_model.dart';
import 'package:valarpay/features/notifiers/notification_notifier.dart';
import '../../../widgets/home_widgets/notification_widgets.dart' as widgets;
import '../../../widgets/transaction_widgets/transaction_shimmer_loader.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  final int? initialTab;

  const NotificationsScreen({super.key, this.initialTab});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize tab controller with initial tab if provided
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );

    // Fetch notifications on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationNotifierProvider.notifier).fetchNotifications();
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Listen to tab changes to filter notifications
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final notifier = ref.read(notificationNotifierProvider.notifier);
      if (notifier.hasMore) {
        notifier.loadMore();
      }
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final type = _getTypeForTab(_tabController.index);
      ref.read(notificationNotifierProvider.notifier).filterByType(type);
    }
  }

  String? _getTypeForTab(int index) {
    switch (index) {
      case 0:
        return 'transaction';
      case 1:
        return 'service';
      case 2:
        return 'update';
      case 3:
        return 'message';
      default:
        return null;
    }
  }

  Future<void> _handleRefresh() async {
    await ref.read(notificationNotifierProvider.notifier).refresh();
  }

  Future<void> _markAllAsRead() async {
    await ref.read(notificationNotifierProvider.notifier).markAllAsRead();
  }

  void _showStatusFilterBottomSheet() {
    final currentFilter =
        ref.read(notificationNotifierProvider.notifier).currentStatusFilter;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter by Status',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (currentFilter != null)
                    TextButton(
                      onPressed: () {
                        ref
                            .read(notificationNotifierProvider.notifier)
                            .filterByStatus(null);
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatusFilterOption('All', null, currentFilter),
              _buildStatusFilterOption('Pending', 'PENDING', currentFilter),
              _buildStatusFilterOption('Sent', 'SENT', currentFilter),
              _buildStatusFilterOption('Failed', 'FAILED', currentFilter),
              _buildStatusFilterOption('Delivered', 'DELIVERED', currentFilter),
              _buildStatusFilterOption('Read', 'READ', currentFilter),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusFilterOption(
    String label,
    String? value,
    String? currentFilter,
  ) {
    final isSelected = currentFilter == value;

    return InkWell(
      onTap: () {
        ref.read(notificationNotifierProvider.notifier).filterByStatus(value);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationNotifierProvider);
    final unreadCount = ref.watch(
      notificationNotifierProvider.select(
        (state) => ref.read(notificationNotifierProvider.notifier).unreadCount,
      ),
    );
    final currentStatusFilter = ref.watch(
      notificationNotifierProvider.select(
        (state) =>
            ref.read(notificationNotifierProvider.notifier).currentStatusFilter,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Filter button
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showStatusFilterBottomSheet,
              ),
              if (currentStatusFilter != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(fontSize: 13),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/notification-settings');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).primaryColor,
          dividerColor: Colors.transparent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Transactions'),
            Tab(text: 'Services'),
            Tab(text: 'Updates'),
            Tab(text: 'Messages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(context, notificationState, 'transaction'),
          _buildNotificationList(context, notificationState, 'service'),
          _buildNotificationList(context, notificationState, 'update'),
          _buildNotificationList(context, notificationState, 'message'),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    dynamic notificationState,
    String type,
  ) {
    // Loading state
    if (notificationState.isInitialLoading) {
      return const TransactionShimmerLoader();
    }

    // Error state
    if (!notificationState.isDataAvailable &&
        notificationState.message != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              notificationState.message ?? 'Failed to load notifications',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(notificationNotifierProvider.notifier)
                    .fetchNotifications();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final notifications =
        (notificationState.data as List<NotificationModel>?) ?? [];

    // Empty state
    if (notifications.isEmpty) {
      return widgets.NotificationEmptyState(
        tab: type == 'transaction' ? 'Transaction' : 'Other',
        message: _getEmptyMessage(type),
      );
    }

    // Success state with data
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount:
            notifications.length + (notificationState.isPaginating ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loader at bottom if loading more
          if (index == notifications.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final notification = notifications[index];
          return InkWell(
            onTap: () {
              // Mark as read when tapped
              if (!notification.isRead) {
                ref
                    .read(notificationNotifierProvider.notifier)
                    .markAsRead(notification.id);
              }

              context.push(
                '/notification-view',
                extra: {
                  'title': notification.title,
                  'content': notification.message,
                },
              );
            },
            child: widgets.NotificationTile(
              notification: widgets.NotificationItem(
                icon: notification.getIcon(),
                title: notification.title,
                subtitle: notification.message,
                time: notification.getTimeAgo(),
                isRead: notification.isRead,
              ),
            ),
          );
        },
      ),
    );
  }

  String _getEmptyMessage(String type) {
    switch (type) {
      case 'transaction':
        return 'No new transactions yet. Start making payments to see your transaction notifications here.';
      case 'service':
        return 'No service notifications yet. Service updates and service notifications will appear here.';
      case 'update':
        return 'No updates yet. Stay tuned for the latest news and updates.';
      case 'message':
        return 'No new messages from ValarPay right now.';
      default:
        return 'No notifications yet.';
    }
  }
}

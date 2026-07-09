import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/features/models/notification_model.dart';
import 'package:valarpay/features/notifiers/notification_notifier.dart';
import '../../../widgets/home_widgets/notification_widgets.dart' as widgets;
import '../../../widgets/transaction_widgets/transaction_shimmer_loader.dart';
import 'package:valarpay/features/notifiers/transaction_notifier.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  final int? initialTab;

  const NotificationsScreen({super.key, this.initialTab});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize tab controller with initial tab if provided
    _tabController = TabController(
      length: 5, // Updated to 5 tabs (All + 4 categories)
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );

    // Initialize header animation
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Fetch notifications on init
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // First fetch all notifications to get total unread count
      await ref
          .read(notificationNotifierProvider.notifier)
          .fetchNotifications();

      // Then apply initial tab filter if not on first tab
      if (widget.initialTab != null && widget.initialTab! > 0) {
        final category = _getCategoryForTab(widget.initialTab!);
        ref
            .read(notificationNotifierProvider.notifier)
            .filterByCategory(category);
      }

      _headerAnimationController.forward();
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
    _headerAnimationController.dispose();
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
      final category = _getCategoryForTab(_tabController.index);
      ref
          .read(notificationNotifierProvider.notifier)
          .filterByCategory(category);
    }
  }

  String? _getCategoryForTab(int index) {
    switch (index) {
      case 0:
        return null; // All notifications
      case 1:
        return 'TRANSACTIONS';
      case 2:
        return 'SERVICES';
      case 3:
        return 'UPDATES';
      case 4:
        return 'MESSAGES';
      default:
        return null;
    }
  }

  Future<void> _handleRefresh() async {
    await ref.read(notificationNotifierProvider.notifier).refresh();
  }

  Future<void> _markAllAsRead() async {
    await ref.read(notificationNotifierProvider.notifier).markAllAsRead();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All notifications marked as read'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showStatusFilterBottomSheet() {
    final currentFilter =
        ref.read(notificationNotifierProvider.notifier).currentStatusFilter;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
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
                _buildStatusFilterOption(
                  'Delivered',
                  'DELIVERED',
                  currentFilter,
                ),
                _buildStatusFilterOption('Read', 'READ', currentFilter),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
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

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, animation, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * animation),
          child: Opacity(
            opacity: animation,
            child: InkWell(
              onTap: () {
                ref
                    .read(notificationNotifierProvider.notifier)
                    .filterByStatus(value);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color:
                              isSelected
                                  ? Theme.of(context).primaryColor
                                  : null,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                title: FadeTransition(
                  opacity: _headerAnimation,
                  child: Row(
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        ScaleTransition(
                          scale: _headerAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
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
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                // Animated Filter button
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(_headerAnimation),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.filter_list_rounded),
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
                ),
                if (unreadCount > 0)
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(_headerAnimation),
                    child: TextButton(
                      onPressed: _markAllAsRead,
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(_headerAnimation),
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      context.push('/notification-settings');
                    },
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: FadeTransition(
                  opacity: _headerAnimation,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: Theme.of(context).primaryColor,
                      dividerColor: Colors.transparent,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                      tabs: const [
                        Tab(text: 'All'),
                        Tab(text: 'Transactions'),
                        Tab(text: 'Services'),
                        Tab(text: 'Updates'),
                        Tab(text: 'Messages'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildNotificationList(context, notificationState, 'ALL'),
            _buildNotificationList(context, notificationState, 'TRANSACTIONS'),
            _buildNotificationList(context, notificationState, 'SERVICES'),
            _buildNotificationList(context, notificationState, 'UPDATES'),
            _buildNotificationList(context, notificationState, 'MESSAGES'),
          ],
        ),
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

    final notifications =
        (notificationState.data as List<NotificationModel>?) ?? [];

    // Empty state - show custom message even if API returned a success message
    if (notifications.isEmpty) {
      return _buildAnimatedEmptyState(type);
    }

    // Error state - only show if there's actually an error AND no data
    if (!notificationState.isDataAvailable &&
        notificationState.message != null &&
        notifications.isEmpty) {
      return _buildErrorState(notificationState.message);
    }

    // Success state with data
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Theme.of(context).primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(), // Better for NestedScrollView
        addAutomaticKeepAlives: true, // Reduce rebuilds
        addRepaintBoundaries: true, // Improve performance
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

          // Only animate first 10 items for better performance
          if (index < 10) {
            return TweenAnimationBuilder<double>(
              key: ValueKey(notification.id),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 50)),
              curve: Curves.easeOutCubic,
              builder: (context, animation, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - animation)),
                  child: Opacity(opacity: animation, child: child),
                );
              },
              child: RepaintBoundary(
                child: _buildAnimatedNotificationTile(notification, index),
              ),
            );
          }

          // No animation for items beyond 10 for smooth scrolling
          return RepaintBoundary(
            key: ValueKey(notification.id),
            child: _buildAnimatedNotificationTile(notification, index),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedNotificationTile(
    NotificationModel notification,
    int index,
  ) {
    return Hero(
      tag: 'notification_${notification.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Mark as read when tapped
            if (!notification.isRead) {
              ref
                  .read(notificationNotifierProvider.notifier)
                  .markAsRead(notification.id);
            }

            if ((notification.category == 'TRANSACTIONS' || notification.category == 'SERVICES') && notification.metadata != null) {
              final reference = notification.metadata?['reference'] ??
                  notification.metadata?['transactionRef'] ??
                  notification.metadata?['ref'];
                  
              if (reference != null) {
                 final transactionsState = ref.read(transactionNotifierProvider);
                 final transactions = transactionsState.data ?? [];
                 
                 try {
                   final transaction = transactions.firstWhere(
                     (t) => t.reference == reference || t.transactionRef == reference || t.id == reference
                   );
                   context.push('/transaction-details', extra: transaction);
                   return;
                 } catch (e) {
                   // Fallback to notification view if not found
                 }
              }
            }

            context.push(
              '/notification-view',
              extra: {
                'title': notification.formattedTitle,
                'content': notification.formattedMessage,
              },
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: widgets.NotificationTile(
            notification: widgets.NotificationItem(
              icon: notification.getIcon(),
              title: notification.formattedTitle,
              subtitle: notification.formattedMessage,
              time: notification.getTimeAgo(),
              isRead: notification.isRead,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedEmptyState(String category) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animation),
          child: Opacity(opacity: animation, child: child),
        );
      },
      child: widgets.NotificationEmptyState(
        tab: _getCategoryDisplayName(category),
        message: _getEmptyMessage(category),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, animation, child) {
        return Opacity(opacity: animation, child: child);
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(notificationNotifierProvider.notifier)
                    .fetchNotifications();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'TRANSACTIONS':
        return 'Transaction';
      case 'SERVICES':
        return 'Service';
      case 'UPDATES':
        return 'Update';
      case 'MESSAGES':
        return 'Message';
      default:
        return 'Notification';
    }
  }

  String _getEmptyMessage(String category) {
    switch (category) {
      case 'TRANSACTIONS':
        return 'You\'re all caught up! No transaction notifications at the moment.';
      case 'SERVICES':
        return 'All clear here! No service notifications right now.';
      case 'UPDATES':
        return 'You\'re up to date! Check back later for new updates.';
      case 'MESSAGES':
        return 'Inbox zero! No new messages from ValarPay.';
      default:
        return 'All clear! No notifications at the moment.';
    }
  }
}

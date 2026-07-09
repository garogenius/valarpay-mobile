import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/notification_model.dart';
import 'package:valarpay/features/models/notification_preference.dart';
import 'package:valarpay/features/repositories/notification_repository.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

/// Repository provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(apiClientProvider));
});

/// Notification Notifier for managing notification state
class NotificationNotifier extends StateNotifier<DataState<NotificationModel>> {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository)
    : super(DataState<NotificationModel>.initial());

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  List<NotificationModel> _allNotifications = [];
  int _unreadCount = 0;

  // Filters
  String? _categoryFilter;
  String? _statusFilter;
  bool? _isReadFilter;

  // Getters
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get unreadCount => _unreadCount;
  String? get currentStatusFilter => _statusFilter;

  /// Fetch only the unread count (lightweight for home screen badge)
  Future<void> fetchUnreadCount() async {
    try {
      final count = await _repository.getNotificationCount();
      _unreadCount = count;
      // Update state to trigger UI rebuild
      state = state.copyWith();
    } catch (e) {
      log('[NotificationNotifier fetchUnreadCount] $e');
      // Don't update on error, keep existing count
    }
  }

  /// Fetch notifications with optional filters
  Future<void> fetchNotifications({
    bool refresh = false,
    String? category,
    String? status,
    bool? isRead,
  }) async {
    // Reset on refresh or filter change
    if (refresh ||
        category != _categoryFilter ||
        status != _statusFilter ||
        isRead != _isReadFilter) {
      _currentPage = 1;
      _allNotifications = [];
      _hasMore = true;
      _categoryFilter = category;
      _statusFilter = status;
      _isReadFilter = isRead;
    }

    // Don't fetch if no more data
    if (!_hasMore && !refresh) return;

    // Set loading state
    state = state.copyWith(
      isInitialLoading: _currentPage == 1,
      isPaginating: _currentPage > 1,
      message: null,
    );

    try {
      final response = await _repository.getNotifications(
        page: _currentPage,
        limit: 20,
        category: _categoryFilter,
        status: _statusFilter,
        isRead: _isReadFilter,
      );

      _totalPages = response.totalPages;
      _hasMore = _currentPage < _totalPages;

      // Only update unread count when fetching ALL notifications (no category filter)
      // This ensures the counter shows total unread across all categories
      if (_categoryFilter == null &&
          _statusFilter == null &&
          _isReadFilter == null) {
        _unreadCount = response.unreadCount;
      }

      // Add new notifications to the list
      if (refresh || _currentPage == 1) {
        _allNotifications = response.notifications;
      } else {
        _allNotifications.addAll(response.notifications);
      }

      state = state.copyWith(
        isInitialLoading: false,
        isPaginating: false,
        data: _allNotifications,
        isDataAvailable: _allNotifications.isNotEmpty,
        message: response.message,
      );
    } catch (e, stack) {
      log('[NotificationNotifier fetchNotifications] $e\\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isPaginating: false,
        isDataAvailable: false,
        message: 'Failed to load notifications: ${e.toString()}',
      );
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    if (!_hasMore || state.isInitialLoading || state.isPaginating) return;

    _currentPage++;
    await fetchNotifications();
  }

  /// Refresh notifications (pull to refresh)
  Future<void> refresh() async {
    await fetchNotifications(refresh: true);
  }

  /// Filter by category (TRANSACTIONS, SERVICES, UPDATES, MESSAGES)
  Future<void> filterByCategory(String? category) async {
    await fetchNotifications(refresh: true, category: category);
  }

  /// Filter by status (PENDING, SENT, FAILED, DELIVERED, READ)
  Future<void> filterByStatus(String? status) async {
    await fetchNotifications(
      refresh: true,
      category: _categoryFilter,
      status: status,
    );
  }

  /// Filter by read status
  Future<void> filterByReadStatus(bool? isRead) async {
    await fetchNotifications(refresh: true, isRead: isRead);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);

      // Update local state
      final updatedNotifications =
          _allNotifications.map((notification) {
            if (notification.id == notificationId) {
              return notification.copyWith(readAt: DateTime.now());
            }
            return notification;
          }).toList();

      _allNotifications = updatedNotifications;
      _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;

      state = state.copyWith(data: _allNotifications);
    } catch (e) {
      log('[NotificationNotifier markAsRead] $e');
      // Optionally show error to user
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();

      // Update local state
      final updatedNotifications =
          _allNotifications.map((notification) {
            return notification.copyWith(readAt: DateTime.now());
          }).toList();

      _allNotifications = updatedNotifications;
      _unreadCount = 0;

      state = state.copyWith(data: _allNotifications);
    } catch (e) {
      log('[NotificationNotifier markAllAsRead] $e');
      // Optionally show error to user
    }
  }


  /// Reset state
  void reset() {
    _currentPage = 1;
    _totalPages = 1;
    _hasMore = true;
    _allNotifications = [];
    _unreadCount = 0;
    _categoryFilter = null;
    _statusFilter = null;
    _isReadFilter = null;
    state = DataState<NotificationModel>.initial();
  }
}

/// Notification Notifier Provider
final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, DataState<NotificationModel>>((
      ref,
    ) {
      return NotificationNotifier(ref.read(notificationRepositoryProvider));
    });

/// Notification Preferences Notifier
class NotificationPreferencesNotifier extends StateNotifier<AsyncValue<Map<String, NotificationPreference>>> {
  final NotificationRepository _repository;

  NotificationPreferencesNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> fetchPreferences() async {
    state = const AsyncValue.loading();
    try {
      final prefsData = await _repository.getNotificationPreferences();
      final Map<String, NotificationPreference> prefsMap = {};
      for (var data in prefsData) {
        final pref = NotificationPreference.fromJson(data);
        prefsMap[pref.category] = pref;
      }
      state = AsyncValue.data(prefsMap);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Notification Preferences Notifier Provider
final notificationPreferencesProvider =
    StateNotifierProvider<NotificationPreferencesNotifier, AsyncValue<Map<String, NotificationPreference>>>((
      ref,
    ) {
      return NotificationPreferencesNotifier(ref.read(notificationRepositoryProvider))..fetchPreferences();
    });

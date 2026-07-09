import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/transaction_model.dart';
import 'package:valarpay/features/repositories/wallet_repository.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

/// Repository provider
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.read(apiClientProvider));
});

/// Transaction Notifier for managing transaction history state
class TransactionNotifier extends StateNotifier<DataState<TransactionModel>> {
  final WalletRepository _repository;
  final Ref _ref;

  TransactionNotifier(this._repository, this._ref)
    : super(DataState<TransactionModel>.initial());

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  List<TransactionModel> _allTransactions = [];

  // Filters
  String? _statusFilter;
  String? _dateFromFilter;
  String? _dateToFilter;
  String? _typeFilter;
  String? _categoryFilter;
  int? _limitFilter;

  // Getters for pagination info
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  /// Fetch transactions with optional filters
  Future<void> fetchTransactions({
    bool refresh = false,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? type,
    String? category,
    int? limit,
  }) async {
    // Reset on refresh or filter change
    if (refresh ||
        status != _statusFilter ||
        dateFrom != _dateFromFilter ||
        dateTo != _dateToFilter ||
        type != _typeFilter ||
        category != _categoryFilter ||
        limit != _limitFilter) {
      _currentPage = 1;
      _allTransactions = [];
      _hasMore = true;
      _statusFilter = status;
      _dateFromFilter = dateFrom;
      _dateToFilter = dateTo;
      _typeFilter = type;
      _categoryFilter = category;
      _limitFilter = limit;
    }

    // Don't fetch if no more data
    if (!_hasMore && !refresh) return;

    // Set loading state based on whether it's initial load or pagination
    state = state.copyWith(
      isInitialLoading: _currentPage == 1,
      isPaginating: _currentPage > 1,
      message: null,
    );

    final userData = _ref.read(userNotifierProvider).data;
    final user =
        userData != null && userData.isNotEmpty ? userData.first : null;
    if (user == null) {
      state = state.copyWith(
        isInitialLoading: false,
        isPaginating: false,
        isDataAvailable: false,
        message: 'User not authenticated.',
      );
      return;
    }
    final userId = user.id;
    log('Fetching transactions for userId: $userId');

    try {
      final response = await _repository.getAllTransactions(
        page: _currentPage,
        limit: _limitFilter != null ? _limitFilter : 20,
        status: _statusFilter,
        dateFrom: _dateFromFilter,
        dateTo: _dateToFilter,
        userId: userId,
        type: _typeFilter,
        category: _categoryFilter,
      );

      _totalPages = response.totalPages;
      _hasMore = _currentPage < _totalPages;

      // Add new transactions to the list
      if (refresh || _currentPage == 1) {
        _allTransactions = response.transactions;
      } else {
        _allTransactions.addAll(response.transactions);
      }

      state = state.copyWith(
        isInitialLoading: false,
        isPaginating: false,
        data: _allTransactions,
        isDataAvailable: _allTransactions.isNotEmpty,
        message: response.message,
      );
    } catch (e, stack) {
      log('[TransactionNotifier fetchTransactions] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isPaginating: false,
        isDataAvailable: false,
        message: 'Failed to load transactions: ${e.toString()}',
      );
    }
  }

  /// Load more transactions (pagination)
  Future<void> loadMore() async {
    if (!_hasMore || state.isInitialLoading || state.isPaginating) return;

    _currentPage++;
    await fetchTransactions(
      status: _statusFilter,
      dateFrom: _dateFromFilter,
      dateTo: _dateToFilter,
      type: _typeFilter,
      category: _categoryFilter,
      limit: _limitFilter,
    );
  }

  /// Refresh transactions (pull to refresh)
  Future<void> refresh() async {
    await fetchTransactions(refresh: true);
  }

  /// Filter by status
  Future<void> filterByStatus(String? status) async {
    await fetchTransactions(refresh: true, status: status);
  }

  /// Filter by date range
  Future<void> filterByDateRange(String? dateFrom, String? dateTo) async {
    await fetchTransactions(refresh: true, dateFrom: dateFrom, dateTo: dateTo);
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    await fetchTransactions(
      refresh: true,
      status: null,
      dateFrom: null,
      dateTo: null,
    );
  }

  /// Check status of a bill or gift card transaction
  Future<String?> checkTransactionStatus({
    required String transactionId,
    required String billRef,
    required bool isGiftCard,
  }) async {
    try {
      final Map<String, dynamic> result;
      if (isGiftCard) {
        result = await _repository.checkGiftCardStatus(billRef: billRef);
      } else {
        result = await _repository.checkBillStatus(billRef: billRef);
      }
      
      final String? apiStatus = result['status'];
      if (apiStatus != null) {
        final String mappedStatus = apiStatus.toLowerCase();
        
        // Find and update in _allTransactions
        for (var i = 0; i < _allTransactions.length; i++) {
          if (_allTransactions[i].id == transactionId) {
            _allTransactions[i] = TransactionModel(
              id: _allTransactions[i].id,
              walletId: _allTransactions[i].walletId,
              transactionRef: _allTransactions[i].transactionRef,
              type: _allTransactions[i].type,
              category: _allTransactions[i].category,
              currency: _allTransactions[i].currency,
              status: mappedStatus,
              description: _allTransactions[i].description,
              previousBalance: _allTransactions[i].previousBalance,
              currentBalance: _allTransactions[i].currentBalance,
              reference: _allTransactions[i].reference,
              billDetails: _allTransactions[i].billDetails,
              transferDetails: _allTransactions[i].transferDetails,
              depositDetails: _allTransactions[i].depositDetails,
              createdAt: _allTransactions[i].createdAt,
              updatedAt: DateTime.now(),
            );
            break;
          }
        }
        
        // Update state data list
        if (state.data != null) {
          final updatedList = state.data!.map((tx) {
            if (tx.id == transactionId) {
              return TransactionModel(
                id: tx.id,
                walletId: tx.walletId,
                transactionRef: tx.transactionRef,
                type: tx.type,
                category: tx.category,
                currency: tx.currency,
                status: mappedStatus,
                description: tx.description,
                previousBalance: tx.previousBalance,
                currentBalance: tx.currentBalance,
                reference: tx.reference,
                billDetails: tx.billDetails,
                transferDetails: tx.transferDetails,
                depositDetails: tx.depositDetails,
                createdAt: tx.createdAt,
                updatedAt: DateTime.now(),
              );
            }
            return tx;
          }).toList();
          
          state = state.copyWith(data: updatedList);
        }
        return apiStatus;
      }
      return null;
    } catch (e, stack) {
      log('[TransactionNotifier checkTransactionStatus] $e\n$stack');
      rethrow;
    }
  }

  /// Reset state
  void reset() {
    _currentPage = 1;
    _totalPages = 1;
    _hasMore = true;
    _allTransactions = [];
    _statusFilter = null;
    _dateFromFilter = null;
    _dateToFilter = null;
    _typeFilter = null;
    _categoryFilter = null;
    state = DataState<TransactionModel>.initial();
  }
}

/// Transaction Notifier Provider
final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, DataState<TransactionModel>>((
      ref,
    ) {
      return TransactionNotifier(ref.read(walletRepositoryProvider), ref);
    });

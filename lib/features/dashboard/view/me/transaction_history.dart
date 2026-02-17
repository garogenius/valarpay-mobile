import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import '../../widgets/me_widgets/category.dart';
import '../../widgets/me_widgets/status_selection.dart';
import '../../widgets/me_widgets/modal/date_picker_modal.dart';
import '../../widgets/transaction_widgets/transaction_item_widget.dart';

import '../../widgets/transaction_widgets/transaction_shimmer_loader.dart';
import '../../widgets/transaction_widgets/empty_transactions_widget.dart';
import '../../../notifiers/transaction_notifier.dart';

// State providers for UI state
final selectedMonthProvider = StateProvider<String>((ref) => 'OCT 2025');
final selectedStatusFilterProvider = StateProvider<String?>((ref) => null);
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

class TransactionHistoryPage extends ConsumerStatefulWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TransactionHistoryPage> createState() =>
      _TransactionHistoryPageState();
}

class _TransactionHistoryPageState
    extends ConsumerState<TransactionHistoryPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch transactions on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTransactions();
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Setup search listener
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Handle search query changes
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  // Fetch transactions
  void _fetchTransactions() {
    ref.read(transactionNotifierProvider.notifier).fetchTransactions();
  }

  // Handle scroll for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final notifier = ref.read(transactionNotifierProvider.notifier);
      if (notifier.hasMore) {
        notifier.loadMore();
      }
    }
  }

  // Handle refresh
  Future<void> _handleRefresh() async {
    await ref.read(transactionNotifierProvider.notifier).refresh();
  }

  // Show filter bottom sheet
  void _showFilterBottomSheet() {
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
            children: [
              // All Categories Dropdown
              GestureDetector(
                onTap: _handleCategorySelection,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'All Categories',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontFamily: 'SF Pro',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // All Status Dropdown
              GestureDetector(
                onTap: _handleStatusSelection,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'All Status',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontFamily: 'SF Pro',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Handle category selection
  void _handleCategorySelection() {
    Navigator.pop(context); // Close current sheet
    showCategorySelection(context); // Show category selection
  }

  // Handle status selection
  void _handleStatusSelection() {
    Navigator.pop(context); // Close current sheet
    showStatusSelection(context); // Show status selection
  }

  // Handle date picker
  void _handleDatePicker() {
    final selectedMonth = ref.read(selectedMonthProvider);
    DatePickerModal.show(
      context,
      currentMonth: selectedMonth,
      onDateSelected: (newDate) {
        ref.read(selectedMonthProvider.notifier).state = newDate;
        // You can implement date filtering here if needed
      },
    );
  }

  // Navigate to statement
  void _navigateToStatement() {
    context.push('/account-statement');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);
    final isBvnVerified = user?.isBvnVerified ?? false;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final transactionState = ref.watch(transactionNotifierProvider);
    final transactions = transactionState.data ?? [];

    // Parse selectedMonth (e.g., 'OCT 2025')
    DateTime? monthStart;
    DateTime? monthEnd;
    try {
      final parts = selectedMonth.split(' ');
      if (parts.length == 2) {
        final month = DateFormat.MMM().parse(parts[0]).month;
        final year = int.parse(parts[1]);
        monthStart = DateTime(year, month, 1);
        monthEnd = DateTime(
          year,
          month + 1,
          1,
        ).subtract(const Duration(days: 1));
      }
    } catch (_) {}

    // Filter transactions by selected month
    var filteredTransactions =
        (monthStart != null && monthEnd != null)
            ? transactions.where((tx) {
              final DateTime txDate = tx.createdAt;
              return !txDate.isBefore(monthStart!) &&
                  !txDate.isAfter(monthEnd!);
            }).toList()
            : transactions;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredTransactions =
          filteredTransactions.where((tx) {
            final description = tx.description.toLowerCase();
            final reference = tx.reference?.toLowerCase() ?? '';
            final amount = tx.amount.toString();
            final status = tx.status.toLowerCase();
            final beneficiaryName =
                tx.depositDetails?.beneficiaryName?.toLowerCase() ?? '';
            final senderName =
                tx.depositDetails?.senderName?.toLowerCase() ?? '';

            return description.contains(_searchQuery) ||
                reference.contains(_searchQuery) ||
                amount.contains(_searchQuery) ||
                beneficiaryName.contains(_searchQuery) ||
                senderName.contains(_searchQuery) ||
                status.contains(_searchQuery);
          }).toList();
    }

    // Calculate totals for filtered transactions (only successful)
    double totalIn = 0;
    double totalOut = 0;
    for (var transaction in filteredTransactions) {
      if (transaction.status == 'success') {
        if (transaction.isCredit) {
          totalIn += transaction.amount;
        } else {
          totalOut += transaction.amount;
        }
      }
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Transaction History',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontFamily: 'SF Pro', 
            fontSize: 18, 
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: _navigateToStatement,
                child: const Text(
                  'Statement',
                  style: TextStyle(
                    color: Color(0xFFF76301),
                    fontFamily: 'SF Pro',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body:
          !isBvnVerified
              ? const KycNotSetWidget(
                title: 'KYC Not Completed',
                subtitle:
                    'Complete your KYC verification to view transaction history',
              )
              : RefreshIndicator(
                onRefresh: _handleRefresh,
                color: const Color(0xFFF76301),
                child: Column(
                  children: [
                    // Header section with search and filters
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Bar
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 44,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark ? Colors.transparent : Colors.grey.withOpacity(0.2)
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 18,
                                  color: isDark ? Colors.white24 : Colors.grey[400],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                    decoration: InputDecoration(
                                      hintText: 'Search transactions...',
                                      hintStyle: TextStyle(
                                        color: isDark ? Colors.white24 : Colors.grey[400],
                                        fontFamily: 'SF Pro',
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                    child: Icon(
                                      Icons.clear,
                                      size: 18,
                                      color: isDark ? Colors.white24 : Colors.grey[400],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Month Selector and Sort By
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Month Selector
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: _handleDatePicker,
                                    child: Row(
                                      children: [
                                        Text(
                                          selectedMonth,
                                          style: TextStyle(
                                            color: isDark ? Colors.white : Colors.black,
                                            fontFamily: 'SF Pro',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 18,
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'In ${currencyFormatter(totalIn.toStringAsFixed(2))}',
                                        style: TextStyle(
                                          color: isDark ? Colors.white54 : Colors.black54,
                                          fontFamily: 'SF Pro',
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Out ${currencyFormatter(totalOut.toStringAsFixed(2))}',
                                        style: TextStyle(
                                          color: isDark ? Colors.white54 : Colors.black54,
                                          fontFamily: 'SF Pro',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Sort By Button
                              GestureDetector(
                                onTap: _showFilterBottomSheet,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF76301),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.filter_list,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Sort by',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'SF Pro',
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Transactions List
                    Expanded(
                      child: _buildTransactionsList(
                        transactionState,
                        filteredTransactions,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  // Build transactions list based on state and filtered transactions
  Widget _buildTransactionsList(
    dynamic transactionState,
    List filteredTransactions,
  ) {
    // Loading state
    if (transactionState.isInitialLoading) {
      return const TransactionShimmerLoader();
    }

    // Error state
    if (!transactionState.isDataAvailable && transactionState.message != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              transactionState.message ?? 'Failed to load transactions',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchTransactions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (filteredTransactions.isEmpty) {
      return EmptyTransactionsWidget(onRefresh: _fetchTransactions);
    }

    // Success state with filtered data
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount:
          filteredTransactions.length + (transactionState.isPaginating ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loader at bottom if loading more
        if (index == filteredTransactions.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final transaction = filteredTransactions[index];
        return TransactionItemWidget(
          transaction: transaction,
          onTap: () {
            context.push('/transaction-details', extra: transaction);
          },
        );
      },
    );
  }
}

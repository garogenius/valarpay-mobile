import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/investment_models.dart';
import 'package:valarpay/features/repositories/investment_repository.dart';
import 'package:valarpay/core/network/api_client.dart';

final investmentRepositoryProvider = Provider<InvestmentRepository>((ref) {
  return InvestmentRepository(ref.read(apiClientProvider));
});

class InvestmentProductNotifier extends StateNotifier<DataState<InvestmentProduct>> {
  final InvestmentRepository _repository;

  InvestmentProductNotifier(this._repository) : super(DataState<InvestmentProduct>.initial());

  Future<void> fetchProductInfo() async {
    // Return early if we already have data to make it "very fast"
    if (state.isDataAvailable && state.data != null && state.data!.isNotEmpty) {
       return;
    }
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final product = await _repository.getProductInfo();
      state = state.copyWith(
        data: [product],
        isDataAvailable: true,
        message: 'Product information loaded',
      );
    } catch (e, stack) {
      log('[InvestmentProductNotifier fetchProductInfo] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

class InvestmentListNotifier extends StateNotifier<DataState<Investment>> {
  final InvestmentRepository _repository;

  InvestmentListNotifier(this._repository) : super(DataState<Investment>.initial());

  Future<void> fetchUserInvestments({
    String? status,
    int page = 1,
    int limit = 20,
    bool isBackgroundLoad = false,
  }) async {
    // If not background load, show loader. If background load but no data, show loader.
    if (!isBackgroundLoad || !state.isDataAvailable) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
    
    try {
      final investments = await _repository.getUserInvestments(
        status: status,
        page: page,
        limit: limit,
      );
      state = state.copyWith(
        data: investments,
        isDataAvailable: investments.isNotEmpty,
        message: 'Investments loaded',
      );
    } catch (e, stack) {
      log('[InvestmentListNotifier fetchUserInvestments] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

class InvestmentActionNotifier extends StateNotifier<DataState<CreateInvestmentResponse>> {
  final InvestmentRepository _repository;

  InvestmentActionNotifier(this._repository) : super(DataState<CreateInvestmentResponse>.initial());

  Future<bool> createInvestment(CreateInvestmentRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final response = await _repository.createInvestment(request);
      state = state.copyWith(
        data: [response],
        isDataAvailable: true,
        message: 'Investment created successfully',
      );
      return true;
    } catch (e, stack) {
      log('[InvestmentActionNotifier createInvestment] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: e.toString(),
      );
      return false;
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

class InvestmentDetailsNotifier extends StateNotifier<DataState<Investment>> {
  final InvestmentRepository _repository;

  InvestmentDetailsNotifier(this._repository) : super(DataState<Investment>.initial());

  Future<void> fetchInvestmentDetails(String id) async {
    // Check if we already have this investment loaded
    final current = state.data?.firstOrNull;
    if (current == null || current.id != id) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
    
    try {
      final investment = await _repository.getInvestmentDetails(id);
      state = state.copyWith(
        data: [investment],
        isDataAvailable: true,
        message: 'Investment details loaded',
      );
    } catch (e, stack) {
      log('[InvestmentDetailsNotifier fetchInvestmentDetails] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

final investmentProductNotifierProvider = StateNotifierProvider<InvestmentProductNotifier, DataState<InvestmentProduct>>((ref) {
  return InvestmentProductNotifier(ref.read(investmentRepositoryProvider));
});

final investmentListNotifierProvider = StateNotifierProvider<InvestmentListNotifier, DataState<Investment>>((ref) {
  return InvestmentListNotifier(ref.read(investmentRepositoryProvider));
});

final investmentActionNotifierProvider = StateNotifierProvider<InvestmentActionNotifier, DataState<CreateInvestmentResponse>>((ref) {
  return InvestmentActionNotifier(ref.read(investmentRepositoryProvider));
});

final investmentDetailsNotifierProvider = StateNotifierProvider<InvestmentDetailsNotifier, DataState<Investment>>((ref) {
  return InvestmentDetailsNotifier(ref.read(investmentRepositoryProvider));
});

import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/remita_models.dart';
import 'package:valarpay/features/repositories/remita_repository.dart';

final remitaRepositoryProvider = Provider<RemitaRepository>((ref) {
  return RemitaRepository(ref.read(apiClientProvider));
});

class RemitaCategoriesNotifier extends StateNotifier<DataState<RemitaCategory>> {
  final RemitaRepository _repository;

  RemitaCategoriesNotifier(this._repository) : super(DataState<RemitaCategory>.initial());

  Future<void> fetchCategories({bool isOverlayHidden = false}) async {
    state = state.copyWith(
      isInitialLoading: true,
      message: null,
      isOverlayHidden: isOverlayHidden,
    );
    try {
      final categories = await _repository.getCategories();
      state = state.copyWith(data: categories, isDataAvailable: true, message: null);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false, isOverlayHidden: false);
    }
  }
}

class RemitaBillersNotifier extends StateNotifier<DataState<RemitaBiller>> {
  final RemitaRepository _repository;

  RemitaBillersNotifier(this._repository) : super(DataState<RemitaBiller>.initial());

  Future<void> fetchBillers(String categoryId, {bool isOverlayHidden = false}) async {
    state = DataState<RemitaBiller>.initial().copyWith(
      isInitialLoading: true,
      message: null,
      isOverlayHidden: isOverlayHidden,
    );
    try {
      final billers = await _repository.getBillersByCategory(categoryId);
      // print(
      //   '[RemitaBillersNotifier] Category $categoryId returned ${billers.length} billers',
      // );
      state = state.copyWith(data: billers, isDataAvailable: true, message: null);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false, isOverlayHidden: false);
    }
  }
}

class RemitaProductsNotifier extends StateNotifier<DataState<RemitaProduct>> {
  final RemitaRepository _repository;

  RemitaProductsNotifier(this._repository) : super(DataState<RemitaProduct>.initial());

  Future<void> fetchProducts(String billerId, {bool isOverlayHidden = false}) async {
    state = state.copyWith(
      isInitialLoading: true,
      message: null,
      isOverlayHidden: isOverlayHidden,
    );
    try {
      final products = await _repository.getBillerProducts(billerId);
      state = state.copyWith(data: products, isDataAvailable: true, message: null);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false, isOverlayHidden: false);
    }
  }

  Future<void> fetchVendingProducts({
    String? categoryCode,
    String? provider,
    bool isOverlayHidden = false,
  }) async {
    state = state.copyWith(
      isInitialLoading: true,
      message: null,
      isOverlayHidden: isOverlayHidden,
    );
    try {
      final products = await _repository.getVendingProducts(
        categoryCode: categoryCode,
        provider: provider,
      );
      state = state.copyWith(data: products, isDataAvailable: true, message: null);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false, isOverlayHidden: false);
    }
  }
}

class RemitaValidationNotifier extends StateNotifier<DataState<RemitaCustomerValidation>> {
  final RemitaRepository _repository;

  RemitaValidationNotifier(this._repository) : super(DataState<RemitaCustomerValidation>.initial());

  Future<void> validate({
    required String billPaymentProductId,
    required String customerId,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.validateCustomer(
        billPaymentProductId: billPaymentProductId,
        customerId: customerId,
      );
      state = state.copyWith(data: [res], isDataAvailable: true, message: null);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

class RemitaPaymentNotifier extends StateNotifier<DataState<RemitaPaymentResponse>> {
  final RemitaRepository _repository;

  RemitaPaymentNotifier(this._repository) : super(DataState<RemitaPaymentResponse>.initial());

  Future<RemitaInitiationResponse?> initiate(RemitaInitiateRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      return await _repository.initiatePayment(request);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
      return null;
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  Future<void> pay(RemitaPaymentRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null, isDataAvailable: false);
    try {
      final res = await _repository.payBill(request);
      state = state.copyWith(data: [res], isDataAvailable: true, message: res.message);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  void reset() {
    state = DataState<RemitaPaymentResponse>.initial();
  }
}

final remitaCategoriesProvider = StateNotifierProvider.autoDispose<RemitaCategoriesNotifier, DataState<RemitaCategory>>((ref) {
  return RemitaCategoriesNotifier(ref.watch(remitaRepositoryProvider));
});

final remitaBillersProvider = StateNotifierProvider.autoDispose<RemitaBillersNotifier, DataState<RemitaBiller>>((ref) {
  return RemitaBillersNotifier(ref.watch(remitaRepositoryProvider));
});

final remitaProductsProvider = StateNotifierProvider.autoDispose<RemitaProductsNotifier, DataState<RemitaProduct>>((ref) {
  return RemitaProductsNotifier(ref.watch(remitaRepositoryProvider));
});

final remitaValidationProvider = StateNotifierProvider.autoDispose<RemitaValidationNotifier, DataState<RemitaCustomerValidation>>((ref) {
  return RemitaValidationNotifier(ref.watch(remitaRepositoryProvider));
});

final remitaPaymentProvider = StateNotifierProvider.autoDispose<RemitaPaymentNotifier, DataState<RemitaPaymentResponse>>((ref) {
  return RemitaPaymentNotifier(ref.watch(remitaRepositoryProvider));
});

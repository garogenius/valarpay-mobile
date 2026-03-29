import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/flutterwave_bill_models.dart';
import 'package:valarpay/features/repositories/flutterwave_bill_repository.dart';

final flutterwaveBillRepositoryProvider = Provider<FlutterwaveBillRepository>((ref) {
  return FlutterwaveBillRepository(ref.read(apiClientProvider));
});

class FlutterwaveCategoriesNotifier extends StateNotifier<DataState<FlutterwaveCategory>> {
  final FlutterwaveBillRepository _repository;

  FlutterwaveCategoriesNotifier(this._repository)
      : super(DataState<FlutterwaveCategory>.initial());

  Future<void> fetchCategories({bool isOverlayHidden = false}) async {
    state = state.copyWith(
      isInitialLoading: true,
      message: null,
      isOverlayHidden: isOverlayHidden,
    );
    try {
      final res = await _repository.getCategories();
      state = state.copyWith(data: res.data, isDataAvailable: true);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false, isOverlayHidden: false);
    }
  }
}

class FlutterwaveBillersNotifier extends StateNotifier<DataState<FlutterwaveBiller>> {
  final FlutterwaveBillRepository _repository;

  FlutterwaveBillersNotifier(this._repository)
      : super(DataState<FlutterwaveBiller>.initial());

  Future<void> fetchBillers(String categoryCode, {bool isOverlayHidden = false}) async {
    state = state.copyWith(
      isInitialLoading: true,
      message: null,
      isOverlayHidden: isOverlayHidden,
      isDataAvailable: false, // Clear previous data
    );
    try {
      final res = await _repository.getBillers(categoryCode);
      state = state.copyWith(data: res.data, isDataAvailable: true);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false, isOverlayHidden: false);
    }
  }

  void reset() {
    state = DataState<FlutterwaveBiller>.initial();
  }
}

class FlutterwaveProductsNotifier extends StateNotifier<DataState<FlutterwaveProduct>> {
  final FlutterwaveBillRepository _repository;

  FlutterwaveProductsNotifier(this._repository) : super(DataState<FlutterwaveProduct>.initial());

  Future<void> fetchProducts(String billerCode, String categoryCode, {bool isOverlayHidden = false}) async {
    state = state.copyWith(
      isInitialLoading: true, 
      message: null,
      isOverlayHidden: isOverlayHidden,
      isDataAvailable: false,
    );
    try {
      final res = await _repository.getBillerProducts(billerCode, categoryCode);
      state = state.copyWith(data: res.data, isDataAvailable: true);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false, isOverlayHidden: false);
    }
  }

  void reset() {
    state = DataState<FlutterwaveProduct>.initial();
  }
}

class FlutterwaveValidationNotifier extends StateNotifier<DataState<FlutterwaveCustomerValidation>> {
  final FlutterwaveBillRepository _repository;

  FlutterwaveValidationNotifier(this._repository)
      : super(DataState<FlutterwaveCustomerValidation>.initial());

  Future<void> validate({
    required String billPaymentProductId,
    required String customerId,
    required String billerCode,
    bool isOverlayHidden = false,
  }) async {
    state = state.copyWith(
      isInitialLoading: true,
      message: null,
      isOverlayHidden: isOverlayHidden,
    );
    try {
      final res = await _repository.validateCustomer(
        billPaymentProductId: billPaymentProductId,
        customerId: customerId,
        billerCode: billerCode,
      );
      state = state.copyWith(data: [res], isDataAvailable: true);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false, isOverlayHidden: false);
    }
  }

  void reset() {
    state = DataState<FlutterwaveCustomerValidation>.initial();
  }
}

class FlutterwaveBillPaymentNotifier extends StateNotifier<DataState<FlutterwavePaymentResponse>> {
  final FlutterwaveBillRepository _repository;

  FlutterwaveBillPaymentNotifier(this._repository)
      : super(DataState<FlutterwavePaymentResponse>.initial());

  Future<void> pay(FlutterwavePaymentRequest request, {bool isOverlayHidden = false}) async {
    state = state.copyWith(
      isInitialLoading: true, 
      message: null, 
      isDataAvailable: false,
      isOverlayHidden: isOverlayHidden,
    );
    try {
      final res = await _repository.payBill(request);
      state = state.copyWith(data: [res], isDataAvailable: true, message: res.message);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false, isOverlayHidden: false);
    }
  }

  void reset() {
    state = DataState<FlutterwavePaymentResponse>.initial();
  }
}

final flutterwaveCategoriesProvider = StateNotifierProvider.autoDispose<FlutterwaveCategoriesNotifier,
    DataState<FlutterwaveCategory>>((ref) {
  return FlutterwaveCategoriesNotifier(ref.watch(flutterwaveBillRepositoryProvider));
});

final flutterwaveBillersProvider = StateNotifierProvider.autoDispose<FlutterwaveBillersNotifier,
    DataState<FlutterwaveBiller>>((ref) {
  return FlutterwaveBillersNotifier(ref.watch(flutterwaveBillRepositoryProvider));
});

final flutterwaveProductsProvider = StateNotifierProvider.autoDispose<FlutterwaveProductsNotifier,
    DataState<FlutterwaveProduct>>((ref) {
  return FlutterwaveProductsNotifier(ref.watch(flutterwaveBillRepositoryProvider));
});

final flutterwaveValidationProvider = StateNotifierProvider.autoDispose<FlutterwaveValidationNotifier,
    DataState<FlutterwaveCustomerValidation>>((ref) {
  return FlutterwaveValidationNotifier(ref.watch(flutterwaveBillRepositoryProvider));
});

final flutterwaveBillPaymentProvider = StateNotifierProvider.autoDispose<FlutterwaveBillPaymentNotifier,
    DataState<FlutterwavePaymentResponse>>((ref) {
  return FlutterwaveBillPaymentNotifier(ref.watch(flutterwaveBillRepositoryProvider));
});

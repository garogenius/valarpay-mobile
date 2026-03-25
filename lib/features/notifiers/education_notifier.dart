import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/education_models.dart';
import 'package:valarpay/features/repositories/education_repository.dart';

final educationRepositoryProvider = Provider<EducationRepository>((ref) {
  return EducationRepository(ref.read(apiClientProvider));
});

class SchoolBillersNotifier extends StateNotifier<DataState<EducationBiller>> {
  final EducationRepository _repository;

  SchoolBillersNotifier(this._repository) : super(DataState<EducationBiller>.initial());

  Future<void> fetchBillers({bool useRemita = false}) async {
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
    try {
      final billers = useRemita 
          ? await _repository.getRemitaSchoolBillers()
          : await _repository.getSchoolBillers();
      state = state.copyWith(
        data: billers,
        isDataAvailable: true,
      );
    } catch (e, stack) {
      log('[SchoolBillersNotifier fetchBillers] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

class VendingProvidersNotifier extends StateNotifier<DataState<EducationBiller>> {
  final EducationRepository _repository;

  VendingProvidersNotifier(this._repository) : super(DataState<EducationBiller>.initial());

  Future<void> fetchProviders() async {
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
    try {
      final providers = await _repository.getVendingProviders();
      state = state.copyWith(
        data: providers,
        isDataAvailable: true,
      );
    } catch (e, stack) {
      log('[VendingProvidersNotifier fetchProviders] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

class EducationProductsNotifier extends StateNotifier<DataState<EducationProduct>> {
  final EducationRepository _repository;

  EducationProductsNotifier(this._repository) : super(DataState<EducationProduct>.initial());

  Future<void> fetchBillerItems(String billerCode) async {
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
    try {
      final items = await _repository.getEducationBillerItems(billerCode);
      state = state.copyWith(
        data: items,
        isDataAvailable: true,
      );
    } catch (e, stack) {
      log('[EducationProductsNotifier fetchBillerItems] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  Future<void> fetchVendingProducts(String provider) async {
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
    try {
      final items = await _repository.getVendingProducts(provider: provider);
      state = state.copyWith(
        data: items,
        isDataAvailable: true,
      );
    } catch (e, stack) {
      log('[EducationProductsNotifier fetchVendingProducts] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

class EducationVerificationNotifier extends StateNotifier<DataState<EducationVerificationResponse>> {
  final EducationRepository _repository;

  EducationVerificationNotifier(this._repository) : super(DataState<EducationVerificationResponse>.initial());

  Future<void> verifySchoolCustomer({
    required String itemCode,
    required String billerCode,
    required String billerNumber,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.verifySchoolCustomer(
        itemCode: itemCode,
        billerCode: billerCode,
        billerNumber: billerNumber,
      );
      state = state.copyWith(data: [res], isDataAvailable: true);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  Future<void> verifyWaec({required String itemCode, required String billerNumber}) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.verifyWaecBillerNumber(itemCode: itemCode, billerNumber: billerNumber);
      state = state.copyWith(data: [res], isDataAvailable: true);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  Future<void> verifyJamb({required String itemCode, required String billerNumber}) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.verifyJambBillerNumber(itemCode: itemCode, billerNumber: billerNumber);
      state = state.copyWith(data: [res], isDataAvailable: true);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

class EducationPurchaseNotifier extends StateNotifier<DataState<EducationPaymentResponse>> {
  final EducationRepository _repository;

  EducationPurchaseNotifier(this._repository) : super(DataState<EducationPaymentResponse>.initial());

  Future<void> paySchoolFees(EducationPaymentRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.paySchoolFees(request);
      state = state.copyWith(data: [res], isDataAvailable: true, message: res.message);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  Future<void> payWaec(EducationPaymentRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.payWaec(request);
      state = state.copyWith(data: [res], isDataAvailable: true, message: res.message);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  Future<void> payJamb(EducationPaymentRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.payJamb(request);
      state = state.copyWith(data: [res], isDataAvailable: true, message: res.message);
    } catch (e) {
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

final schoolBillersProvider = StateNotifierProvider<SchoolBillersNotifier, DataState<EducationBiller>>((ref) {
  return SchoolBillersNotifier(ref.read(educationRepositoryProvider));
});

final vendingProvidersProvider = StateNotifierProvider<VendingProvidersNotifier, DataState<EducationBiller>>((ref) {
  return VendingProvidersNotifier(ref.read(educationRepositoryProvider));
});

final educationProductsProvider = StateNotifierProvider<EducationProductsNotifier, DataState<EducationProduct>>((ref) {
  return EducationProductsNotifier(ref.read(educationRepositoryProvider));
});

final educationVerificationProvider = StateNotifierProvider<EducationVerificationNotifier, DataState<EducationVerificationResponse>>((ref) {
  return EducationVerificationNotifier(ref.read(educationRepositoryProvider));
});

final educationPurchaseProvider = StateNotifierProvider<EducationPurchaseNotifier, DataState<EducationPaymentResponse>>((ref) {
  return EducationPurchaseNotifier(ref.read(educationRepositoryProvider));
});

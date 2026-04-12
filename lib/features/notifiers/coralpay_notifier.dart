import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/data_state.dart';
import '../../core/network/api_client.dart';
import '../models/coralpay_models.dart';
import '../repositories/coralpay_repository.dart';

final coralPayRepositoryProvider = Provider<CoralPayRepository>((ref) {
  return CoralPayRepository(ref.read(apiClientProvider));
});

// Notifier for CoralPay Billers
class CoralPayBillersNotifier extends StateNotifier<DataState<CoralPayBiller>> {
  final CoralPayRepository _repository;

  CoralPayBillersNotifier(this._repository) : super(DataState.initial());

  Future<void> fetchBillers(String groupSlug) async {
    state = state.toLoading();
    try {
      // Fetch and log groups for debugging as requested
      await _repository.getGroups();
      
      final billers = await _repository.getBillers(groupSlug);
      state = state.toDataAvailable(billers);
    } catch (e) {
      state = state.toError(e.toString());
    }
  }
}

final coralPayBillersProvider =
    StateNotifierProvider<CoralPayBillersNotifier, DataState<CoralPayBiller>>((ref) {
  return CoralPayBillersNotifier(ref.read(coralPayRepositoryProvider));
});

// Notifier for CoralPay Packages
class CoralPayPackagesNotifier extends StateNotifier<DataState<CoralPayPackage>> {
  final CoralPayRepository _repository;

  CoralPayPackagesNotifier(this._repository) : super(DataState.initial());

  Future<void> fetchPackages(String billerSlug) async {
    state = state.toLoading();
    try {
      final packages = await _repository.getPackages(billerSlug);
      state = state.toDataAvailable(packages);
    } catch (e) {
      state = state.toError(e.toString());
    }
  }
}

final coralPayPackagesProvider =
    StateNotifierProvider<CoralPayPackagesNotifier, DataState<CoralPayPackage>>((ref) {
  return CoralPayPackagesNotifier(ref.read(coralPayRepositoryProvider));
});

// Notifier for CoralPay Verification
class CoralPayVerificationNotifier extends StateNotifier<DataState<CoralPayCustomerVerification>> {
  final CoralPayRepository _repository;

  CoralPayVerificationNotifier(this._repository) : super(DataState.initial());

  Future<bool> verify({
    required String customerId,
    required String billerSlug,
    required String productName,
  }) async {
    state = state.toLoading();
    try {
      final verification = await _repository.verifyCustomer(
        customerId: customerId,
        billerSlug: billerSlug,
        productName: productName,
      );
      state = state.toSingleDataAvailable(verification);
      return true;
    } catch (e) {
      state = state.toError(e.toString());
      return false;
    }
  }

  void reset() {
    state = DataState.initial();
  }
}

final coralPayVerificationProvider =
    StateNotifierProvider<CoralPayVerificationNotifier, DataState<CoralPayCustomerVerification>>((ref) {
  return CoralPayVerificationNotifier(ref.read(coralPayRepositoryProvider));
});

// Notifier for CoralPay Payment
class CoralPayPaymentNotifier extends StateNotifier<DataState<CoralPayPaymentResponse>> {
  final CoralPayRepository _repository;

  CoralPayPaymentNotifier(this._repository) : super(DataState.initial());

  Future<bool> pay(CoralPayPaymentRequest request) async {
    state = state.toLoading();
    try {
      final response = await _repository.payBill(request);
      if (response.success) {
        state = state.toSingleDataAvailable(response);
        return true;
      } else {
        state = state.toError(response.message);
        return false;
      }
    } catch (e) {
      state = state.toError(e.toString());
      return false;
    }
  }
}

final coralPayPaymentProvider =
    StateNotifierProvider<CoralPayPaymentNotifier, DataState<CoralPayPaymentResponse>>((ref) {
  return CoralPayPaymentNotifier(ref.read(coralPayRepositoryProvider));
});

// Popular Billers Notifier
class PopularCoralPayBillersNotifier extends StateNotifier<DataState<CoralPayBiller>> {
  final CoralPayRepository _repository;

  PopularCoralPayBillersNotifier(this._repository) : super(DataState.initial());

  Future<void> fetchPopularBillers() async {
    state = state.toLoading();
    try {
      final billers = await _repository.getPopularBillers();
      state = state.toDataAvailable(billers);
    } catch (e) {
      state = state.toError(e.toString());
    }
  }
}

final popularCoralPayBillersProvider =
    StateNotifierProvider<PopularCoralPayBillersNotifier, DataState<CoralPayBiller>>((ref) {
  return PopularCoralPayBillersNotifier(ref.read(coralPayRepositoryProvider));
});

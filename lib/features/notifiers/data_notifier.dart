import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/network_provider.dart';
import 'package:valarpay/features/models/data_models.dart';
import 'package:valarpay/features/repositories/data_repository.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

/// Data repository provider
final dataRepositoryProvider = Provider<DataRepository>((ref) {
  return DataRepository(ref.read(apiClientProvider));
});

/// Provider: network providers list (NetworkProvider)
class DataProvidersNotifier extends StateNotifier<DataState<NetworkProvider>> {
  final DataRepository _repository;

  DataProvidersNotifier(this._repository)
    : super(DataState<NetworkProvider>.initial());

  Future<void> fetchProviders() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getDataNetworkProviders();
      state = state.copyWith(
        isInitialLoading: false,
        data: res.providers,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[DataProvidersNotifier fetchProviders] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load providers: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<NetworkProvider>.initial();
}

/// Provider: data plans (DataPlanInfo)
class DataPlansNotifier extends StateNotifier<DataState<DataPlanInfo>> {
  final DataRepository _repository;

  DataPlansNotifier(this._repository)
    : super(DataState<DataPlanInfo>.initial());

  Future<void> getPlans({
    String? phone,
    String? currency,
    String? category,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getDataPlan(
        phone: phone,
        currency: currency,
        category: category,
      );
      state = state.copyWith(
        isInitialLoading: false,
        data: res.plans,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[DataPlansNotifier getPlans] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load plans: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<DataPlanInfo>.initial();
}

/// Provider: data variation (DataPlanBundle)
class DataVariationNotifier extends StateNotifier<DataState<DataPlanBundle>> {
  final DataRepository _repository;

  DataVariationNotifier(this._repository)
    : super(DataState<DataPlanBundle>.initial());

  Future<void> getVariation({
    String? network,
    int? operatorId,
    String? billerId,
    String? filterCategory, // Used for client-side filtering only
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getDataPlansByNetwork(
        network: network,
        operatorId: operatorId,
        billerId: billerId,
      );
      
      // Client-side filtering based on validity days from extInfo
      List<DataPlanBundle> filteredData = res.data;
      
      if (filterCategory != null && filterCategory != 'HOT') {
        filteredData = res.data.where((bundle) {
          final validityDate = bundle.extInfo?.validityDate ?? 0;
          final name = bundle.name.toLowerCase();
          
          switch (filterCategory) {
            case 'Daily':
              return validityDate >= 1 && validityDate <= 3;
            case 'Weekly':
              return validityDate >= 4 && validityDate <= 13;
            case 'Monthly':
              return validityDate >= 14 && validityDate < 360;
            case 'Yearly':
              return validityDate >= 360 || name.contains('year');
            case 'XtraValue':
              final note = bundle.extInfo?.validityAttachNote?.toLowerCase() ?? '';
              final desc = bundle.extInfo?.itemDescription?.toLowerCase() ?? '';
              return name.contains('xtra') || name.contains('extra') || name.contains('talk') || 
                     note.contains('xtra') || desc.contains('xtra') || desc.contains('extra') || desc.contains('talk');
            case 'Social':
              final note = bundle.extInfo?.validityAttachNote?.toLowerCase() ?? '';
              final desc = bundle.extInfo?.itemDescription?.toLowerCase() ?? '';
              return name.contains('social') || 
                     name.contains('whatsapp') || 
                     name.contains('facebook') || 
                     name.contains('instagram') ||
                     name.contains('youtube') ||
                     name.contains('tiktok') ||
                     name.contains('fb/ig') ||
                     note.contains('social') ||
                     note.contains('whatsapp') ||
                     note.contains('facebook') ||
                     note.contains('instagram') ||
                     note.contains('youtube') ||
                     note.contains('tiktok') ||
                     desc.contains('social') ||
                     desc.contains('whatsapp') ||
                     desc.contains('facebook') ||
                     desc.contains('instagram') ||
                     desc.contains('youtube') ||
                     desc.contains('tiktok');
            case 'Broadband':
              final note = bundle.extInfo?.validityAttachNote?.toLowerCase() ?? '';
              final desc = bundle.extInfo?.itemDescription?.toLowerCase() ?? '';
              return name.contains('broadband') || 
                     name.contains('router') || 
                     name.contains('mifi') ||
                     name.contains('hynet') ||
                     note.contains('broadband') ||
                     desc.contains('broadband') ||
                     desc.contains('router') ||
                     desc.contains('mifi') ||
                     desc.contains('hynet');
            default:
              return true; // HOT or unknown - show all
          }
        }).toList();
      }
      
      state = state.copyWith(
        isInitialLoading: false,
        data: filteredData,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[DataVariationNotifier getVariation] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load variation: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<DataPlanBundle>.initial();
}

/// Provider: data purchase
class DataPurchaseNotifier
    extends StateNotifier<DataState<DataPurchaseResponse>> {
  final DataRepository _repository;

  DataPurchaseNotifier(this._repository)
    : super(DataState<DataPurchaseResponse>.initial());

  Future<void> purchase(DataPurchaseRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.payData(request);
      state = state.copyWith(
        isInitialLoading: false,
        data: [res],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[DataPurchaseNotifier purchase] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Purchase failed: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<DataPurchaseResponse>.initial();
}

/// Provider: data beneficiaries
class DataBeneficiaryNotifier
    extends StateNotifier<DataState<DataBeneficiary>> {
  final DataRepository _repository;
  final Ref _ref;

  DataBeneficiaryNotifier(this._repository, this._ref)
    : super(DataState<DataBeneficiary>.initial());

  Future<void> getDataBeneficiaries() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final user = _ref.read(userNotifierProvider).data?.first;
      final userId = user?.id ?? '';
      final response = await _repository.getDataBeneficiaries(userId: userId);

      state = state.copyWith(
        isInitialLoading: false,
        data: response.data,
        isDataAvailable: response.data.isNotEmpty,
        message: response.data.isEmpty ? null : response.message,
      );
    } catch (e, stack) {
      log('[DataBeneficiaryNotifier getDataBeneficiaries] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to get data beneficiaries: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<DataBeneficiary>.initial();
}

// Riverpod providers
final dataProvidersNotifierProvider =
    StateNotifierProvider<DataProvidersNotifier, DataState<NetworkProvider>>(
      (ref) => DataProvidersNotifier(ref.read(dataRepositoryProvider)),
    );

final dataPlansNotifierProvider =
    StateNotifierProvider<DataPlansNotifier, DataState<DataPlanInfo>>(
      (ref) => DataPlansNotifier(ref.read(dataRepositoryProvider)),
    );

final dataVariationNotifierProvider =
    StateNotifierProvider<DataVariationNotifier, DataState<DataPlanBundle>>(
      (ref) => DataVariationNotifier(ref.read(dataRepositoryProvider)),
    );

final dataPurchaseNotifierProvider = StateNotifierProvider<
  DataPurchaseNotifier,
  DataState<DataPurchaseResponse>
>((ref) => DataPurchaseNotifier(ref.read(dataRepositoryProvider)));

final dataBeneficiaryNotifierProvider =
    StateNotifierProvider<DataBeneficiaryNotifier, DataState<DataBeneficiary>>(
      (ref) => DataBeneficiaryNotifier(ref.read(dataRepositoryProvider), ref),
    );

/// UI StateProviders for data screen selections
final dataSelectedNetworkProvider = StateProvider<String>((ref) => 'MTN');
final dataSelectedOperatorIdProvider = StateProvider<int>((ref) => 0);
final dataSelectedBillerIdProvider = StateProvider<String?>((ref) => 'MTN');
final dataSelectedPlanProvider = StateProvider<String>((ref) => '');

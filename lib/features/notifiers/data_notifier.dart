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
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
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
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
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
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
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
          int validityDate = bundle.extInfo?.validityDate ?? 0;
          final name = bundle.name.toLowerCase();
          final validityText = bundle.validity.toLowerCase();
          
          if (validityDate == 0) {
             final match = RegExp(r'(\d+)\s*(day|days|month|months|hr|hrs|hour|hours|wk|wks|week|weeks|year|years)').firstMatch(validityText);
             if (match != null) {
               final val = int.tryParse(match.group(1) ?? '0') ?? 0;
               final unit = match.group(2) ?? '';
               if (unit.contains('day')) {
                 validityDate = val;
               } else if (unit.contains('week') || unit.contains('wk')) {
                 validityDate = val * 7;
               } else if (unit.contains('month')) {
                 validityDate = val * 30;
               } else if (unit.contains('year')) {
                 validityDate = val * 365;
               } else if (unit.contains('hr') || unit.contains('hour')) {
                 validityDate = 1;
               }
             } else {
               if (validityText.contains('day') || validityText.contains('hr') || validityText.contains('hour')) validityDate = 1;
               if (validityText.contains('week') || validityText.contains('wk')) validityDate = 7;
               if (validityText.contains('month')) validityDate = 30;
               if (validityText.contains('year')) validityDate = 365;
             }
          }
          
          switch (filterCategory) {
            case 'Daily':
              return validityDate >= 1 && validityDate <= 3 || name.contains('daily') || name.contains('1 day') || name.contains('2 day');
            case 'Weekly':
              return validityDate >= 4 && validityDate <= 13 || name.contains('weekly') || name.contains('7 day') || name.contains('14 day') || validityText.contains('week');
            case 'Monthly':
              return validityDate >= 14 && validityDate < 360 || name.contains('monthly') || name.contains('30 day') || validityText.contains('month');
            case 'Yearly':
              return validityDate >= 360 || name.contains('year') || validityText.contains('year');
            case 'XtraValue':
              final note = bundle.extInfo?.validityAttachNote?.toLowerCase() ?? '';
              final desc = bundle.extInfo?.itemDescription?.toLowerCase() ?? '';
              return name.contains('xtra') || name.contains('extra') || name.contains('talk') || name.contains('voice') ||
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
                     validityText.contains('social') ||
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
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
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

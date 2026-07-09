import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/giftcard.dart';
import 'package:valarpay/features/repositories/giftcard_repository.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

class GiftCardNotifier extends StateNotifier<DataState<GiftCardProduct>> {
  final GiftCardRepository _repository;

  GiftCardNotifier(this._repository)
    : super(DataState<GiftCardProduct>.initial());

  Future<void> getCategories() async {
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
    try {
      await _repository.getCategories();
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: 'Categories loaded successfully',
      );
    } catch (e, stack) {
      log('[GiftCardNotifier Categories Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load categories: ${e.toString()}',
      );
    }
  }

  Future<void> getProducts({required String currency}) async {
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
    try {
      final response = await _repository.getProducts(currency: currency);
      state = state.copyWith(
        isInitialLoading: false,
        data: response.data,
        isDataAvailable: true,
        message: response.message,
      );
    } catch (e, stack) {
      log('[GiftCardNotifier Products Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load products: ${e.toString()}',
      );
    }
  }

  Future<void> payForGiftCard(GiftCardPaymentRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      await _repository.payForGiftCard(request);
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: 'Payment successful',
      );
    } catch (e, stack) {
      log('[GiftCardNotifier Payment Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Payment failed: ${e.toString()}',
      );
    }
  }

  Future<GiftCardFxRateResponse?> getFxRate({
    required String currency,
    required double amount,
  }) async {
    try {
      return await _repository.getFxRate(currency: currency, amount: amount);
    } catch (e, stack) {
      log('[GiftCardNotifier FX Rate Error] $e\n$stack');
      state = state.copyWith(message: 'Failed to get FX rate: ${e.toString()}');
      return null;
    }
  }

  Future<GiftCardRedeemCodeResponse?> getRedeemCode({
    required String transactionId,
  }) async {
    try {
      return await _repository.getRedeemCode(transactionId: transactionId);
    } catch (e, stack) {
      log('[GiftCardNotifier Redeem Code Error] $e\n$stack');
      state = state.copyWith(
        message: 'Failed to get redeem code: ${e.toString()}',
      );
      return null;
    }
  }

  Future<String?> checkGiftCardStatus(String billRef) async {
    try {
      final res = await _repository.checkGiftCardStatus(billRef);
      return res['status'];
    } catch (e, stack) {
      log('[GiftCardNotifier checkGiftCardStatus] $e\n$stack');
      rethrow;
    }
  }

  void reset() => state = DataState<GiftCardProduct>.initial();
}

// Categories Notifier
class GiftCardCategoriesNotifier
    extends StateNotifier<DataState<GiftCardCategory>> {
  final GiftCardRepository _repository;

  GiftCardCategoriesNotifier(this._repository)
    : super(DataState<GiftCardCategory>.initial());

  Future<void> getCategories() async {
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
    try {
      final categories = await _repository.getCategories();
      state = state.copyWith(
        isInitialLoading: false,
        data: categories,
        isDataAvailable: true,
        message: 'Categories loaded successfully',
      );
    } catch (e, stack) {
      log('[GiftCardCategoriesNotifier Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load categories: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<GiftCardCategory>.initial();
}

// Providers
final giftCardRepositoryProvider = Provider(
  (ref) => GiftCardRepository(ref.read(apiClientProvider)),
);

final giftCardNotifierProvider =
    StateNotifierProvider<GiftCardNotifier, DataState<GiftCardProduct>>(
      (ref) => GiftCardNotifier(ref.read(giftCardRepositoryProvider)),
    );

final giftCardCategoriesNotifierProvider = StateNotifierProvider<
  GiftCardCategoriesNotifier,
  DataState<GiftCardCategory>
>((ref) => GiftCardCategoriesNotifier(ref.read(giftCardRepositoryProvider)));

// UI State Providers
final giftCardSelectedProductProvider = StateProvider<GiftCardProduct?>(
  (ref) => null,
);
final giftCardSelectedBrandProvider = StateProvider<String>(
  (ref) => 'Select Brand',
);
final giftCardSelectedCountryProvider = StateProvider<String>(
  (ref) => 'Select Country',
);
final giftCardSelectedAmountProvider = StateProvider<String>(
  (ref) => 'Select Amount',
);
final giftCardSelectedAmountValueProvider = StateProvider<double?>(
  (ref) => null,
);

class GiftcardBeneficiaryNotifier
    extends StateNotifier<DataState<GiftcardBeneficiary>> {
  final GiftCardRepository _repository;

  GiftcardBeneficiaryNotifier(this._repository)
    : super(DataState<GiftcardBeneficiary>.initial());

  Future<void> getGiftcardBeneficiaries() async {
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
    try {
      final res = await _repository.getGiftcardBeneficiaries();
      state = state.copyWith(
        isInitialLoading: false,
        data: res.data,
        isDataAvailable: true,
        message: res.message,
      );
      log(
        '[GiftcardBeneficiaryNotifier] Loaded ${res.data.length} beneficiaries',
      );
    } catch (e, stack) {
      log(
        '[GiftcardBeneficiaryNotifier getGiftcardBeneficiaries Error] $e\n$stack',
      );
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load beneficiaries: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<GiftcardBeneficiary>.initial();
}

final giftcardBeneficiaryNotifierProvider = StateNotifierProvider<
  GiftcardBeneficiaryNotifier,
  DataState<GiftcardBeneficiary>
>((ref) => GiftcardBeneficiaryNotifier(ref.read(giftCardRepositoryProvider)));

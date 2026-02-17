import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/currency_conversion_model.dart';
import 'package:valarpay/features/repositories/wallet_repository.dart';
import 'package:valarpay/features/notifiers/wallet_notifier.dart';

class CurrencyNotifier extends StateNotifier<DataState<CurrencyConversionData>> {
  final WalletRepository _repository;

  CurrencyNotifier(this._repository) : super(DataState<CurrencyConversionData>.initial());

  Future<void> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      print('[CurrencyNotifier] Converting $amount $fromCurrency to $toCurrency');
      final res = await _repository.convertCurrency(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
      
      print('[CurrencyNotifier] Raw API Response: $res');
      final convResponse = CurrencyConversionResponse.fromJson(res);
      print('[CurrencyNotifier] Parsed Data: ${convResponse.data}');

      if (convResponse.data != null) {
        state = state.copyWith(
          isInitialLoading: false,
          isDataAvailable: true,
          singleData: convResponse.data,
          message: convResponse.message,
        );
      } else {
        print('[CurrencyNotifier] No data found in response');
        state = state.copyWith(
          isInitialLoading: false,
          isDataAvailable: false,
          message: convResponse.errors?.join(', ') ?? convResponse.message ?? 'Conversion failed',
        );
      }
    } catch (e) {
      print('[CurrencyNotifier] Conversion Error: $e');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
    }
  }

  void reset() => state = DataState<CurrencyConversionData>.initial();
}

final currencyNotifierProvider = StateNotifierProvider<CurrencyNotifier, DataState<CurrencyConversionData>>((ref) {
  final repo = ref.read(walletRepositoryProvider);
  return CurrencyNotifier(repo);
});

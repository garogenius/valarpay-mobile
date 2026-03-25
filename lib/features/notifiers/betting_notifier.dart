import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/betting_models.dart';
import 'package:valarpay/features/repositories/betting_repository.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/models/beneficiary_models.dart';
import 'package:valarpay/features/repositories/beneficiary_repository.dart';
import 'package:valarpay/features/notifiers/beneficiary_notifier.dart';

class BettingPlatformsNotifier
    extends StateNotifier<DataState<BettingPlatformModel>> {
  final BettingRepository _repository;

  BettingPlatformsNotifier(this._repository)
    : super(DataState<BettingPlatformModel>.initial());

  Future<void> fetchPlatforms() async {
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
    try {
      final res = await _repository.getBettingPlatforms();
      state = state.copyWith(
        data: res,
        isDataAvailable: true,
      );
    } catch (e, stack) {
      log('[BettingPlatformsNotifier fetchPlatforms] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: 'Failed to load platforms: ${e.toString()}',
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  void reset() => state = DataState<BettingPlatformModel>.initial();
}

class BettingPayNotifier
    extends StateNotifier<DataState<BettingPayResponse>> {
  final BettingRepository _repository;

  BettingPayNotifier(this._repository)
    : super(DataState<BettingPayResponse>.initial());

  Future<void> payBetting(BettingPayRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.payBetting(request);
      state = state.copyWith(
        data: [res],
        isDataAvailable: true,
        message: 'Funding successful',
      );
    } catch (e, stack) {
      log('[BettingPayNotifier payBetting] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: e.toString().contains('Exception:') ? e.toString().split('Exception:')[1].trim() : e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  void reset() => state = DataState<BettingPayResponse>.initial();
}

final bettingPlatformsNotifierProvider = StateNotifierProvider<
  BettingPlatformsNotifier,
  DataState<BettingPlatformModel>
>((ref) => BettingPlatformsNotifier(ref.read(bettingRepositoryProvider)));

final bettingPayNotifierProvider = StateNotifierProvider<
  BettingPayNotifier,
  DataState<BettingPayResponse>
>((ref) => BettingPayNotifier(ref.read(bettingRepositoryProvider)));

// If we need beneficiaries specifically for betting
final bettingBeneficiaryNotifierProvider = StateNotifierProvider<
  BettingBeneficiaryNotifier,
  DataState<Beneficiary>
>((ref) {
  final repository = ref.read(beneficiaryRepositoryProvider);
  return BettingBeneficiaryNotifier(repository, ref);
});

class BettingBeneficiaryNotifier extends StateNotifier<DataState<Beneficiary>> {
  final BeneficiaryRepository _repository;
  final Ref _ref;

  BettingBeneficiaryNotifier(this._repository, this._ref)
    : super(DataState<Beneficiary>.initial());

  Future<void> fetchBeneficiaries() async {
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
    try {
      final response = await _repository.getBeneficiaries(
        category: 'BILL',
        billType: 'BETTING', // Assuming BETTING is the type
      );

      state = state.copyWith(
        isInitialLoading: false,
        data: response.data,
        isDataAvailable: response.data.isNotEmpty,
        message: response.message,
      );
    } catch (e, stack) {
      log('[BettingBeneficiaryNotifier fetchBeneficiaries Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to get betting beneficiaries: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<Beneficiary>.initial();
}

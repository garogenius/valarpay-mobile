import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/vcard_models.dart';
import 'package:valarpay/features/repositories/card_repository.dart';

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepository(ref.read(apiClientProvider));
});

class CardState {
  final List<VirtualCardModel>? cards;
  final bool isLoading;
  final bool isInitialLoading;
  final String? error;

  CardState({
    this.cards,
    this.isLoading = false,
    this.isInitialLoading = false,
    this.error,
  });

  CardState copyWith({
    List<VirtualCardModel>? cards,
    bool? isLoading,
    bool? isInitialLoading,
    String? error,
  }) {
    return CardState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      error: error ?? this.error,
    );
  }

  bool get isDataAvailable => cards != null && cards!.isNotEmpty;
}

class CardNotifier extends StateNotifier<CardState> {
  final CardRepository _repository;

  CardNotifier(this._repository) : super(CardState(isInitialLoading: true)) {
    fetchCards();
  }

  Future<void> fetchCards({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isInitialLoading: true, error: null);
    }
    
    final result = await _repository.getCards();
    if (result is DataSuccess) {
      state = state.copyWith(cards: result.data, isLoading: false, isInitialLoading: false);
    } else {
      state = state.copyWith(isLoading: false, isInitialLoading: false, error: result.error);
    }
  }

  Future<bool> createCard(CreateCardRequest request) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.createCard(request);
    state = state.copyWith(isLoading: false);
    if (result is DataSuccess) {
      await fetchCards(refresh: true);
      return true;
    }
    state = state.copyWith(error: result.error);
    return false;
  }

  Future<bool> fundCard(FundCardRequest request) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.fundCard(request);
    state = state.copyWith(isLoading: false);
    if (result is DataSuccess) {
      await fetchCards(refresh: true);
      return true;
    }
    state = state.copyWith(error: result.error);
    return false;
  }

  Future<bool> freezeCard(String cardId, bool freeze) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.freezeCard(cardId, freeze);
    state = state.copyWith(isLoading: false);
    if (result is DataSuccess) {
      await fetchCards(refresh: true);
      return true;
    }
    state = state.copyWith(error: result.error);
    return false;
  }

  Future<bool> blockCard(String cardId, String pin, String reason) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.blockCard(cardId, pin, reason);
    state = state.copyWith(isLoading: false);
    if (result is DataSuccess) {
      await fetchCards(refresh: true);
      return true;
    }
    state = state.copyWith(error: result.error);
    return false;
  }

  Future<bool> closeCard(String cardId, String pin) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.closeCard(cardId, pin);
    state = state.copyWith(isLoading: false);
    if (result is DataSuccess) {
      await fetchCards(refresh: true);
      return true;
    }
    state = state.copyWith(error: result.error);
    return false;
  }

  Future<bool> withdrawFromCard(String cardId, double amount, String pin) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.withdrawFromCard(cardId, amount, pin);
    state = state.copyWith(isLoading: false);
    if (result is DataSuccess) {
      await fetchCards(refresh: true);
      return true;
    }
    state = state.copyWith(error: result.error);
    return false;
  }

  Future<bool> setLimits(String cardId, double daily, double monthly, double tx, String pin) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.setCardLimits(cardId, daily, monthly, tx, pin);
    state = state.copyWith(isLoading: false);
    if (result is DataSuccess) {
      await fetchCards(refresh: true);
      return true;
    }
    state = state.copyWith(error: result.error);
    return false;
  }
}

final cardNotifierProvider = StateNotifierProvider<CardNotifier, CardState>((ref) {
  return CardNotifier(ref.read(cardRepositoryProvider));
});

final cardTransactionsProvider = FutureProvider.family<List<CardTransactionModel>, String>((ref, cardId) async {
  final repository = ref.read(cardRepositoryProvider);
  final result = await repository.getCardTransactions(cardId);
  if (result is DataSuccess) {
    return result.data ?? <CardTransactionModel>[];
  }
  return <CardTransactionModel>[];
});

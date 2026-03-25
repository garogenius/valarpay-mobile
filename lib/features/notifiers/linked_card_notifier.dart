import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/linked_card_models.dart';
import 'package:valarpay/features/repositories/linked_card_repository.dart';

final linkedCardRepositoryProvider = Provider((ref) => LinkedCardRepository(ref.read(apiClientProvider)));

final linkedCardsProvider = StateNotifierProvider<LinkedCardsNotifier, DataState<LinkedCard>>((ref) {
  return LinkedCardsNotifier(ref.read(linkedCardRepositoryProvider));
});

class LinkedCardsNotifier extends StateNotifier<DataState<LinkedCard>> {
  final LinkedCardRepository _repository;

  LinkedCardsNotifier(this._repository) : super(DataState.initial());

  Future<void> fetchLinkedCards() async {
    state = state.copyWith(isInitialLoading: true);
    final response = await _repository.getLinkedCards();
    state = response;
  }
}

final cardLinkProvider = StateNotifierProvider<CardLinkNotifier, DataState<CardLinkInitiateResponse>>((ref) {
  return CardLinkNotifier(ref.read(linkedCardRepositoryProvider));
});

class CardLinkNotifier extends StateNotifier<DataState<CardLinkInitiateResponse>> {
  final LinkedCardRepository _repository;

  CardLinkNotifier(this._repository) : super(DataState.initial());

  Future<CardLinkInitiateResponse?> initiate(CardLinkInitiateRequest request) async {
    state = state.copyWith(isInitialLoading: true);
    final response = await _repository.initiateCardLink(request);
    state = response;

    if (response is DataSuccess<CardLinkInitiateResponse>) {
      return response.singleData;
    }
    return null;
  }
}

final cardChargeProvider = StateNotifierProvider<CardChargeNotifier, DataState<ChargeCardResponse>>((ref) {
  return CardChargeNotifier(ref.read(linkedCardRepositoryProvider));
});

class CardChargeNotifier extends StateNotifier<DataState<ChargeCardResponse>> {
  final LinkedCardRepository _repository;

  CardChargeNotifier(this._repository) : super(DataState.initial());

  Future<ChargeCardResponse?> charge(String cardId, ChargeCardRequest request) async {
    state = state.copyWith(isInitialLoading: true);
    final response = await _repository.chargeCard(cardId, request);
    state = response;

    if (response is DataSuccess<ChargeCardResponse>) {
      return response.singleData;
    }
    return null;
  }
}

final cardDisableProvider = StateNotifierProvider<CardDisableNotifier, DataState<bool>>((ref) {
  return CardDisableNotifier(ref.read(linkedCardRepositoryProvider));
});

class CardDisableNotifier extends StateNotifier<DataState<bool>> {
  final LinkedCardRepository _repository;

  CardDisableNotifier(this._repository) : super(DataState.initial());

  Future<bool> disable(String cardId) async {
    state = state.copyWith(isInitialLoading: true);
    final response = await _repository.disableCard(cardId);
    state = response;
    
    return response.isDataAvailable;
  }
}

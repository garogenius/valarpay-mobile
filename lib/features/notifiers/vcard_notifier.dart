import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/vcard_models.dart';
import 'package:valarpay/features/repositories/card_repository.dart';
import 'package:valarpay/features/providers/user_provider.dart';

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
  final Ref _ref;

  CardNotifier(this._repository, this._ref) : super(CardState(isInitialLoading: true)) {
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

  Future<bool> createCard(CreateCardRequest legacyRequest) async {
    state = state.copyWith(isLoading: true);
    
    final user = _ref.read(userProvider);
    if (user == null) {
      state = state.copyWith(isLoading: false, error: 'User session not found');
      return false;
    }

    final usdWallet = user.wallets.firstWhere(
      (w) => w.currency == 'USD',
      orElse: () => user.wallets.isNotEmpty ? user.wallets.first : throw Exception('No wallet found'),
    );

    final nameParts = user.fullname.split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Doe';

    String formattedPhone = '+234801234567';
    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
      String cleaned = user.phoneNumber!.replaceAll(RegExp(r'\D'), '');
      if (cleaned.startsWith('0')) {
        cleaned = cleaned.substring(1);
      }
      if (cleaned.startsWith('234')) {
        formattedPhone = '+$cleaned';
      } else {
        formattedPhone = '+234$cleaned';
      }
    }

    String hexColor = '#0D1D2A';
    switch (legacyRequest.color) {
      case 'Quantum Grid': hexColor = '#F76301'; break;
      case 'Titanium Edge': hexColor = '#273644'; break;
      case 'Ethereal Flow': hexColor = '#010816'; break;
      case 'Solar Velocity': hexColor = '#A33F00'; break;
      case 'Prism Digital': hexColor = '#1C2B39'; break;
      case 'Midnight Executive':
      default: hexColor = '#0D1D2A'; break;
    }

    final request = EversendCreateCardRequest(
      walletId: usdWallet.id,
      userData: EversendUserData(
        firstName: firstName.isNotEmpty ? firstName : 'John',
        lastName: lastName.isNotEmpty ? lastName : 'Doe',
        email: user.email.isNotEmpty ? user.email : 'john.doe@example.com',
        phone: formattedPhone,
        country: (user.country != null && user.country!.isNotEmpty) ? user.country! : 'NG',
        state: (user.state != null && user.state!.isNotEmpty) ? user.state! : 'Anambra State',
        city: (user.city != null && user.city!.isNotEmpty) ? user.city! : 'Oyi',
        address: (user.address != null && user.address!.isNotEmpty) ? user.address! : '123 Main Street',
        zipCode: (user.postalCode != null && user.postalCode!.isNotEmpty) ? user.postalCode! : '100001',
        idType: 'NATIONAL_ID', // Default to NATIONAL_ID as per example
        idNumber: (user.nin != null && user.nin!.isNotEmpty) ? user.nin! : '1234567890',
      ),
      cardData: EversendCardData(
        userId: user.id,
        title: legacyRequest.label,
        amount: legacyRequest.fundingAmount.toStringAsFixed(2),
        currency: 'USD',
        brand: 'VISA',
        color: hexColor,
        isNonSubscription: false,
      ),
    );

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

  Future<bool> withdrawFromCard(String cardId, double amount) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.withdrawFromCard(cardId, amount);
    state = state.copyWith(isLoading: false);
    if (result is DataSuccess) {
      await fetchCards(refresh: true);
      return true;
    }
    state = state.copyWith(error: result.error);
    return false;
  }

  Future<bool> freezeCard(String cardId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.freezeCard(cardId);
    state = state.copyWith(isLoading: false);
    if (result is DataSuccess) {
      await fetchCards(refresh: true);
      return true;
    }
    state = state.copyWith(error: result.error);
    return false;
  }

  Future<bool> unfreezeCard(String cardId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.unfreezeCard(cardId);
    state = state.copyWith(isLoading: false);
    if (result is DataSuccess) {
      await fetchCards(refresh: true);
      return true;
    }
    state = state.copyWith(error: result.error);
    return false;
  }

  Future<bool> terminateCard(String cardId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.terminateCard(cardId);
    state = state.copyWith(isLoading: false);
    if (result is DataSuccess) {
      await fetchCards(refresh: true);
      return true;
    }
    state = state.copyWith(error: result.error);
    return false;
  }

  // Deprecated methods for backward compatibility if needed, but updated to use terminate
  Future<bool> blockCard(String cardId, String pin, String reason) => terminateCard(cardId);
  Future<bool> closeCard(String cardId, String pin) => terminateCard(cardId);
}

final cardNotifierProvider = StateNotifierProvider<CardNotifier, CardState>((ref) {
  return CardNotifier(ref.read(cardRepositoryProvider), ref);
});

final cardTransactionsProvider = FutureProvider.family<List<CardTransactionModel>, String>((ref, cardId) async {
  final repository = ref.read(cardRepositoryProvider);
  final result = await repository.getCardTransactions(cardId);
  if (result is DataSuccess) {
    return result.data ?? <CardTransactionModel>[];
  }
  return <CardTransactionModel>[];
});

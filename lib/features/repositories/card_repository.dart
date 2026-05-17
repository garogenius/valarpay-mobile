import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/vcard_models.dart';

class CardRepository {
  final ApiClient _apiClient;

  CardRepository(this._apiClient);

  Future<DataState<VirtualCardModel>> createCard(EversendCreateCardRequest request) async {
    return _apiClient.postData<VirtualCardModel>(
      '/api/v1/currency/eversend/cards',
      data: request.toJson(),
      converter: (json) => VirtualCardModel.fromJson(json),
    );
  }

  Future<DataState<VirtualCardModel>> getCards() async {
    return _apiClient.getData<VirtualCardModel>(
      '/api/v1/currency/eversend/cards',
      converter: (json) {
        final List cards = json['data'] is List ? json['data'] : (json['data']?['cards'] ?? []);
        return cards.map((c) => VirtualCardModel.fromJson(c)).toList();
      },
    );
  }

  Future<DataState<VirtualCardModel>> getCardsByWallet(String walletId) async {
    return _apiClient.getData<VirtualCardModel>(
      '/api/v1/currency/eversend/wallets/$walletId/cards',
      converter: (json) {
        final List cards = json['data'] is List ? json['data'] : (json['data']?['cards'] ?? []);
        return cards.map((c) => VirtualCardModel.fromJson(c)).toList();
      },
    );
  }

  Future<DataState<VirtualCardModel>> getCardDetails(String cardId) async {
    return _apiClient.getData<VirtualCardModel>(
      '/api/v1/currency/eversend/cards/$cardId',
      converter: (json) => VirtualCardModel.fromJson(json['data'] ?? json),
    );
  }

  Future<DataState<bool>> fundCard(FundCardRequest request) async {
    return _apiClient.postData<bool>(
      '/api/v1/currency/eversend/cards/${request.cardId}/fund',
      data: {'amount': request.amount},
      converter: (json) => true,
    );
  }

  Future<DataState<bool>> withdrawFromCard(String cardId, double amount) async {
    return _apiClient.postData<bool>(
      '/api/v1/currency/eversend/cards/$cardId/withdraw',
      data: {'amount': amount},
      converter: (json) => true,
    );
  }

  Future<DataState<bool>> freezeCard(String cardId) async {
    return _apiClient.postData<bool>(
      '/api/v1/currency/eversend/cards/$cardId/freeze',
      converter: (json) => true,
    );
  }

  Future<DataState<bool>> unfreezeCard(String cardId) async {
    return _apiClient.postData<bool>(
      '/api/v1/currency/eversend/cards/$cardId/unfreeze',
      converter: (json) => true,
    );
  }

  Future<DataState<bool>> terminateCard(String cardId) async {
    return _apiClient.postData<bool>(
      '/api/v1/currency/eversend/cards/$cardId/terminate',
      converter: (json) => true,
    );
  }

  Future<DataState<CardTransactionModel>> getCardTransactions(String cardId, {int limit = 50, int offset = 0}) async {
    return _apiClient.getData<CardTransactionModel>(
      '/api/v1/currency/eversend/cards/$cardId/transactions',
      queryParameters: {'limit': limit, 'offset': offset},
      converter: (json) {
        final List txs = json['data']?['transactions'] ?? json['transactions'] ?? [];
        return txs.map((t) => CardTransactionModel.fromJson(t)).toList();
      },
    );
  }
}

import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/vcard_models.dart';

class CardRepository {
  final ApiClient _apiClient;

  CardRepository(this._apiClient);

  Future<DataState<VirtualCardModel>> createCard(CreateCardRequest request) async {
    return _apiClient.postData<VirtualCardModel>(
      '/api/v1/currency/cards',
      data: request.toJson(),
      converter: (json) => VirtualCardModel.fromJson(json),
    );
  }

  Future<DataState<VirtualCardModel>> getCards() async {
    return _apiClient.getData<VirtualCardModel>(
      '/api/v1/currency/cards',
      converter: (json) {
        final List cards = json['data']['cards'];
        return cards.map((c) => VirtualCardModel.fromJson(c)).toList();
      },
    );
  }

  Future<DataState<VirtualCardModel>> getCardDetails(String cardId) async {
    return _apiClient.getData<VirtualCardModel>(
      '/api/v1/currency/cards/$cardId',
      converter: (json) => VirtualCardModel.fromJson(json['data']),
    );
  }

  Future<DataState<bool>> updateCard(String cardId, String label) async {
    return _apiClient.patchData<bool>(
      '/api/v1/currency/cards/$cardId',
      data: {'label': label},
      converter: (json) => true,
    );
  }

  Future<DataState<bool>> fundCard(FundCardRequest request) async {
    return _apiClient.postData<bool>(
      '/api/v1/currency/cards/${request.cardId}/fund',
      data: request.toJson(),
      converter: (json) => true,
    );
  }

  Future<DataState<bool>> freezeCard(String cardId, bool freeze) async {
    return _apiClient.patchData<bool>(
      '/api/v1/currency/cards/$cardId/freeze',
      queryParameters: {'freeze': freeze},
      converter: (json) => true,
    );
  }

  Future<DataState<bool>> blockCard(String cardId, String walletPin, String reason) async {
    return _apiClient.postData<bool>(
      '/api/v1/currency/cards/$cardId/block',
      data: {'walletPin': walletPin, 'reason': reason},
      converter: (json) => true,
    );
  }

  Future<DataState<bool>> closeCard(String cardId, String walletPin) async {
    return _apiClient.postData<bool>(
      '/api/v1/currency/cards/$cardId/close',
      data: {'walletPin': walletPin},
      converter: (json) => true,
    );
  }

  Future<DataState<CardTransactionModel>> getCardTransactions(String cardId, {int limit = 50, int offset = 0}) async {
    return _apiClient.getData<CardTransactionModel>(
      '/api/v1/currency/cards/$cardId/transactions',
      queryParameters: {'limit': limit, 'offset': offset},
      converter: (json) {
        final List txs = json['transactions'];
        return txs.map((t) => CardTransactionModel.fromJson(t)).toList();
      },
    );
  }

  Future<DataState<bool>> setCardLimits(String cardId, double daily, double monthly, double txLimit, String pin) async {
    return _apiClient.putData<bool>(
      '/api/v1/currency/cards/$cardId/limits',
      data: {
        'dailyLimit': daily,
        'monthlyLimit': monthly,
        'transactionLimit': txLimit,
        'walletPin': pin,
      },
      converter: (json) => true,
    );
  }

  Future<DataState<bool>> withdrawFromCard(String cardId, double amount, String pin) async {
    return _apiClient.postData<bool>(
      '/api/v1/currency/cards/$cardId/withdraw',
      data: {'amount': amount, 'walletPin': pin},
      converter: (json) => true,
    );
  }
}

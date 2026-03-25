import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/features/models/linked_card_models.dart';

class LinkedCardRepository {
  final ApiClient _apiClient;

  LinkedCardRepository(this._apiClient);

  Future<DataState<CardProviders>> getCardLinkProviders() async {
    return _apiClient.getData<CardProviders>(
      ApiEndpoints.getCardLinkProviders,
      converter: (json) => CardProviders.fromJson(json['data'] ?? json),
    );
  }

  Future<DataState<CardLinkInitiateResponse>> initiateCardLink(CardLinkInitiateRequest request) async {
    return _apiClient.postData<CardLinkInitiateResponse>(
      ApiEndpoints.initiateCardLink,
      data: request.toJson(),
      converter: (json) => CardLinkInitiateResponse.fromJson(json['data'] ?? json),
    );
  }

  Future<DataState<LinkedCard>> getLinkedCards() async {
    return _apiClient.getData<LinkedCard>(
      ApiEndpoints.getLinkedCards,
      converter: (json) {
        final dynamic data = json['data'] ?? json;
        List cards = [];
        if (data is List) {
          cards = data;
        } else if (data is Map) {
          cards = data['cards'] ?? data['data'] ?? [];
        }
        return cards.map((c) => LinkedCard.fromJson(c)).toList();
      },
    );
  }

  Future<DataState<ChargeCardResponse>> chargeCard(String cardId, ChargeCardRequest request) async {
    return _apiClient.postData<ChargeCardResponse>(
      ApiEndpoints.chargeLinkedCard(cardId),
      data: request.toJson(),
      converter: (json) => ChargeCardResponse.fromJson(json['data'] ?? json),
    );
  }

  Future<DataState<bool>> disableCard(String cardId) async {
    return _apiClient.postData<bool>(
      ApiEndpoints.disableLinkedCard(cardId),
      converter: (json) => true,
    );
  }
}

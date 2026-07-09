class UserTierResponse {
  final int statusCode;
  final UserTierData data;

  UserTierResponse({
    required this.statusCode,
    required this.data,
  });

  factory UserTierResponse.fromJson(Map<String, dynamic> json) {
    return UserTierResponse(
      statusCode: json['statusCode'] ?? 200,
      data: UserTierData.fromJson(json['data']),
    );
  }
}

class UserTierData {
  final String currentTier;
  final TierInfo? tier;
  final List<TierInfo> tiers;

  UserTierData({
    required this.currentTier,
    this.tier,
    required this.tiers,
  });

  factory UserTierData.fromJson(Map<String, dynamic> json) {
    return UserTierData(
      currentTier: json['currentTier'] ?? 'one',
      tier: json['tier'] != null ? TierInfo.fromJson(json['tier']) : null,
      tiers: (json['tiers'] as List?)
              ?.map((t) => TierInfo.fromJson(t))
              .toList() ??
          [],
    );
  }
}

class TierInfo {
  final String tier;
  final num? dailyTransactionLimit;
  final num? balanceLimit;
  final List<String> requirements;

  TierInfo({
    required this.tier,
    this.dailyTransactionLimit,
    this.balanceLimit,
    required this.requirements,
  });

  factory TierInfo.fromJson(Map<String, dynamic> json) {
    List<String> parsedRequirements = [];
    if (json['requirements'] is List) {
      parsedRequirements = List<String>.from(json['requirements']);
    } else if (json['requirements'] is Map) {
      (json['requirements'] as Map).forEach((key, value) {
        if (value == true) parsedRequirements.add(key.toString());
      });
    }

    return TierInfo(
      tier: json['tier'] ?? '',
      dailyTransactionLimit: json['dailyTransactionLimit'],
      balanceLimit: json['balanceLimit'] ?? json['cumulativeBalanceLimit'],
      requirements: parsedRequirements,
    );
  }
}

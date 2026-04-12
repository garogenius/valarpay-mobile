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
  final num dailyTransactionLimit;
  final num balanceLimit;
  final List<TierInfo> tiers;

  UserTierData({
    required this.currentTier,
    required this.dailyTransactionLimit,
    required this.balanceLimit,
    required this.tiers,
  });

  factory UserTierData.fromJson(Map<String, dynamic> json) {
    return UserTierData(
      currentTier: json['currentTier'] ?? 'one',
      dailyTransactionLimit: json['dailyTransactionLimit'] ?? 0,
      balanceLimit: json['balanceLimit'] ?? 0,
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
    return TierInfo(
      tier: json['tier'] ?? '',
      dailyTransactionLimit: json['dailyTransactionLimit'],
      balanceLimit: json['balanceLimit'],
      requirements: List<String>.from(json['requirements'] ?? []),
    );
  }
}

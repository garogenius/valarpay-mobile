class EasyLifeProduct {
  final String name;
  final String description;
  final double interestRatePerAnnum;
  final double earlyWithdrawalPenaltyRate;
  final int minDurationDays;
  final double minInitialDeposit;
  final bool allowEarlyWithdrawal;
  final bool supportsContributionFrequency;
  final List<String> contributionFrequencies;

  EasyLifeProduct({
    required this.name,
    required this.description,
    required this.interestRatePerAnnum,
    required this.earlyWithdrawalPenaltyRate,
    required this.minDurationDays,
    required this.minInitialDeposit,
    required this.allowEarlyWithdrawal,
    required this.supportsContributionFrequency,
    required this.contributionFrequencies,
  });

  factory EasyLifeProduct.fromJson(Map<String, dynamic> json) {
    return EasyLifeProduct(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      interestRatePerAnnum: (json['interestRatePerAnnum'] ?? 0).toDouble(),
      earlyWithdrawalPenaltyRate: (json['earlyWithdrawalPenaltyRate'] ?? 0).toDouble(),
      minDurationDays: json['minDurationDays'] ?? 0,
      minInitialDeposit: (json['minInitialDeposit'] ?? 0).toDouble(),
      allowEarlyWithdrawal: json['allowEarlyWithdrawal'] ?? false,
      supportsContributionFrequency: json['supportsContributionFrequency'] ?? false,
      contributionFrequencies: List<String>.from(json['contributionFrequencies'] ?? []),
    );
  }
}

class CreateEasyLifePlanRequest {
  final String name;
  final String description;
  final double goalAmount;
  final String currency;
  final int durationDays;
  final String contributionFrequency;
  final bool autoDebitEnabled;
  final bool earlyWithdrawalEnabled;

  CreateEasyLifePlanRequest({
    required this.name,
    required this.description,
    required this.goalAmount,
    this.currency = 'NGN',
    required this.durationDays,
    required this.contributionFrequency,
    required this.autoDebitEnabled,
    this.earlyWithdrawalEnabled = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'goalAmount': goalAmount,
    'currency': currency,
    'durationDays': durationDays,
    'contributionFrequency': contributionFrequency,
    'autoDebitEnabled': autoDebitEnabled,
    'earlyWithdrawalEnabled': earlyWithdrawalEnabled,
  };
}

class EasyLifePlan {
  final String id;
  final String name;
  final double goalAmount;
  final double totalSaved;
  final int durationDays;
  final String contributionFrequency;
  final bool autoDebitEnabled;
  final String status;
  final DateTime createdAt;
  final List<EasyLifeFunding>? fundings;

  EasyLifePlan({
    required this.id,
    required this.name,
    required this.goalAmount,
    required this.totalSaved,
    required this.durationDays,
    required this.contributionFrequency,
    required this.autoDebitEnabled,
    required this.status,
    required this.createdAt,
    this.fundings,
  });

  factory EasyLifePlan.fromJson(Map<String, dynamic> json) {
    return EasyLifePlan(
      id: json['id'] ?? '',
      name: json['name'] ?? json['title'] ?? '',
      goalAmount: (json['goalAmount'] ?? json['targetAmount'] ?? 0).toDouble(),
      totalSaved: (json['totalSaved'] ?? 0).toDouble(),
      durationDays: json['durationDays'] ?? 0,
      contributionFrequency: json['contributionFrequency'] ?? 'DAILY',
      autoDebitEnabled: json['autoDebitEnabled'] ?? false,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      fundings: json['fundings'] != null 
          ? (json['fundings'] as List).map((i) => EasyLifeFunding.fromJson(i)).toList() 
          : null,
    );
  }
}

class EasyLifeFunding {
  final String id;
  final double amount;
  final DateTime createdAt;

  EasyLifeFunding({
    required this.id,
    required this.amount,
    required this.createdAt,
  });

  factory EasyLifeFunding.fromJson(Map<String, dynamic> json) {
    return EasyLifeFunding(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class FundEasyLifePlanRequest {
  final String planId;
  final double amount;
  final String currency;

  FundEasyLifePlanRequest({
    required this.planId,
    required this.amount,
    this.currency = 'NGN',
  });

  Map<String, dynamic> toJson() => {
    'planId': planId,
    'amount': amount,
    'currency': currency,
  };
}

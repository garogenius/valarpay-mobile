class SavingsProduct {
  final String id;
  final String name;
  final String description;
  final double interestRate;
  final double minAmount;
  final double maxAmount;

  SavingsProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.interestRate,
    required this.minAmount,
    required this.maxAmount,
  });

  factory SavingsProduct.fromJson(Map<String, dynamic> json) {
    return SavingsProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      interestRate: (json['interestRate'] ?? 0).toDouble(),
      minAmount: (json['minAmount'] ?? 0).toDouble(),
      maxAmount: (json['maxAmount'] ?? 0).toDouble(),
    );
  }
}

class SavingsPlan {
  final String id;
  final String type;
  final String name;
  final double goalAmount;
  final double currentAmount;
  final double interestRate;
  final int durationMonths;
  final String status;
  final DateTime createdAt;
  final DateTime? endDate;
  final List<SavingsFunding>? fundings;

  SavingsPlan({
    required this.id,
    required this.type,
    required this.name,
    required this.goalAmount,
    required this.currentAmount,
    required this.interestRate,
    required this.durationMonths,
    required this.status,
    required this.createdAt,
    this.endDate,
    this.fundings,
  });

  factory SavingsPlan.fromJson(Map<String, dynamic> json) {
    return SavingsPlan(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      goalAmount: (json['goalAmount'] ?? json['targetAmount'] ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0).toDouble(),
      interestRate: (json['interestRate'] ?? 0).toDouble(),
      durationMonths: json['durationMonths'] ?? 3,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      fundings: json['fundings'] != null 
          ? (json['fundings'] as List).map((i) => SavingsFunding.fromJson(i)).toList() 
          : null,
    );
  }
}

class SavingsFunding {
  final String id;
  final double amount;
  final DateTime createdAt;

  SavingsFunding({
    required this.id,
    required this.amount,
    required this.createdAt,
  });

  factory SavingsFunding.fromJson(Map<String, dynamic> json) {
    return SavingsFunding(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class CreateSavingsPlanRequest {
  final String type;
  final String name;
  final String description;
  final double goalAmount;
  final String currency;
  final int durationMonths;

  CreateSavingsPlanRequest({
    required this.type,
    required this.name,
    required this.description,
    required this.goalAmount,
    this.currency = 'NGN',
    required this.durationMonths,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'description': description,
    'goalAmount': goalAmount,
    'currency': currency,
    'durationMonths': durationMonths,
  };
}

class FundSavingsPlanRequest {
  final String planId;
  final double amount;
  final String currency;

  FundSavingsPlanRequest({
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

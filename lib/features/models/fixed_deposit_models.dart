class FixedDepositPlan {
  final String id;
  final String name;
  final String description;
  final double interestRate;
  final int durationMonths;
  final double minAmount;
  final double maxAmount;

  FixedDepositPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.interestRate,
    required this.durationMonths,
    required this.minAmount,
    required this.maxAmount,
  });

  factory FixedDepositPlan.fromJson(Map<String, dynamic> json) {
    return FixedDepositPlan(
      id: json['id'] ?? json['planType'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      interestRate: (json['interestRate'] ?? json['interestRatePerAnnum'] ?? 0).toDouble(),
      durationMonths: json['durationMonths'] ?? json['tenureMonths'] ?? 0,
      minAmount: (json['minAmount'] ?? json['minimumDeposit'] ?? 0).toDouble(),
      maxAmount: (json['maxAmount'] ?? json['maximumDeposit'] ?? 0).toDouble(),
    );
  }
}

class CreateFixedDepositRequest {
  final String planId;
  final double amount;
  final String currency;
  final String rolloverType; // NONE, PRINCIPAL, PRINCIPAL_AND_INTEREST

  CreateFixedDepositRequest({
    required this.planId,
    required this.amount,
    this.currency = 'NGN',
    required this.rolloverType,
  });

  Map<String, dynamic> toJson() => {
    'planId': planId,
    'amount': amount,
    'currency': currency,
    'rolloverType': rolloverType,
  };
}

class FixedDeposit {
  final String id;
  final String planId;
  final double amount;
  final double interestRate;
  final double expectedReturn;
  final String status;
  final DateTime startDate;
  final DateTime maturityDate;
  final String rolloverType;

  FixedDeposit({
    required this.id,
    required this.planId,
    required this.amount,
    required this.interestRate,
    required this.expectedReturn,
    required this.status,
    required this.startDate,
    required this.maturityDate,
    required this.rolloverType,
  });

  factory FixedDeposit.fromJson(Map<String, dynamic> json) {
    return FixedDeposit(
      id: json['id'] ?? '',
      planId: json['planId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      interestRate: (json['interestRate'] ?? json['interestRatePerAnnum'] ?? 0).toDouble(),
      expectedReturn: (json['expectedReturn'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      maturityDate: json['maturityDate'] != null ? DateTime.parse(json['maturityDate']) : DateTime.now(),
      rolloverType: json['rolloverType'] ?? 'NONE',
    );
  }
}

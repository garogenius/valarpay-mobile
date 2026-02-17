// Investment Product Model
class InvestmentProduct {
  final String name;
  final String description;
  final double minimumInvestmentAmount;
  final double roiRate;
  final int tenureMonths;
  final bool capitalGuaranteed;
  final String repaymentStructure;
  final List<String> features;

  InvestmentProduct({
    required this.name,
    required this.description,
    required this.minimumInvestmentAmount,
    required this.roiRate,
    required this.tenureMonths,
    required this.capitalGuaranteed,
    required this.repaymentStructure,
    required this.features,
  });

  factory InvestmentProduct.fromJson(Map<String, dynamic> json) {
    return InvestmentProduct(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      minimumInvestmentAmount: (json['minimumInvestmentAmount'] ?? 0).toDouble(),
      roiRate: (json['roiRate'] ?? 0).toDouble(),
      tenureMonths: json['tenureMonths'] ?? 0,
      capitalGuaranteed: json['capitalGuaranteed'] ?? false,
      repaymentStructure: json['repaymentStructure'] ?? '',
      features: List<String>.from(json['features'] ?? []),
    );
  }
}

// Investment Model
class Investment {
  final String id;
  final double amount;
  final double expectedReturn;
  final double roiRate;
  final int tenureMonths;
  final String status;
  final DateTime startDate;
  final DateTime maturityDate;
  final InvestmentTransaction? transaction;

  Investment({
    required this.id,
    required this.amount,
    required this.expectedReturn,
    required this.roiRate,
    required this.tenureMonths,
    required this.status,
    required this.startDate,
    required this.maturityDate,
    this.transaction,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      expectedReturn: (json['expectedReturn'] ?? 0).toDouble(),
      roiRate: (json['roiRate'] ?? 0).toDouble(),
      tenureMonths: json['tenureMonths'] ?? 0,
      status: json['status'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      maturityDate: json['maturityDate'] != null ? DateTime.parse(json['maturityDate']) : DateTime.now(),
      transaction: json['transaction'] != null ? InvestmentTransaction.fromJson(json['transaction']) : null,
    );
  }
}

// Investment Transaction Model
class InvestmentTransaction {
  final String id;
  final double amount;
  final String type;
  final String status;
  final DateTime createdAt;

  InvestmentTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  factory InvestmentTransaction.fromJson(Map<String, dynamic> json) {
    return InvestmentTransaction(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

// Create Investment Request
class CreateInvestmentRequest {
  final double amount;
  final String currency;
  final String agreementReference;
  final String legalDocumentUrl;

  CreateInvestmentRequest({
    required this.amount,
    this.currency = 'NGN',
    required this.agreementReference,
    required this.legalDocumentUrl,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'currency': currency,
    'agreementReference': agreementReference,
    'legalDocumentUrl': legalDocumentUrl,
  };
}

// Create Investment Response
class CreateInvestmentResponse {
  final Investment investment;
  final String transactionId;
  final double newWalletBalance;

  CreateInvestmentResponse({
    required this.investment,
    required this.transactionId,
    required this.newWalletBalance,
  });

  factory CreateInvestmentResponse.fromJson(Map<String, dynamic> json) {
    return CreateInvestmentResponse(
      investment: Investment.fromJson(json['investment']),
      transactionId: json['transactionId'] ?? '',
      newWalletBalance: (json['newWalletBalance'] ?? 0).toDouble(),
    );
  }
}

// Investment List Response Meta
class InvestmentListMeta {
  final int total;
  final int page;
  final int limit;

  InvestmentListMeta({
    required this.total,
    required this.page,
    required this.limit,
  });

  factory InvestmentListMeta.fromJson(Map<String, dynamic> json) {
    return InvestmentListMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
    );
  }
}

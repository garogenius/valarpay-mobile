class BillDetails {
  final String? billType;
  final String? provider;
  final String? accountNumber;
  final double? amount;
  final String? reference;
  final String? network;

  BillDetails({
    this.billType,
    this.provider,
    this.accountNumber,
    this.amount,
    this.reference,
    this.network,
  });

  factory BillDetails.fromJson(Map<String, dynamic> json) {
    return BillDetails(
      billType: json['billType'] ?? json['type'],
      provider: json['provider'],
      accountNumber: json['accountNumber'] ?? json['recipientPhone'],
      amount: json['amount']?.toDouble(),
      reference: json['reference'],
      network: json['network'],
    );
  }

  Map<String, dynamic> toJson() => {
    'billType': billType,
    'provider': provider,
    'accountNumber': accountNumber,
    'amount': amount,
    'reference': reference,
    'network': network,
  };
}

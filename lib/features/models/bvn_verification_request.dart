class BvnVerificationRequest {
  final String idType;
  final String idNumber;
  final String? selfieImage;
  final List<String>? livenessImages;

  BvnVerificationRequest({
    required this.idType,
    required this.idNumber,
    this.selfieImage,
    this.livenessImages,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'idType': idType,
      'idNumber': idNumber,
    };
    if (selfieImage != null) map['selfieImage'] = selfieImage!;
    if (livenessImages != null) map['livenessImages'] = livenessImages!;
    return map;
  }
}


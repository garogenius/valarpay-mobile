class NinVerificationRequest {
  final String nin;
  final String? docType;
  final String selfieImage;
  final List<String>? livenessImages;

  NinVerificationRequest({
    required this.nin,
    this.docType,
    required this.selfieImage,
    this.livenessImages,
  });

  factory NinVerificationRequest.fromJson(Map<String, dynamic> json) =>
      NinVerificationRequest(
        nin: json['nin'] ?? json['bvn'] ?? '',
        selfieImage: json['selfieImage'] ?? '',
        livenessImages: (json['livenessImages'] as List?)?.cast<String>(),
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    
    if (docType != null && docType!.toUpperCase() == 'BVN') {
      map['bvn'] = nin;
    } else {
      map['nin'] = nin;
    }
    
    // Only include selfieImage if it's not empty
    if (selfieImage.isNotEmpty) {
      map['selfieImage'] = selfieImage;
      map['selfie_image'] = selfieImage; // snake_case fallback
    }

    if (livenessImages != null && livenessImages!.isNotEmpty) {
      map['livenessImages'] = livenessImages;
      map['liveness_images'] = livenessImages; // snake_case fallback
    }
    
    return map;
  }
}

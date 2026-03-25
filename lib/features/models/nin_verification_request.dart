class NinVerificationRequest {
  final String nin;
  final String selfieImage;
  final List<String>? livenessImages;

  NinVerificationRequest({
    required this.nin,
    required this.selfieImage,
    this.livenessImages,
  });

  factory NinVerificationRequest.fromJson(Map<String, dynamic> json) =>
      NinVerificationRequest(
        nin: json['nin'] ?? '',
        selfieImage: json['selfieImage'] ?? '',
        livenessImages: (json['livenessImages'] as List?)?.cast<String>(),
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'nin': nin,
    };
    
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

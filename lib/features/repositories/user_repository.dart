import 'dart:io';
import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/features/models/api_response.dart';
import 'package:valarpay/features/models/email_request.dart';
import 'package:valarpay/features/models/forgot_password.dart';
import 'package:valarpay/features/models/login.dart';
import 'package:valarpay/features/models/phone_number_request.dart';
import 'package:valarpay/features/models/reset_password.dart';
import 'package:valarpay/features/models/set_wallet_pin_request.dart';
import 'package:valarpay/features/models/set_wallet_pin_response.dart';
import 'package:valarpay/features/models/signup_request.dart';
import 'package:valarpay/features/models/user.dart';
import 'package:valarpay/features/models/user_availablity_request.dart';
import 'package:valarpay/features/models/verify_email_request.dart';
import 'package:valarpay/features/models/verify_otp_request.dart';
import 'package:valarpay/features/models/verify_phone_number.dart';
import 'package:valarpay/features/models/verify_wallet_pin_request.dart';
import 'package:valarpay/features/models/verify_wallet_pin_response.dart';
import 'package:valarpay/features/models/nin_verification_request.dart';
import 'package:valarpay/features/models/nin_verification_response.dart';
import 'package:valarpay/features/models/user_tier.dart';
import '../../../core/network/api_client.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository(this.apiClient);

  Future<LoginResponse> register(SignUpRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    }
  }

  Future<LoginResponse> registerBusiness(SignUpRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.registerBusiness,
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    }
  }

  Future<ApiResponse> checkUserAvailablity(
    UserAvailabilityRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.existanceCheck,
        data: request.toJson(),
      );

      // Handle expected structure gracefully
      if (response.statusCode == 200 && response.data != null) {
        return ApiResponse.fromJson(response.data);
      } else {
        throw Exception('Unexpected response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    } catch (e) {
      throw Exception('User existance check failed');
    }
  }

  Future<ApiResponse> validateEmail(EmailRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.validateEmail,
        data: request.toJson(),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    }
  }

  Future<ApiResponse> verifyEmail(VerifyEmailRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyEmail,
        data: request.toJson(),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    }
  }

  Future<ApiResponse> validatePhone(PhoneNumberRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.validatePhone,
        data: request.toJson(),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    }
  }

  Future<ApiResponse> verifyPhone(VerifyPhoneOtpRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyPhone,
        data: request.toJson(),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    }
  }

  Future<ApiResponse> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.forgotPassword,
        data: request.toJson(),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    }
  }

  Future<ApiResponse> verifyForgotPassword(VerifyOtpRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyForgotPassword,
        data: request.toJson(),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    }
  }

  Future<ApiResponse> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.resetPassword,
        data: request.toJson(),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    }
  }

  Future<SetWalletPinResponse> setWalletPin(SetWalletPinRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.setWalletPin,
        data: request.toJson(),
      );
      return SetWalletPinResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    }
  }

  Future<UserModel> getUserProfile() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getUserProfile);
      final user = UserModel.fromJson(response.data);
      return user;
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    }
  }

  Future<UserTierResponse> getUserTier() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getUserTier);
      return UserTierResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    }
  }

  Future<VerifyWalletPinResponse> verifyWalletPin(
    VerifyWalletPinRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyWalletPin,
        data: request.toJson(),
      );
      return VerifyWalletPinResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    }
  }

  /// Update user profile using multipart PUT
  Future<UserModel> editProfile({
    String? fullName,
    String? phoneNumber,
    String? dateOfBirth,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? employmentStatus,
    String? occupation,
    String? primaryPurpose,
    String? sourceOfFunds,
    num? expectedMonthlyInflow,
    String? passportNumber,
    String? passportCountry,
    String? passportIssueDate,
    String? passportExpiryDate,
    String? passportDocumentUrl,
    String? bankStatementUrl,
    String? bankStatementIssueDate,
    String? bankStatementExpiryDate,
    String? utilityBillUrl,
    String? utilityBillIssueDate,
    String? utilityBillExpiryDate,
    String? profileImagePath,
    String? documentPath,
    String? documentType,
  }) async {
    try {
      final Map<String, dynamic> data = {
        if (fullName != null) 'fullName': fullName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (postalCode != null) 'postalCode': postalCode,
        if (employmentStatus != null) 'employmentStatus': employmentStatus,
        if (occupation != null) 'occupation': occupation,
        if (primaryPurpose != null) 'primaryPurpose': primaryPurpose,
        if (sourceOfFunds != null) 'sourceOfFunds': sourceOfFunds,
        if (expectedMonthlyInflow != null)
          'expectedMonthlyInflow': expectedMonthlyInflow,
        if (passportNumber != null) 'passportNumber': passportNumber,
        if (passportCountry != null) 'passportCountry': passportCountry,
        if (passportIssueDate != null) 'passportIssueDate': passportIssueDate,
        if (passportExpiryDate != null) 'passportExpiryDate': passportExpiryDate,
        if (passportDocumentUrl != null) 'passportDocumentUrl': passportDocumentUrl,
        if (bankStatementUrl != null) 'bankStatementUrl': bankStatementUrl,
        if (bankStatementIssueDate != null) 'bankStatementIssueDate': bankStatementIssueDate,
        if (bankStatementExpiryDate != null) 'bankStatementExpiryDate': bankStatementExpiryDate,
        if (utilityBillUrl != null) 'utilityBillUrl': utilityBillUrl,
        if (utilityBillIssueDate != null) 'utilityBillIssueDate': utilityBillIssueDate,
        if (utilityBillExpiryDate != null) 'utilityBillExpiryDate': utilityBillExpiryDate,
        if (documentType != null) 'documentType': documentType,
      };

      if (profileImagePath != null) {
        final file = File(profileImagePath);
        final fileName = file.path.split(Platform.pathSeparator).last;
        data['profile-image'] = await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        );
      }

      if (documentPath != null) {
        final file = File(documentPath);
        final fileName = file.path.split(Platform.pathSeparator).last;
        data['document'] = await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap(data);

      final response = await apiClient.putFormData(
        ApiEndpoints.editProfile,
        data: formData,
      );

      if (response.statusCode != 200) {
        throw Exception(
          response.data?['message'] ?? 'Failed to update profile',
        );
      }
      
      // The API returns the updated user details in the 'data' or 'user' field, or at the root
      final dynamic rawData = response.data;
      Map<String, dynamic>? userData;

      if (rawData is Map<String, dynamic>) {
        if (rawData['data'] is Map<String, dynamic>) {
          userData = rawData['data'];
        } else if (rawData['user'] is Map<String, dynamic>) {
          userData = rawData['user'];
        } else if (rawData.containsKey('id') || rawData.containsKey('email')) {
          userData = rawData;
        }
      }

      if (userData == null) {
        // Fallback: fetch profile again if the update response doesn't contain the user object
        return await getUserProfile();
      }

      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Upload profile image using multipart PUT (Legacy, kept for compatibility if needed)
  Future<ApiResponse> editProfileImage(String filePath, String fullName) async {
    try {
      await editProfile(profileImagePath: filePath, fullName: fullName);
      return ApiResponse(message: 'Profile updated successfully', statusCode: 200);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  String _normalizeDate(String rawDate) {
    if (rawDate.isEmpty) return rawDate;

    // Already in YYYY-MM-DD format
    final isoPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (isoPattern.hasMatch(rawDate)) return rawDate;

    // Try DD-MM-YYYY or DD/MM/YYYY
    final ddMmYyyyPattern = RegExp(r'^(\d{2})[-/](\d{2})[-/](\d{4})$');
    final match = ddMmYyyyPattern.firstMatch(rawDate);
    if (match != null) {
      final day = match.group(1)!;
      final month = match.group(2)!;
      final year = match.group(3)!;
      return '$year-$month-$day';
    }

    // Try standard parsing
    try {
      final date = DateTime.parse(rawDate);
      return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {}

    // Fallback: return as-is and let server handle it
    return rawDate;
  }

  /// Submit SmileID Basic KYC (BVN or NIN number verification)
  Future<ApiResponse> submitBasicKyc({
    required String idType,
    required String idNumber,
    required String dob,
    String? phoneNumber, // optional
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'idType': idType,
        'idNumber': idNumber,
        'dob': _normalizeDate(dob), // ensure YYYY-MM-DD format
      };
      // Only include phone if provided
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        payload['phoneNumber'] = phoneNumber;
      }
      final response = await apiClient.post(
        ApiEndpoints.basicKyc,
        data: payload,
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    } catch (e) {
      throw Exception('Basic KYC submission failed: $e');
    }
  }

  /// Submit SmileID Smart Selfie Registration (Enrolling liveness)
  Future<ApiResponse> submitSmartSelfieRegister({
    required String selfieImage,
    required List<String> livenessImages,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.biometricKyc,
        data: {
          'selfieImage': selfieImage,
          'livenessImages': livenessImages,
        },
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    } catch (e) {
      throw Exception('Smart Selfie Registration failed: $e');
    }
  }

  /// Submit SmileID Smart Selfie Authentication (Biometric for 50k+ transfers)
  Future<ApiResponse> submitSmartSelfieAuth({
    required String selfieImage,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.smartSelfieAuth,
        data: {
          'selfieImage': selfieImage,
        },
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    } catch (e) {
      throw Exception('Smart Selfie Authentication failed: $e');
    }
  }

  /// Poll SmileID job status
  Future<ApiResponse> getSmileIdJobStatus(String jobId) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.smileIdJobStatus(jobId),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    } catch (e) {
      throw Exception('Failed to get job status: $e');
    }
  }

  /// Verify NIN for Tier 2 KYC upgrade (Legacy/Wrapper for NinVerificationRequest)
  Future<NinVerificationResponse> verifyNinTier2(
    NinVerificationRequest request,
  ) async {
    try {
       // If liveness is present, we call smart selfie register
       if (request.selfieImage.isNotEmpty) {
          final res = await submitSmartSelfieRegister(
            selfieImage: request.selfieImage,
            livenessImages: request.livenessImages ?? [],
          );
          return NinVerificationResponse(
            message: res.message,
            statusCode: res.statusCode,
          );
       } else {
          // If no images, we call the old kycTier2 or basicKyc
          final response = await apiClient.post(
            ApiEndpoints.kycTier2,
            data: request.toJson(),
          );
          return NinVerificationResponse.fromJson(response.data);
       }
    } on DioException catch (e) {
      return NinVerificationResponse(
        message: ApiResponse.getErrorMessage(e.response?.data),
        error: e.response?.data is Map? e.response?.data['error'] ?? 'Bad Request' : 'Bad Request',
        statusCode: e.response?.statusCode ?? 400,
      );
    } catch (e) {
      return NinVerificationResponse(
        message: 'Unexpected error: $e',
        error: 'Internal Error',
        statusCode: 500,
      );
    }
  }

  /// Upload document for identity verification
  Future<ApiResponse> uploadDocument({
    required String documentType,
    required String documentPath,
    String? documentNumber,
    String? documentCountry,
    String? issueDate,
    String? expiryDate,
  }) async {
    try {
      final file = File(documentPath);
      final fileName = file.path.split(Platform.pathSeparator).last;

      final Map<String, dynamic> data = {
        'documentType': documentType,
        'document': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        if (documentNumber != null) 'documentNumber': documentNumber,
        if (documentCountry != null) 'documentCountry': documentCountry,
        if (issueDate != null) 'issueDate': issueDate,
        if (expiryDate != null) 'expiryDate': expiryDate,
      };

      final formData = FormData.fromMap(data);

      final response = await apiClient.postFormData(
        ApiEndpoints.uploadDocument,
        data: formData,
      );

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  /// Upload Tier 3 document (Proof of Address/Bank Statement)
  Future<ApiResponse> uploadTier3Document({
    required String filePath,
    String? documentType,
  }) async {
    try {
      final file = File(filePath);
      final fileName = file.path.split(Platform.pathSeparator).last;

      final Map<String, dynamic> data = {
        'tier3Document': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        if (documentType != null) 'documentType': documentType,
      };

      final formData = FormData.fromMap(data);

      final response = await apiClient.postFormData(
        ApiEndpoints.uploadTier3Document,
        data: formData,
      );

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    } catch (e) {
      throw Exception('Failed to upload Tier 3 document: $e');
    }
  }

  /// Upload CAC document for business accounts
  Future<ApiResponse> uploadCacDocument(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = file.path.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        'cacDocument': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await apiClient.postFormData(
        ApiEndpoints.uploadCacDocument,
        data: formData,
      );

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiResponse.getErrorMessage(e.response?.data));
    } catch (e) {
      throw Exception('Failed to upload CAC document: $e');
    }
  }
}

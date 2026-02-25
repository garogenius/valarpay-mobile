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
      throw Exception(e.response?.data['message'] ?? 'Sign up failed');
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
      throw Exception(
        e.response?.data['message'] ?? 'Business registration failed',
      );
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
      final serverMessage =
          e.response?.data != null
              ? e.response?.data['message'] ?? 'User existance check failed'
              : 'User existance check failed';
      throw Exception(serverMessage);
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
      throw Exception(
        e.response?.data['message'] ?? 'Failed to resend verification code',
      );
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
      throw Exception(
        e.response?.data['message'] ?? 'Email verification failed',
      );
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
      throw Exception(
        e.response?.data['message'] ?? 'Failed to resend verification code',
      );
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
      throw Exception(
        e.response?.data['message'] ?? 'Phone verification failed',
      );
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
      throw Exception(
        e.response?.data['message'] ?? 'Failed to send reset link',
      );
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
      throw Exception(e.response?.data['message'] ?? 'Failed to verify OTP');
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
      throw Exception(
        e.response?.data['message'] ?? 'Failed to reset password',
      );
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
      throw Exception(
        e.response?.data['message'] ?? 'Failed to set wallet PIN',
      );
    }
  }

  Future<UserModel> getUserProfile() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getUserProfile);
      final user = UserModel.fromJson(response.data);
      return user;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch user profile',
      );
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
      throw Exception(
        e.response?.data['message'] ?? 'Failed to verify wallet PIN',
      );
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
       final message = e.response?.data?['message'];
       if (message is List) {
         throw Exception(message.join(', '));
       }
      throw Exception(message ?? 'Failed to update profile');
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

  /// Verify NIN for Tier 2 KYC upgrade
  Future<NinVerificationResponse> verifyNinTier2(
    NinVerificationRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.kycTier2,
        data: request.toJson(),
      );

      return NinVerificationResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Return error response with proper structure
      return NinVerificationResponse(
        message: e.response?.data['message'] ?? 'NIN verification failed',
        error: e.response?.data['error'] ?? 'Bad Request',
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

  /// Submit address for Tier 3 KYC upgrade
  Future<ApiResponse> submitKycTier3(Map<String, dynamic> addressData) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.kycTier3,
        data: addressData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.fromJson(response.data);
      } else {
        throw Exception(
          response.data?['message'] ?? 'Failed to submit address verification',
        );
      }
    } on DioException catch (e) {
      // Try to extract the error message from the response
      String errorMessage = 'Failed to submit address verification';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage =
              e.response!.data['message'] ??
              e.response!.data['error'] ??
              errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to submit address verification: $e');
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
      throw Exception(
        e.response?.data['message'] ?? 'Document upload failed',
      );
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }
}

// ignore: file_names
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/api_response.dart';
import 'package:valarpay/features/models/nin_verification_request.dart';
import 'package:valarpay/features/models/nin_verification_response.dart';
import 'package:valarpay/features/models/email_request.dart';
import 'package:valarpay/features/models/set_wallet_pin_request.dart';
import 'package:valarpay/features/models/set_wallet_pin_response.dart';
import 'package:valarpay/features/models/forgot_password.dart';
import 'package:valarpay/features/models/phone_number_request.dart';
import 'package:valarpay/features/models/reset_password.dart';
import 'package:valarpay/features/models/signup_request.dart';
import 'package:valarpay/features/models/user.dart';
import 'package:valarpay/features/models/user_availablity_request.dart';
import 'package:valarpay/features/models/verify_email_request.dart';
import 'package:valarpay/features/models/verify_otp_request.dart';
import 'package:valarpay/features/models/verify_phone_number.dart';
import 'package:valarpay/features/models/verify_wallet_pin_request.dart';
import 'package:valarpay/features/repositories/user_repository.dart';

import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class UserNotifier extends StateNotifier<DataState<UserModel>> {
  final UserRepository _repository;
  final Ref _ref;

  UserNotifier(this._repository, this._ref) : super(DataState<UserModel>.initial());

  Future<void> register(SignUpRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null, isDataAvailable: false);
    try {
      final res = await _repository.register(request);
      state = state.copyWith(
        isInitialLoading: false,
        data: [res.user],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[UserNotifier SignUp Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> registerBusiness(SignUpRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null, isDataAvailable: false);
    try {
      final res = await _repository.registerBusiness(request);
      state = state.copyWith(
        isInitialLoading: false,
        data: [res.user],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[UserNotifier Register Business Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> checkUserExistance(UserAvailabilityRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.checkUserAvailablity(request);
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[UserNotifier Availablity Check Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> validateEmail(EmailRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null, isDataAvailable: false);
    try {
      final res = await _repository.validateEmail(request);
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[UserNotifier Resend Code Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> verifyEmail(VerifyEmailRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null, isDataAvailable: false);
    try {
      final res = await _repository.verifyEmail(request);
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[UserNotifier Verify Email Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<ApiResponse?> validatePhone(PhoneNumberRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null, isDataAvailable: false);
    try {
      final res = await _repository.validatePhone(request);
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: res.message,
      );
      return res;
    } catch (e, stack) {
      log('[UserNotifier Resend Code Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  Future<ApiResponse?> verifyPhone(VerifyPhoneOtpRequest request) async {
    log(request.phoneNumber.toString());
    log(request.otpCode.toString());

    state = state.copyWith(isInitialLoading: true, message: null, isDataAvailable: false);
    try {
      final res = await _repository.verifyPhone(request);
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: res.message,
      );
      return res;
    } catch (e, stack) {
      log('[UserNotifier Verify Phone Number Error] $e\n$stack');
      log(e.toString());
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.forgotPassword(request);
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[UserNotifier Forgot Password Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> verifyForgotPassword(VerifyOtpRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.verifyForgotPassword(request);
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[UserNotifier Verify OTP Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.resetPassword(request);
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[UserNotifier Reset Password Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<SetWalletPinResponse?> setWalletPin(
    SetWalletPinRequest request,
  ) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.setWalletPin(request);
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: res.message,
      );
      return res;
    } catch (e, stack) {
      log('[UserNotifier Set Wallet PIN Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  Future<UserModel?> refreshUserProfile() async {
    try {
      final user = await _repository.getUserProfile();
      
      // Mitigate backend replication lag by preserving local 'true' states
      final currentUser = _ref.read(userProvider);
      UserModel finalUser = user;
      
      if (currentUser != null) {
        bool needsOverride = false;
        final jsonMap = user.toJson();
        
        if (currentUser.isWalletPinSet == true && !user.isWalletPinSet) {
          jsonMap['isWalletPinSet'] = true;
          jsonMap['pin_set'] = true;
          jsonMap['is_wallet_pin_set'] = true;
          needsOverride = true;
        }
        
        if (currentUser.isPasscodeSet == true && !user.isPasscodeSet) {
          jsonMap['isPasscodeSet'] = true;
          jsonMap['is_passcode_set'] = true;
          needsOverride = true;
        }

        if (currentUser.isBvnVerified == true && !user.isBvnVerified) {
          jsonMap['isBvnVerified'] = true;
          jsonMap['is_bvn_verified'] = true;
          needsOverride = true;
        }

        if (currentUser.isNinVerified == true && !user.isNinVerified) {
          jsonMap['isNinVerified'] = true;
          jsonMap['is_nin_verified'] = true;
          needsOverride = true;
        }

        if (needsOverride) {
           finalUser = UserModel.fromJson(jsonMap);
        }
      }

      // Persist user data
      await SessionService.saveUser(finalUser);
      // Sync with userProvider
      _ref.read(userProvider.notifier).setUser(finalUser);
      state = state.copyWith(data: [finalUser], isDataAvailable: true);
      return finalUser;
    } catch (e, stack) {
      log('[UserNotifier Refresh Profile Error] $e\n$stack');
      return null;
    }
  }

  Future<bool> verifyWalletPin(String pin) async {
    try {
      log('[UserNotifier] Verifying wallet PIN...');
      final request = VerifyWalletPinRequest(pin: pin);
      final response = await _repository.verifyWalletPin(request);
      log('[UserNotifier] PIN verification result: ${response.isSuccess}');
      return response.isSuccess;
    } catch (e, stack) {
      log('[UserNotifier Verify PIN Error] $e\n$stack');
      return false;
    }
  }

  Future<NinVerificationResponse?> verifyNinTier2(
    NinVerificationRequest request,
  ) async {
    try {
      final response = await _repository.verifyNinTier2(request);
      
      if (response.isSuccess) {
        log('[UserNotifier] Tier 2 verification successful, refreshing profile...');
        await refreshUserProfile();
      }

      return response;
    } catch (e, stack) {
      log('[UserNotifier NIN Verification Error] $e\n$stack');
      return NinVerificationResponse(
        message: e.toString().replaceAll('Exception: ', ''),
        error: 'Verification failed',
        statusCode: 500,
      );
    }
  }

  /// Submit KYC Tier 3 address verification
  Future<void> submitKycTier3(Map<String, dynamic> addressData) async {
    try {
      final response = await _repository.submitKycTier3(addressData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await refreshUserProfile();
      }
    } catch (e, stack) {
      log('[UserNotifier KYC Tier 3 Error] $e\n$stack');
      rethrow;
    }
  }

  /// Verify NIN only (without selfie) for Tier 2 KYC upgrade
  Future<NinVerificationResponse?> verifyNinOnly(String nin) async {
    try {
      final request = NinVerificationRequest(
        nin: nin,
        selfieImage: '', // Empty string for no selfie
      );

      final response = await _repository.verifyNinTier2(request);
      if (response.isSuccess) {
        log(
          '[UserNotifier] NIN verification successful, refreshing profile...',
        );
        await refreshUserProfile();
      }

      return response;
    } catch (e, stack) {
      log('[UserNotifier NIN Verification Error] $e\n$stack');
      rethrow;
    }
  }

  Future<void> editProfile({
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
    this.state = this.state.copyWith(isInitialLoading: true, message: null);
    try {
      final updatedUser = await _repository.editProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        address: address,
        city: city,
        state: state,
        postalCode: postalCode,
        employmentStatus: employmentStatus,
        occupation: occupation,
        primaryPurpose: primaryPurpose,
        sourceOfFunds: sourceOfFunds,
        expectedMonthlyInflow: expectedMonthlyInflow,
        passportNumber: passportNumber,
        passportCountry: passportCountry,
        passportIssueDate: passportIssueDate,
        passportExpiryDate: passportExpiryDate,
        passportDocumentUrl: passportDocumentUrl,
        bankStatementUrl: bankStatementUrl,
        bankStatementIssueDate: bankStatementIssueDate,
        bankStatementExpiryDate: bankStatementExpiryDate,
        utilityBillUrl: utilityBillUrl,
        utilityBillIssueDate: utilityBillIssueDate,
        utilityBillExpiryDate: utilityBillExpiryDate,
        profileImagePath: profileImagePath,
        documentPath: documentPath,
        documentType: documentType,
      );
      // Persist user data
      await SessionService.saveUser(updatedUser);
      // Sync with userProvider
      _ref.read(userProvider.notifier).setUser(updatedUser);

      this.state = this.state.copyWith(
        isInitialLoading: false,
        data: [updatedUser],
        isDataAvailable: true,
        message: 'Profile updated successfully',
      );
    } catch (e, stack) {
      this.state = this.state.copyWith(
        isInitialLoading: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<ApiResponse?> submitBasicKyc({
    required String idType,
    required String idNumber,
    required String idDob,
    String? idPhoneNumber, // optional
  }) async {
    try {
      final res = await _repository.submitBasicKyc(
        idType: idType,
        idNumber: idNumber,
        dob: idDob,
        phoneNumber: idPhoneNumber,
      );
      return res;
    } catch (e) {
      log('Basic KYC Error: $e');
      rethrow;
    }
  }

  Future<ApiResponse?> submitSmartSelfieRegister({
    required String selfieImage,
    required List<String> livenessImages,
  }) async {
    try {
      final res = await _repository.submitSmartSelfieRegister(
        selfieImage: selfieImage,
        livenessImages: livenessImages,
      );
      return res;
    } catch (e) {
      log('Smart Selfie Register Error: $e');
      rethrow;
    }
  }

  Future<ApiResponse?> submitSmartSelfieAuth({
    required String selfieImage,
  }) async {
    try {
      final res = await _repository.submitSmartSelfieAuth(
        selfieImage: selfieImage,
      );
      return res;
    } catch (e) {
      log('Smart Selfie Auth Error: $e');
      rethrow;
    }
  }

  Future<ApiResponse?> getSmileIdJobStatus(String jobId) async {
    try {
      final res = await _repository.getSmileIdJobStatus(jobId);
      return res;
    } catch (e) {
      log('Job Status Error: $e');
      rethrow;
    }
  }

  /// Upload document for identity verification
  Future<ApiResponse?> uploadDocument({
    required String documentType,
    required String documentPath,
    String? documentNumber,
    String? documentCountry,
    String? issueDate,
    String? expiryDate,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.uploadDocument(
        documentType: documentType,
        documentPath: documentPath,
        documentNumber: documentNumber,
        documentCountry: documentCountry,
        issueDate: issueDate,
        expiryDate: expiryDate,
      );
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: res.message,
      );
      // Refresh profile after upload to update verification status if needed
      await refreshUserProfile();
      return res;
    } catch (e, stack) {
      log('[UserNotifier uploadDocument Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  void reset() => state = DataState<UserModel>.initial();
}

// 🔹 Providers

final userRepositoryProvider = Provider(
  (ref) => UserRepository(ref.read(apiClientProvider)),
);

final userNotifierProvider =
    StateNotifierProvider<UserNotifier, DataState<UserModel>>(
      (ref) => UserNotifier(ref.read(userRepositoryProvider), ref),
    );

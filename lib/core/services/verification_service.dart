
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:valarpay/features/models/qore_bvn_face_verification_request.dart';
import 'package:valarpay/features/models/qore_bvn_face_verification_response.dart';
import 'package:valarpay/features/models/qore_token_request.dart';
import 'package:valarpay/features/models/qore_token_response.dart';

class VerificationService {
  static const String _tokenUrl = 'https://api.qoreid.com/token';
  static const String _baseUrl =
      'https://api.qoreid.com/v1/ng/identities/face-verification/bvn';

  final Dio _dio;
  VerificationService({Dio? dio}) : _dio = dio ?? Dio();

  /// Generate access token from Qore API
  Future<QoreTokenResponse> getAccessToken(QoreTokenRequest request) async {
    try {
      final response = await _dio.post(
        _tokenUrl,
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }
        ),
      );
      return QoreTokenResponse.fromJson(response.data);
    } on DioException catch (e) {
      return QoreTokenResponse(
        message: e.response?.data['message'] ?? 'Token request failed',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return QoreTokenResponse(
        message: 'Unexpected error: $e',
        statusCode: 500,
      );
    }
  }

  Future<QoreBvnFaceVerificationResponse> verifyBvnFace(
    QoreBvnFaceVerificationRequest request,
  ) async {
    try {
      
      final tokenResponse = await getAccessToken(
        QoreTokenRequest(
          clientId: 'QLBQA1VCADWNAHRHP3G3',
          secret: '59ab112e8cc549829a66a84d0c550256',
        ),
      );
      if (tokenResponse.accessToken != null) {
        final response = await _dio.post(
          _baseUrl,
          data: request.toJson(),
          options: Options(
            headers: {
              'Authorization': 'Bearer ${tokenResponse.accessToken}',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

        // log(response.toString());
        return QoreBvnFaceVerificationResponse.fromJson(response.data);
      } else {
        return QoreBvnFaceVerificationResponse(
          message: tokenResponse.message ?? 'Verification failed',
          statusCode: tokenResponse.statusCode ?? 400,
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      return QoreBvnFaceVerificationResponse(
        message: data?['message'] ?? 'Verification failed',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return QoreBvnFaceVerificationResponse(
        message: 'Unexpected error: $e',
        statusCode: 500,
      );
    }
  }
}

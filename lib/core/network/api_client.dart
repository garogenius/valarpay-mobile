import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:valarpay/core/services/session_service.dart';

class ApiClient {
  static const String baseUrl = 'https://valar-pay-api.up.railway.app';
  static const String apiKey = '5821039487621507';

  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-api-key': apiKey,
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // log("Api call:${options.path}");
          // log("Request:${options.data.toString()}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // log("Response: ${response.statusCode}");
          if (response.statusCode == 200) {
            final data = response.data;

            // Skip validation for endpoints that return data directly (not wrapped in 'data' field)
            final proceedWithValidation = response.requestOptions.path.contains(
              '/verify-account',
            );

            if (proceedWithValidation) {
              if (data is Map &&
                  (data['data'] == null || data['data'].toString() == '{}')) {
                return handler.reject(
                  DioException(
                    requestOptions: response.requestOptions,
                    error: "Invalid response returned by server.",
                    type: DioExceptionType.badResponse,
                  ),
                );
              }
            }
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // ✅ Handle 401 Unauthorized
          if (e.response?.statusCode == 401) {
            await SessionService.logout();
          }

          return handler.next(e);
        },
      ),
    );
  }

  Future<void> _withAuth(Options options) async {
    final token = await SessionService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers ??= {};
      options.headers!['Authorization'] = 'Bearer $token';
    }
  }

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    final options = Options();
    await _withAuth(options);
    return await dio.post(path, data: data, options: options);
  }

  Future<Response> postFormData(String path, {required FormData data}) async {
    final options = Options(contentType: 'multipart/form-data');
    await _withAuth(options);
    return await dio.post(path, data: data, options: options);
  }

  Future<Response> putFormData(String path, {required FormData data}) async {
    final options = Options(contentType: 'multipart/form-data');
    await _withAuth(options);
    return await dio.put(path, data: data, options: options);
  }

  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    final options = Options();
    await _withAuth(options);
    return await dio.get(path, queryParameters: query, options: options);
  }

  Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    final options = Options();
    await _withAuth(options);
    return await dio.put(path, data: data, options: options);
  }

  Future<Response> delete(String path) async {
    final options = Options();
    await _withAuth(options);
    return await dio.delete(path, options: options);
  }
}

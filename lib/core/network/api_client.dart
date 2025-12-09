import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:valarpay/core/services/session_service.dart';

class ApiClient {
  //static const String baseUrl = 'https://valarpay.nattycore.com';
  static const String baseUrl =  'https://valar-pay-backend-staging.up.railway.app';
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
          _logRequest(options);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);

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
          _logError(e);
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

  void _logRequest(RequestOptions options) {
    log(
      '╔════════════════════════════════════════════════════════════════════════════',
    );
    log('║ 🌐 API REQUEST');
    log(
      '╠════════════════════════════════════════════════════════════════════════════',
    );
    log('║ Method: ${options.method}');
    log('║ URL: ${options.baseUrl}${options.path}');

    if (options.queryParameters.isNotEmpty) {
      log('║ Query Parameters: ${options.queryParameters}');
    }

    if (options.headers.isNotEmpty) {
      log('║ Headers:');
      options.headers.forEach((key, value) {
        // Mask sensitive headers
        if (key.toLowerCase() == 'authorization') {
          log('║   $key: Bearer ***');
        } else if (key.toLowerCase() == 'x-api-key') {
          log('║   $key: ***');
        } else {
          log('║   $key: $value');
        }
      });
    }

    if (options.data != null) {
      log('║ Payload:');
      log('║ ${_formatJson(options.data)}');
    }

    log(
      '╚════════════════════════════════════════════════════════════════════════════',
    );
  }

  void _logResponse(Response response) {
    log(
      '╔════════════════════════════════════════════════════════════════════════════',
    );
    log('║ ✅ API RESPONSE');
    log(
      '╠════════════════════════════════════════════════════════════════════════════',
    );
    log('║ Method: ${response.requestOptions.method}');
    log(
      '║ URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}',
    );
    log(
      '║ Status Code: ${response.statusCode} ${response.statusMessage ?? ''}',
    );

    if (response.headers.map.isNotEmpty) {
      log('║ Response Headers:');
      response.headers.map.forEach((key, value) {
        log('║   $key: ${value.join(', ')}');
      });
    }

    if (response.data != null) {
      log('║ Response Data:');
      log('║ ${_formatJson(response.data)}');
    }

    log(
      '╚════════════════════════════════════════════════════════════════════════════',
    );
  }

  void _logError(DioException error) {
    log(
      '╔════════════════════════════════════════════════════════════════════════════',
    );
    log('║ ❌ API ERROR');
    log(
      '╠════════════════════════════════════════════════════════════════════════════',
    );
    log('║ Method: ${error.requestOptions.method}');
    log('║ URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
    log('║ Error Type: ${error.type}');
    log('║ Error Message: ${error.message}');

    if (error.response != null) {
      log('║ Status Code: ${error.response!.statusCode}');
      log('║ Response Data:');
      log('║ ${_formatJson(error.response!.data)}');
    }

    log('║ Stack Trace:');
    log('║ ${error.stackTrace.toString().split('\n').take(5).join('\n║ ')}');

    log(
      '╚════════════════════════════════════════════════════════════════════════════',
    );
  }

  String _formatJson(dynamic data) {
    try {
      if (data == null) return 'null';
      if (data is String) return data;

      // Pretty print JSON with indentation
      final encoder = const JsonEncoder.withIndent('  ');
      return encoder
          .convert(data)
          .split('\n')
          .map((line) => '   $line')
          .join('\n║');
    } catch (e) {
      return data.toString();
    }
  }

  Future<Response> delete(String path) async {
    final options = Options();
    await _withAuth(options);
    return await dio.delete(path, options: options);
  }
}

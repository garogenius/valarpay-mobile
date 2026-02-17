import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/core/network/data_state.dart';

final apiClientProvider = Provider((ref) => ApiClient());

class ApiClient {
  static const String baseUrl = 'https://valarpay.nattycore.com';
    // static const String baseUrl = 'https://valar-pay-api.up.railway.app';
  // static const String baseUrl = 'https://valar-pay-api.up.railway.app';
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

  // --- Base HTTP Methods (Returning Response) ---

  Future<Response> post(String path, {Map<String, dynamic>? data, bool useAuth = true}) async {
    final options = Options();
    if (useAuth) {
      await _withAuth(options);
    }
    return await dio.post(path, data: data, options: options);
  }

  Future<Response> get(String path, {Map<String, dynamic>? query, Map<String, dynamic>? queryParameters, bool useAuth = true}) async {
    final options = Options();
    if (useAuth) {
      await _withAuth(options);
    }
    return await dio.get(path, queryParameters: query ?? queryParameters, options: options);
  }

  Future<Response> put(String path, {Map<String, dynamic>? data, bool useAuth = true}) async {
    final options = Options();
    if (useAuth) {
      await _withAuth(options);
    }
    return await dio.put(path, data: data, options: options);
  }

  Future<Response> patch(String path, {Map<String, dynamic>? data, Map<String, dynamic>? queryParameters, bool useAuth = true}) async {
    final options = Options();
    if (useAuth) {
      await _withAuth(options);
    }
    return await dio.patch(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(String path, {bool useAuth = true}) async {
    final options = Options();
    if (useAuth) {
      await _withAuth(options);
    }
    return await dio.delete(path, options: options);
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

  // --- DataState Methods (Strongly Typed with Converters) ---

  Future<DataState<T>> getData<T>(String path, {Map<String, dynamic>? query, Map<String, dynamic>? queryParameters, bool useAuth = true, required dynamic Function(dynamic) converter}) async {
    try {
      final response = await get(path, query: query, queryParameters: queryParameters, useAuth: useAuth);
      final converted = converter(response.data);
      if (converted is List) {
        return DataSuccess<T>(data: converted.cast<T>());
      }
      return DataSuccess<T>(singleData: converted as T, data: [converted as T]);
    } on DioException catch (e) {
      return DataFailed<T>(e.message ?? 'An error occurred');
    } catch (e) {
      return DataFailed<T>(e.toString());
    }
  }

  Future<DataState<T>> postData<T>(String path, {Map<String, dynamic>? data, bool useAuth = true, required dynamic Function(dynamic) converter}) async {
    try {
      final response = await post(path, data: data, useAuth: useAuth);
      final converted = converter(response.data);
      if (converted is List) {
        return DataSuccess<T>(data: converted.cast<T>());
      }
      return DataSuccess<T>(singleData: converted as T, data: [converted as T]);
    } on DioException catch (e) {
      return DataFailed<T>(e.message ?? 'An error occurred');
    } catch (e) {
      return DataFailed<T>(e.toString());
    }
  }

  Future<DataState<T>> putData<T>(String path, {Map<String, dynamic>? data, required dynamic Function(dynamic) converter}) async {
    try {
      final response = await put(path, data: data);
      final converted = converter(response.data);
      if (converted is List) {
        return DataSuccess<T>(data: converted.cast<T>());
      }
      return DataSuccess<T>(singleData: converted as T, data: [converted as T]);
    } on DioException catch (e) {
      return DataFailed<T>(e.message ?? 'An error occurred');
    } catch (e) {
      return DataFailed<T>(e.toString());
    }
  }

  Future<DataState<T>> patchData<T>(String path, {Map<String, dynamic>? data, Map<String, dynamic>? queryParameters, required dynamic Function(dynamic) converter}) async {
    try {
      final response = await patch(path, data: data, queryParameters: queryParameters);
      final converted = converter(response.data);
      if (converted is List) {
        return DataSuccess<T>(data: converted.cast<T>());
      }
      return DataSuccess<T>(singleData: converted as T, data: [converted as T]);
    } on DioException catch (e) {
      return DataFailed<T>(e.message ?? 'An error occurred');
    } catch (e) {
      return DataFailed<T>(e.toString());
    }
  }

  void _logRequest(RequestOptions options) {
    final logMessage = StringBuffer();
    logMessage.writeln('╔════════════════════════════════════════════════════════════════════════════');
    logMessage.writeln('║ 🌐 API REQUEST');
    logMessage.writeln('╠════════════════════════════════════════════════════════════════════════════');
    logMessage.writeln('║ Method: ${options.method}');
    logMessage.writeln('║ URL: ${options.baseUrl}${options.path}');

    if (options.queryParameters.isNotEmpty) {
      logMessage.writeln('║ Query Parameters: ${options.queryParameters}');
    }

    if (options.headers.isNotEmpty) {
      logMessage.writeln('║ Headers:');
      options.headers.forEach((key, value) {
        // Mask sensitive headers
        if (key.toLowerCase() == 'authorization') {
          logMessage.writeln('║   $key: Bearer ***');
        } else if (key.toLowerCase() == 'x-api-key') {
          logMessage.writeln('║   $key: ***');
        } else {
          logMessage.writeln('║   $key: $value');
        }
      });
    }

    if (options.data != null) {
      logMessage.writeln('║ Payload:');
      logMessage.writeln(_formatJson(options.data));
    }

    logMessage.writeln('╚════════════════════════════════════════════════════════════════════════════');
    
    _printLog(logMessage.toString(), 'API_REQUEST');
  }

  void _logResponse(Response response) {
    final logMessage = StringBuffer();
    logMessage.writeln('╔════════════════════════════════════════════════════════════════════════════');
    logMessage.writeln('║ ✅ API RESPONSE');
    logMessage.writeln('╠════════════════════════════════════════════════════════════════════════════');
    logMessage.writeln('║ Method: ${response.requestOptions.method}');
    logMessage.writeln('║ URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}');
    logMessage.writeln('║ Status Code: ${response.statusCode} ${response.statusMessage ?? ''}');

    if (response.headers.map.isNotEmpty) {
      logMessage.writeln('║ Response Headers:');
      response.headers.map.forEach((key, value) {
        logMessage.writeln('║   $key: ${value.join(', ')}');
      });
    }

    if (response.data != null) {
      logMessage.writeln('║ Response Data:');
      logMessage.writeln(_formatJson(response.data));
    }

    logMessage.writeln('╚════════════════════════════════════════════════════════════════════════════');
    
    _printLog(logMessage.toString(), 'API_RESPONSE');
  }

  void _logError(DioException error) {
    final logMessage = StringBuffer();
    logMessage.writeln('╔════════════════════════════════════════════════════════════════════════════');
    logMessage.writeln('║ ❌ API ERROR');
    logMessage.writeln('╠════════════════════════════════════════════════════════════════════════════');
    logMessage.writeln('║ Method: ${error.requestOptions.method}');
    logMessage.writeln('║ URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
    logMessage.writeln('║ Error Type: ${error.type}');
    logMessage.writeln('║ Error Message: ${error.message}');

    if (error.response != null) {
      logMessage.writeln('║ Status Code: ${error.response!.statusCode}');
      logMessage.writeln('║ Response Data:');
      logMessage.writeln(_formatJson(error.response!.data));
    }

    logMessage.writeln('║ Stack Trace:');
    logMessage.writeln('║ ${error.stackTrace.toString().split('\n').take(5).join('\n║ ')}');

    logMessage.writeln('╚════════════════════════════════════════════════════════════════════════════');
    
    _printLog(logMessage.toString(), 'API_ERROR');
  }

  void _printLog(String message, String name) {
    // 1. Log to DevTools using dart:developer log (handles large strings better)
    log(message, name: name);
    
    // 2. Print to console string splitting to avoid truncation (Android logcat limit is ~4kb)
    // We strictly prefer printing line by line to keep the box formatting intact
    const int maxChunkSize = 800;
    
    final lines = message.split('\n');
    for (final line in lines) {
      if (line.length <= maxChunkSize) {
        print(line);
      } else {
        // If a single line is massive (e.g. minified JSON), split it
        for (int i = 0; i < line.length; i += maxChunkSize) {
          int end = (i + maxChunkSize < line.length) ? i + maxChunkSize : line.length;
          print(line.substring(i, end));
        }
      }
    }
  }

  String _formatJson(dynamic data) {
    try {
      if (data == null) return '║    null';
      
      dynamic content = data;
      
      // If data is a String, try to parse it as JSON to pretty print it
      if (data is String) {
        try {
          if (data.trim().startsWith('{') || data.trim().startsWith('[')) {
             content = jsonDecode(data);
          }
        } catch (_) {
          // Keep as string if parsing fails
        }
      }

      // Pretty print JSON with indentation
      final encoder = const JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(content);
      
      // Split into lines and prefix each with the box character
      final lines = jsonString.split('\n');
      final formattedLines = lines.map((line) => '║    $line').toList();
      
      return formattedLines.join('\n');
    } catch (e) {
      return '║    ${data.toString()}';
    }
  }
}

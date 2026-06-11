import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'token_manager.dart';

/// 全局统一的异常类
class ApiException implements Exception {
  final int code;
  final String message;
  ApiException({required this.code, required this.message});

  @override
  String toString() => 'ApiException(code: $code, message: $message)';
}

/// 统一网络请求封装
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;

  late Dio _dio;

  HttpClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConfig.timeout),
      receiveTimeout: const Duration(milliseconds: ApiConfig.timeout),
      headers: ApiConfig.defaultHeaders,
    ));

    // 添加拦截器：处理 Token、日志、统一错误上报
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (ApiConfig.enableLog) {
          print('--> [${options.method}] ${options.uri}');
        }
        // 自动携带 Token
        final username = await TokenManager.loadToken();
        if (username != null) {
          options.headers['Authorization'] = 'Bearer $username'; // Mock token usage
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (ApiConfig.enableLog) {
          print('<-- [${response.statusCode}] ${response.requestOptions.uri}');
        }
        // 业务层通用数据拆包 (假定服务器返回 { code: 0, message: 'ok', data: {...} })
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final code = data['code'];
          if (code != null && code != 0) {
            // 业务错误
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                error: ApiException(code: code, message: data['message'] ?? 'Business Error'),
                type: DioExceptionType.badResponse,
              ),
            );
          }
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (ApiConfig.enableLog) {
          print('<-- [Error] ${e.message}');
        }
        // 处理 401 登出逻辑等
        if (e.response?.statusCode == 401) {
          await TokenManager.clearToken();
          // TODO: Dispatch global logout event to UI
        }
        return handler.next(e);
      },
    ));
  }

  /// 通用 GET 请求
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data['data'] ?? response.data; // 返回解包后的 data
    } catch (e) {
      _handleError(e);
    }
  }

  /// 通用 POST 请求
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(dynamic e) {
    if (e is DioException && e.error is ApiException) {
      throw e.error as ApiException;
    }
    // 其他网络错误统装
    throw ApiException(code: -1, message: '网络请求失败，请稍后重试');
  }
}

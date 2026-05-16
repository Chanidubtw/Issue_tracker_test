import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';

class MockInterceptor extends Interceptor {
  Map<String, dynamic>? _mockData;

  Future<void> _ensureLoaded() async {
    if (_mockData != null) return;
    final raw = await rootBundle.loadString('assets/mock/issues.json');
    _mockData = jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    await Future.delayed(
        const Duration(milliseconds: AppConstants.mockNetworkDelay));
    await _ensureLoaded();

    final path = options.path;

    if (path.contains('/issues') && options.method == 'GET') {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: _mockData,
        ),
      );
      return;
    }

    if (path.contains('/auth/login') && options.method == 'POST') {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'token': 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
            'email': options.data['email'],
          },
        ),
      );
      return;
    }

    // Default: 404
    handler.reject(
      DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 404,
          data: {'message': 'Not found'},
        ),
        type: DioExceptionType.badResponse,
      ),
    );
  }
}

import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/issue_model.dart';
import 'mock_interceptor.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.mockBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    _dio.interceptors.add(MockInterceptor());
  }

  Future<List<IssueModel>> fetchIssues() async {
    try {
      final response = await _dio.get('/issues');
      final list = response.data['issues'] as List<dynamic>;
      return list
          .map((e) => IssueModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AuthException(e.message ?? 'Login failed');
    }
  }
}

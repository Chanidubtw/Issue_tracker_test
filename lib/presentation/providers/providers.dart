import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local/hive_issue_datasource.dart';
import '../../data/datasources/remote/api_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/issue_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/issue_repository.dart';

// Infrastructure
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final hiveIssueDatasourceProvider =
    Provider<HiveIssueDatasource>((ref) => HiveIssueDatasource());

// Repositories
final issueRepositoryProvider = Provider<IssueRepository>((ref) {
  return IssueRepositoryImpl(
    ref.watch(hiveIssueDatasourceProvider),
    ref.watch(apiServiceProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(apiServiceProvider),
    ref.watch(sharedPrefsProvider),
  );
});

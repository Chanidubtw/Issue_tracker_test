import '../../domain/entities/issue.dart';
import '../../domain/repositories/issue_repository.dart';
import '../datasources/local/hive_issue_datasource.dart';
import '../datasources/remote/api_service.dart';
import '../models/issue_model.dart';

class IssueRepositoryImpl implements IssueRepository {
  final HiveIssueDatasource _local;
  final ApiService _remote;

  const IssueRepositoryImpl(this._local, this._remote);

  @override
  Future<List<Issue>> getAllIssues() async {
    final local = _local.getAll();
    if (local.isEmpty) {
      return getRemoteIssues();
    }
    return local.map((m) => m.toEntity()).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Issue>> getRemoteIssues() async {
    final remote = await _remote.fetchIssues();
    // Merge: keep local-only (unsynced) issues, overwrite synced ones from remote
    final localPending = _local.getPending();
    final pendingIds = localPending.map((m) => m.id).toSet();

    final toStore = remote.where((m) => !pendingIds.contains(m.id)).toList();
    await _local.putAll(toStore);

    final all = _local.getAll();
    return all.map((m) => m.toEntity()).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Issue>> getLocalIssues() async {
    return _local.getAll().map((m) => m.toEntity()).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> saveIssue(Issue issue) async {
    await _local.put(IssueModel.fromIssue(issue));
  }

  @override
  Future<void> updateIssue(Issue issue) async {
    await _local.put(IssueModel.fromIssue(issue));
  }

  @override
  Future<void> deleteIssue(String id) async {
    await _local.delete(id);
  }

  @override
  Future<void> syncPendingIssues() async {
    // In a real app: POST/PATCH pending issues to the API.
    // Here we just mark them synced after the mock delay.
    final pending = _local.getPending();
    for (final model in pending) {
      await Future.delayed(const Duration(milliseconds: 100));
      await _local.markSynced(model.id);
    }
  }
}

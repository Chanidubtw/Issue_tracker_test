import '../entities/issue.dart';

abstract class IssueRepository {
  Future<List<Issue>> getRemoteIssues();
  Future<List<Issue>> getLocalIssues();
  Future<void> saveIssue(Issue issue);
  Future<void> updateIssue(Issue issue);
  Future<void> deleteIssue(String id);
  Future<void> syncPendingIssues();
  Future<List<Issue>> getAllIssues();
}

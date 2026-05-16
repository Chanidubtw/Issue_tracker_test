import '../entities/issue.dart';
import '../repositories/issue_repository.dart';

class GetAllIssuesUseCase {
  final IssueRepository _repo;
  const GetAllIssuesUseCase(this._repo);
  Future<List<Issue>> call() => _repo.getAllIssues();
}

class RefreshIssuesUseCase {
  final IssueRepository _repo;
  const RefreshIssuesUseCase(this._repo);
  Future<List<Issue>> call() => _repo.getRemoteIssues();
}

class CreateIssueUseCase {
  final IssueRepository _repo;
  const CreateIssueUseCase(this._repo);
  Future<void> call(Issue issue) => _repo.saveIssue(issue);
}

class UpdateIssueUseCase {
  final IssueRepository _repo;
  const UpdateIssueUseCase(this._repo);
  Future<void> call(Issue issue) => _repo.updateIssue(issue);
}

class DeleteIssueUseCase {
  final IssueRepository _repo;
  const DeleteIssueUseCase(this._repo);
  Future<void> call(String id) => _repo.deleteIssue(id);
}

class SyncIssuesUseCase {
  final IssueRepository _repo;
  const SyncIssuesUseCase(this._repo);
  Future<void> call() => _repo.syncPendingIssues();
}

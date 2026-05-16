import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/issue.dart';
import 'providers.dart';

enum IssueLoadStatus { initial, loading, loaded, refreshing, error }

class IssueState {
  final IssueLoadStatus status;
  final List<Issue> issues;
  final String? error;

  const IssueState({
    this.status = IssueLoadStatus.initial,
    this.issues = const [],
    this.error,
  });

  IssueState copyWith({
    IssueLoadStatus? status,
    List<Issue>? issues,
    String? error,
  }) {
    return IssueState(
      status: status ?? this.status,
      issues: issues ?? this.issues,
      error: error,
    );
  }
}

class IssueNotifier extends StateNotifier<IssueState> {
  final Ref _ref;
  static const _uuid = Uuid();

  IssueNotifier(this._ref) : super(const IssueState());

  Future<void> loadIssues() async {
    state = state.copyWith(status: IssueLoadStatus.loading);
    try {
      final issues =
          await _ref.read(issueRepositoryProvider).getAllIssues();
      state = IssueState(status: IssueLoadStatus.loaded, issues: issues);
    } catch (e) {
      state = IssueState(
        status: IssueLoadStatus.error,
        error: _message(e),
        issues: state.issues,
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(status: IssueLoadStatus.refreshing);
    try {
      final issues =
          await _ref.read(issueRepositoryProvider).getRemoteIssues();
      // Sync any pending local issues
      await _ref.read(issueRepositoryProvider).syncPendingIssues();
      state = IssueState(status: IssueLoadStatus.loaded, issues: issues);
    } catch (e) {
      state = state.copyWith(
        status: IssueLoadStatus.error,
        error: _message(e),
      );
    }
  }

  Future<void> createIssue({
    required String title,
    required String description,
    required IssueStatus status,
    required IssuePriority priority,
    String? assignee,
  }) async {
    final now = DateTime.now();
    final issue = Issue(
      id: 'local-${_uuid.v4()}',
      title: title,
      description: description,
      status: status,
      priority: priority,
      assignee: assignee?.trim().isEmpty == true ? null : assignee?.trim(),
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );
    await _ref.read(issueRepositoryProvider).saveIssue(issue);
    final updated = [issue, ...state.issues];
    state = state.copyWith(issues: updated);
  }

  Future<void> updateIssue(Issue issue) async {
    final updated = issue.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await _ref.read(issueRepositoryProvider).updateIssue(updated);
    final list = state.issues.map((i) => i.id == updated.id ? updated : i).toList();
    state = state.copyWith(issues: list);
  }

  Future<void> resolveIssue(String id) async {
    final issue = state.issues.firstWhere((i) => i.id == id);
    await updateIssue(issue.copyWith(status: IssueStatus.resolved));
  }

  Future<void> closeIssue(String id) async {
    final issue = state.issues.firstWhere((i) => i.id == id);
    await updateIssue(issue.copyWith(status: IssueStatus.closed));
  }

  Future<void> deleteIssue(String id) async {
    await _ref.read(issueRepositoryProvider).deleteIssue(id);
    state = state.copyWith(issues: state.issues.where((i) => i.id != id).toList());
  }

  String _message(Object e) =>
      e.toString().replaceFirst('Exception: ', '');
}

final issueProvider =
    StateNotifierProvider<IssueNotifier, IssueState>((ref) {
  return IssueNotifier(ref);
});

// Dashboard counts
final dashboardProvider = Provider<Map<String, int>>((ref) {
  final issues = ref.watch(issueProvider).issues;
  return {
    'open': issues.where((i) => i.status == IssueStatus.open).length,
    'in_progress':
        issues.where((i) => i.status == IssueStatus.inProgress).length,
    'resolved': issues.where((i) => i.status == IssueStatus.resolved).length,
    'closed': issues.where((i) => i.status == IssueStatus.closed).length,
    'total': issues.length,
  };
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/issue.dart';
import 'issue_provider.dart';

class FilterState {
  final String query;
  final IssueStatus? statusFilter;
  final IssuePriority? priorityFilter;

  const FilterState({
    this.query = '',
    this.statusFilter,
    this.priorityFilter,
  });

  FilterState copyWith({
    String? query,
    Object? statusFilter = _sentinel,
    Object? priorityFilter = _sentinel,
  }) {
    return FilterState(
      query: query ?? this.query,
      statusFilter: statusFilter == _sentinel
          ? this.statusFilter
          : statusFilter as IssueStatus?,
      priorityFilter: priorityFilter == _sentinel
          ? this.priorityFilter
          : priorityFilter as IssuePriority?,
    );
  }

  bool get hasActiveFilter =>
      query.isNotEmpty || statusFilter != null || priorityFilter != null;
}

const _sentinel = Object();

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>(
  (ref) => FilterNotifier(),
);

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setQuery(String q) => state = state.copyWith(query: q);
  void setStatus(IssueStatus? s) => state = state.copyWith(statusFilter: s);
  void setPriority(IssuePriority? p) =>
      state = state.copyWith(priorityFilter: p);
  void clearAll() => state = const FilterState();
}

final filteredIssuesProvider = Provider<List<Issue>>((ref) {
  final issues = ref.watch(issueProvider).issues;
  final filter = ref.watch(filterProvider);

  return issues.where((issue) {
    final matchesQuery = filter.query.isEmpty ||
        issue.title.toLowerCase().contains(filter.query.toLowerCase()) ||
        issue.description.toLowerCase().contains(filter.query.toLowerCase());
    final matchesStatus =
        filter.statusFilter == null || issue.status == filter.statusFilter;
    final matchesPriority =
        filter.priorityFilter == null || issue.priority == filter.priorityFilter;
    return matchesQuery && matchesStatus && matchesPriority;
  }).toList();
});

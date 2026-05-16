import 'package:flutter_test/flutter_test.dart';
import 'package:issue_tracker/domain/entities/issue.dart';

void main() {
  final baseIssue = Issue(
    id: 'test-001',
    title: 'Test Issue',
    description: 'A test description',
    status: IssueStatus.open,
    priority: IssuePriority.medium,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
    isSynced: false,
  );

  group('Issue.copyWith', () {
    test('copies with updated fields', () {
      final updated = baseIssue.copyWith(
        status: IssueStatus.resolved,
        priority: IssuePriority.high,
      );
      expect(updated.status, IssueStatus.resolved);
      expect(updated.priority, IssuePriority.high);
      expect(updated.id, baseIssue.id);
      expect(updated.title, baseIssue.title);
    });

    test('preserves original when no fields changed', () {
      final copy = baseIssue.copyWith();
      expect(copy.id, baseIssue.id);
      expect(copy.status, baseIssue.status);
    });
  });

  group('IssueStatus', () {
    test('fromValue maps known values', () {
      expect(IssueStatus.fromValue('open'), IssueStatus.open);
      expect(IssueStatus.fromValue('in_progress'), IssueStatus.inProgress);
      expect(IssueStatus.fromValue('resolved'), IssueStatus.resolved);
      expect(IssueStatus.fromValue('closed'), IssueStatus.closed);
    });

    test('fromValue falls back to open for unknown', () {
      expect(IssueStatus.fromValue('unknown'), IssueStatus.open);
    });
  });

  group('IssuePriority', () {
    test('fromValue maps known values', () {
      expect(IssuePriority.fromValue('low'), IssuePriority.low);
      expect(IssuePriority.fromValue('medium'), IssuePriority.medium);
      expect(IssuePriority.fromValue('high'), IssuePriority.high);
      expect(IssuePriority.fromValue('critical'), IssuePriority.critical);
    });

    test('fromValue falls back to medium for unknown', () {
      expect(IssuePriority.fromValue('unknown'), IssuePriority.medium);
    });
  });

  group('Issue.toJson / equality', () {
    test('toJson contains all fields', () {
      final json = baseIssue.toJson();
      expect(json['id'], 'test-001');
      expect(json['status'], 'open');
      expect(json['priority'], 'medium');
      expect(json['isSynced'], false);
    });

    test('two issues with same id are equal', () {
      final copy = baseIssue.copyWith(title: 'Different title');
      expect(baseIssue, copy);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/issue.dart';
import '../../providers/issue_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/sync_indicator.dart';

class IssueDetailScreen extends ConsumerWidget {
  final String issueId;
  const IssueDetailScreen({super.key, required this.issueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final issue = ref
        .watch(issueProvider)
        .issues
        .where((i) => i.id == issueId)
        .firstOrNull;

    if (issue == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Issue')),
        body: const Center(child: Text('Issue not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Issue #${_shortId(issue.id)}'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                context.push('/issues/${issue.id}/edit', extra: issue),
          ),
          PopupMenuButton<String>(
            onSelected: (val) => _handleAction(context, ref, issue, val),
            itemBuilder: (_) => [
              if (issue.status != IssueStatus.resolved)
                const PopupMenuItem(
                    value: 'resolve', child: Text('Mark as Resolved')),
              if (issue.status != IssueStatus.closed)
                const PopupMenuItem(
                    value: 'close', child: Text('Close Issue')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    issue.title,
                    style:
                        tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (!issue.isSynced) ...[
                  const SizedBox(width: 8),
                  const SyncIndicator(),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Status + Priority row
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                StatusChip(status: issue.status),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.priorityColor(issue.priority.value, cs)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.priorityColor(issue.priority.value, cs)
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: PriorityBadge(priority: issue.priority),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _InfoSection(
              label: 'Description',
              child: Text(issue.description,
                  style: tt.bodyMedium?.copyWith(height: 1.6)),
            ),
            const SizedBox(height: 20),

            // Meta grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _MetaRow(
                    icon: Icons.person_outline,
                    label: 'Assignee',
                    value: issue.assignee ?? 'Unassigned',
                    valueColor: issue.assignee == null ? cs.outline : null,
                  ),
                  const Divider(height: 20),
                  _MetaRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Created',
                    value: DateFormatter.toDateTime(issue.createdAt),
                  ),
                  const Divider(height: 20),
                  _MetaRow(
                    icon: Icons.update_outlined,
                    label: 'Last updated',
                    value: DateFormatter.toDateTime(issue.updatedAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            if (issue.status != IssueStatus.resolved &&
                issue.status != IssueStatus.closed)
              _ActionButtons(issue: issue),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref,
      Issue issue, String action) async {
    final cs = Theme.of(context).colorScheme;
    switch (action) {
      case 'resolve':
        final ok = await ConfirmDialog.show(
          context,
          title: 'Mark as Resolved',
          content:
              'Are you sure you want to mark "${issue.title}" as resolved?',
          confirmLabel: 'Resolve',
        );
        if (ok) {
          await ref.read(issueProvider.notifier).resolveIssue(issue.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Issue marked as resolved')),
            );
          }
        }
      case 'close':
        final ok = await ConfirmDialog.show(
          context,
          title: 'Close Issue',
          content: 'Are you sure you want to close "${issue.title}"?',
          confirmLabel: 'Close',
          confirmColor: cs.error,
        );
        if (ok) {
          await ref.read(issueProvider.notifier).closeIssue(issue.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Issue closed')),
            );
          }
        }
      case 'delete':
        final ok = await ConfirmDialog.show(
          context,
          title: 'Delete Issue',
          content:
              'This action cannot be undone. Delete "${issue.title}"?',
          confirmLabel: 'Delete',
          confirmColor: cs.error,
        );
        if (ok) {
          await ref.read(issueProvider.notifier).deleteIssue(issue.id);
          if (context.mounted) context.pop();
        }
    }
  }

  String _shortId(String id) {
    if (id.startsWith('issue-')) return id.replaceFirst('issue-', '');
    return id.length > 8 ? id.substring(0, 8) : id;
  }
}

class _InfoSection extends StatelessWidget {
  final String label;
  final Widget child;
  const _InfoSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                )),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 10),
        Text(label,
            style:
                tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value,
            style: tt.bodySmall
                ?.copyWith(color: valueColor ?? cs.onSurface)),
      ],
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  final Issue issue;
  const _ActionButtons({required this.issue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (issue.status != IssueStatus.resolved)
          FilledButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Mark as Resolved'),
            onPressed: () async {
              final ok = await ConfirmDialog.show(
                context,
                title: 'Mark as Resolved',
                content: 'Mark this issue as resolved?',
                confirmLabel: 'Resolve',
              );
              if (ok) {
                await ref
                    .read(issueProvider.notifier)
                    .resolveIssue(issue.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Issue marked as resolved')),
                  );
                }
              }
            },
          ),
        if (issue.status != IssueStatus.closed) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: Icon(Icons.cancel_outlined, color: cs.error),
            label:
                Text('Close Issue', style: TextStyle(color: cs.error)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final ok = await ConfirmDialog.show(
                context,
                title: 'Close Issue',
                content: 'Are you sure you want to close this issue?',
                confirmLabel: 'Close',
                confirmColor: cs.error,
              );
              if (ok) {
                await ref
                    .read(issueProvider.notifier)
                    .closeIssue(issue.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Issue closed')),
                  );
                }
              }
            },
          ),
        ],
      ],
    );
  }
}

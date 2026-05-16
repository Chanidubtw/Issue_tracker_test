import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/export_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/filter_provider.dart';
import '../../providers/issue_provider.dart';
import '../../providers/theme_provider.dart';
import '../../../domain/entities/issue.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final status = ref.read(issueProvider).status;
      if (status == IssueLoadStatus.initial) {
        ref.read(issueProvider.notifier).loadIssues();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dashboard = ref.watch(dashboardProvider);
    final issueState = ref.watch(issueProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName,
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: isDark ? 'Light mode' : 'Dark mode',
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) async {
              final issues = ref.read(issueProvider).issues;
              if (val == 'json') await ExportHelper.exportAsJson(issues);
              if (val == 'csv') await ExportHelper.exportAsCsv(issues);
              if (val == 'logout') {
                if (!context.mounted) return;
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go(RouteNames.login);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'json', child: Text('Export as JSON')),
              PopupMenuItem(value: 'csv', child: Text('Export as CSV')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'logout', child: Text('Sign out')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(issueProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overview',
                        style: tt.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '${dashboard['total']} total issues',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    _StatusGrid(dashboard: dashboard),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Issues',
                            style: tt.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        TextButton(
                          onPressed: () => context.go(RouteNames.issueList),
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (issueState.status == IssueLoadStatus.loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final recent = issueState.issues.take(5).toList();
                      if (index >= recent.length) return null;
                      final issue = recent[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DashboardIssueRow(
                          issue: issue,
                          onTap: () => context
                              .push('/issues/${issue.id}'),
                        ),
                      );
                    },
                    childCount: issueState.issues.take(5).length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.issueCreate),
        icon: const Icon(Icons.add),
        label: const Text('New Issue'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Issues'),
        ],
        onDestinationSelected: (i) {
          if (i == 1) context.go(RouteNames.issueList);
        },
      ),
    );
  }
}

class _StatusGrid extends StatelessWidget {
  final Map<String, int> dashboard;
  const _StatusGrid({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = [
      _CardData('Open', dashboard['open'] ?? 0, 'open', Icons.radio_button_unchecked),
      _CardData('In Progress', dashboard['in_progress'] ?? 0, 'in_progress', Icons.timelapse_outlined),
      _CardData('Resolved', dashboard['resolved'] ?? 0, 'resolved', Icons.check_circle_outline),
      _CardData('Closed', dashboard['closed'] ?? 0, 'closed', Icons.cancel_outlined),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: items.map((item) {
        final color = AppTheme.statusColor(item.statusKey, cs);
        return Consumer(builder: (context, ref, _) {
          return InkWell(
            onTap: () {
              final status = IssueStatus.fromValue(item.statusKey);
              ref.read(filterProvider.notifier).setStatus(status);
              context.go(RouteNames.issueList);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.count.toString(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Icon(item.icon, color: color, size: 22),
                    ],
                  ),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          );
        });
      }).toList(),
    );
  }
}

class _CardData {
  final String label;
  final int count;
  final String statusKey;
  final IconData icon;
  const _CardData(this.label, this.count, this.statusKey, this.icon);
}

class _DashboardIssueRow extends StatelessWidget {
  final Issue issue;
  final VoidCallback onTap;
  const _DashboardIssueRow({required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final priorityColor = AppTheme.priorityColor(issue.priority.value, cs);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                issue.title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.statusColor(issue.status.value, cs)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                issue.status.label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.statusColor(issue.status.value, cs),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

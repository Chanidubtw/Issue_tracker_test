import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/issue.dart';
import '../../providers/filter_provider.dart';
import '../../providers/issue_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/issue_card.dart';
import '../../widgets/loading_state.dart';

class IssueListScreen extends ConsumerStatefulWidget {
  const IssueListScreen({super.key});

  @override
  ConsumerState<IssueListScreen> createState() => _IssueListScreenState();
}

class _IssueListScreenState extends ConsumerState<IssueListScreen> {
  final _searchCtrl = TextEditingController();
  bool _showFilters = false;

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
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final issueState = ref.watch(issueProvider);
    final filter = ref.watch(filterProvider);
    final filtered = ref.watch(filteredIssuesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issues', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Toggle filters',
            icon: Badge(
              isLabelVisible: filter.hasActiveFilter,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: issueState.status == IssueLoadStatus.refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
            onPressed: issueState.status == IssueLoadStatus.refreshing
                ? null
                : () => ref.read(issueProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(controller: _searchCtrl),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _showFilters ? _FilterBar(filter: filter) : const SizedBox.shrink(),
          ),
          if (filter.hasActiveFilter)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Text('${filtered.length} result${filtered.length == 1 ? '' : 's'}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(filterProvider.notifier).clearAll();
                      _searchCtrl.clear();
                    },
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text('Clear filters'),
                    style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _buildBody(context, issueState, filtered),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.issueCreate),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
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
          if (i == 0) context.go(RouteNames.dashboard);
        },
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, IssueState state, List<Issue> issues) {
    if (state.status == IssueLoadStatus.loading) {
      return const LoadingState(message: 'Loading issues...');
    }
    if (state.status == IssueLoadStatus.error && state.issues.isEmpty) {
      return ErrorState(
        message: state.error ?? 'Unknown error',
        onRetry: () => ref.read(issueProvider.notifier).loadIssues(),
      );
    }
    if (issues.isEmpty) {
      return EmptyState(
        title: ref.read(filterProvider).hasActiveFilter
            ? 'No matching issues'
            : 'No issues yet',
        subtitle: ref.read(filterProvider).hasActiveFilter
            ? 'Try adjusting your filters'
            : 'Tap + to create your first issue',
        icon: Icons.search_off_outlined,
        action: ref.read(filterProvider).hasActiveFilter
            ? TextButton(
                onPressed: () {
                  ref.read(filterProvider.notifier).clearAll();
                  _searchCtrl.clear();
                },
                child: const Text('Clear filters'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(issueProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: issues.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final issue = issues[index];
          return IssueCard(
            issue: issue,
            onTap: () => context.push('/issues/${issue.id}'),
          );
        },
      ),
    );
  }
}

class _SearchBar extends ConsumerWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: (v) => ref.read(filterProvider.notifier).setQuery(v),
        decoration: InputDecoration(
          hintText: 'Search issues...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    ref.read(filterProvider.notifier).setQuery('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  final FilterState filter;
  const _FilterBar({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip<IssueStatus>(
                label: 'All',
                selected: filter.statusFilter == null,
                onSelected: (_) =>
                    ref.read(filterProvider.notifier).setStatus(null),
              ),
              ...IssueStatus.values.map((s) => _FilterChip<IssueStatus>(
                    label: s.label,
                    selected: filter.statusFilter == s,
                    onSelected: (_) =>
                        ref.read(filterProvider.notifier).setStatus(s),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Text('Priority',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip<IssuePriority>(
                label: 'All',
                selected: filter.priorityFilter == null,
                onSelected: (_) =>
                    ref.read(filterProvider.notifier).setPriority(null),
              ),
              ...IssuePriority.values.map((p) => _FilterChip<IssuePriority>(
                    label: p.label,
                    selected: filter.priorityFilter == p,
                    onSelected: (_) =>
                        ref.read(filterProvider.notifier).setPriority(p),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip<T> extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: true,
      visualDensity: VisualDensity.compact,
    );
  }
}

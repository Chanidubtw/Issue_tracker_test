import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/issue.dart';
import '../../providers/issue_provider.dart';

class IssueFormScreen extends ConsumerStatefulWidget {
  final Issue? existing;
  const IssueFormScreen({super.key, this.existing});

  @override
  ConsumerState<IssueFormScreen> createState() => _IssueFormScreenState();
}

class _IssueFormScreenState extends ConsumerState<IssueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _assigneeCtrl;
  late IssueStatus _status;
  late IssuePriority _priority;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _assigneeCtrl = TextEditingController(text: e?.assignee ?? '');
    _status = e?.status ?? IssueStatus.open;
    _priority = e?.priority ?? IssuePriority.medium;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _assigneeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await ref.read(issueProvider.notifier).updateIssue(
              widget.existing!.copyWith(
                title: _titleCtrl.text.trim(),
                description: _descCtrl.text.trim(),
                status: _status,
                priority: _priority,
                assignee: _assigneeCtrl.text.trim().isEmpty
                    ? null
                    : _assigneeCtrl.text.trim(),
              ),
            );
      } else {
        await ref.read(issueProvider.notifier).createIssue(
              title: _titleCtrl.text.trim(),
              description: _descCtrl.text.trim(),
              status: _status,
              priority: _priority,
              assignee: _assigneeCtrl.text.trim().isEmpty
                  ? null
                  : _assigneeCtrl.text.trim(),
            );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(_isEditing ? 'Issue updated' : 'Issue created')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Issue' : 'New Issue',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_isEditing ? 'Save' : 'Create',
                    style: TextStyle(
                        color: cs.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _SectionLabel('Title *'),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('title_field'),
              controller: _titleCtrl,
              textInputAction: TextInputAction.next,
              validator: Validators.title,
              maxLength: 100,
              decoration: const InputDecoration(
                hintText: 'Brief description of the issue',
              ),
            ),
            const SizedBox(height: 20),

            const _SectionLabel('Description *'),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('description_field'),
              controller: _descCtrl,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              validator: Validators.description,
              decoration: const InputDecoration(
                hintText: 'Detailed description, steps to reproduce, expected behavior...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Status'),
                      const SizedBox(height: 8),
                      _DropdownField<IssueStatus>(
                        key: const Key('status_dropdown'),
                        value: _status,
                        items: IssueStatus.values,
                        labelOf: (s) => s.label,
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Priority'),
                      const SizedBox(height: 8),
                      _DropdownField<IssuePriority>(
                        key: const Key('priority_dropdown'),
                        value: _priority,
                        items: IssuePriority.values,
                        labelOf: (p) => p.label,
                        onChanged: (v) => setState(() => _priority = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const _SectionLabel('Assignee (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('assignee_field'),
              controller: _assigneeCtrl,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                hintText: 'Name of the person responsible',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 32),

            FilledButton(
              key: const Key('submit_button'),
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : Text(_isEditing ? 'Save Changes' : 'Create Issue'),
            ),

            if (_isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
      ),
      borderRadius: BorderRadius.circular(12),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(labelOf(item)),
              ))
          .toList(),
    );
  }
}

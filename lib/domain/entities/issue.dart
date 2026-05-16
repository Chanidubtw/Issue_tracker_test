enum IssueStatus {
  open('open', 'Open'),
  inProgress('in_progress', 'In Progress'),
  resolved('resolved', 'Resolved'),
  closed('closed', 'Closed');

  const IssueStatus(this.value, this.label);
  final String value;
  final String label;

  static IssueStatus fromValue(String value) =>
      IssueStatus.values.firstWhere((e) => e.value == value,
          orElse: () => IssueStatus.open);
}

enum IssuePriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  critical('critical', 'Critical');

  const IssuePriority(this.value, this.label);
  final String value;
  final String label;

  static IssuePriority fromValue(String value) =>
      IssuePriority.values.firstWhere((e) => e.value == value,
          orElse: () => IssuePriority.medium);
}

class Issue {
  final String id;
  final String title;
  final String description;
  final IssueStatus status;
  final IssuePriority priority;
  final String? assignee;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  const Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.assignee,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Issue copyWith({
    String? id,
    String? title,
    String? description,
    IssueStatus? status,
    IssuePriority? priority,
    String? assignee,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Issue(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignee: assignee ?? this.assignee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.value,
        'priority': priority.value,
        'assignee': assignee,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isSynced': isSynced,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Issue && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

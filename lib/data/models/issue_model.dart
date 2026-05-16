import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/issue.dart';

part 'issue_model.g.dart';

@HiveType(typeId: 0)
class IssueModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late String status;

  @HiveField(4)
  late String priority;

  @HiveField(5)
  String? assignee;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  late DateTime updatedAt;

  @HiveField(8)
  late bool isSynced;

  IssueModel();

  factory IssueModel.fromIssue(Issue issue) => IssueModel()
    ..id = issue.id
    ..title = issue.title
    ..description = issue.description
    ..status = issue.status.value
    ..priority = issue.priority.value
    ..assignee = issue.assignee
    ..createdAt = issue.createdAt
    ..updatedAt = issue.updatedAt
    ..isSynced = issue.isSynced;

  factory IssueModel.fromJson(Map<String, dynamic> json) => IssueModel()
    ..id = json['id'] as String
    ..title = json['title'] as String
    ..description = json['description'] as String
    ..status = json['status'] as String
    ..priority = json['priority'] as String
    ..assignee = json['assignee'] as String?
    ..createdAt = DateTime.parse(json['createdAt'] as String)
    ..updatedAt = DateTime.parse(json['updatedAt'] as String)
    ..isSynced = json['isSynced'] as bool? ?? true;

  Issue toEntity() => Issue(
        id: id,
        title: title,
        description: description,
        status: IssueStatus.fromValue(status),
        priority: IssuePriority.fromValue(priority),
        assignee: assignee,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isSynced: isSynced,
      );
}

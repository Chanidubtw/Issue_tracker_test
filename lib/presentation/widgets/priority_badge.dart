import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/issue.dart';

class PriorityBadge extends StatelessWidget {
  final IssuePriority priority;
  final bool showLabel;

  const PriorityBadge({super.key, required this.priority, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = AppTheme.priorityColor(priority.value, cs);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

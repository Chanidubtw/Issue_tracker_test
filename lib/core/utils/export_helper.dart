import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/issue.dart';
import 'date_formatter.dart';

class ExportHelper {
  static Future<void> exportAsJson(List<Issue> issues) async {
    final data = issues.map((e) => e.toJson()).toList();
    final json = const JsonEncoder.withIndent('  ').convert({'issues': data});
    await _shareString(json, 'issues_export.json', 'application/json');
  }

  static Future<void> exportAsCsv(List<Issue> issues) async {
    final buffer = StringBuffer();
    buffer.writeln('ID,Title,Status,Priority,Assignee,Created At,Updated At');
    for (final issue in issues) {
      buffer.writeln([
        _csvCell(issue.id),
        _csvCell(issue.title),
        _csvCell(issue.status.label),
        _csvCell(issue.priority.label),
        _csvCell(issue.assignee ?? ''),
        _csvCell(DateFormatter.toCsvDate(issue.createdAt)),
        _csvCell(DateFormatter.toCsvDate(issue.updatedAt)),
      ].join(','));
    }
    await _shareString(buffer.toString(), 'issues_export.csv', 'text/csv');
  }

  static String _csvCell(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  static Future<void> _shareString(
      String content, String filename, String mimeType) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
      subject: 'Issue Tracker Export — $filename',
    );
  }
}

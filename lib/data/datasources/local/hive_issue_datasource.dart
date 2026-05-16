import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/issue_model.dart';

class HiveIssueDatasource {
  Box<IssueModel> get _box => Hive.box<IssueModel>(AppConstants.hiveIssueBox);

  List<IssueModel> getAll() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Failed to read local issues: $e');
    }
  }

  Future<void> put(IssueModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Failed to save issue: $e');
    }
  }

  Future<void> putAll(List<IssueModel> models) async {
    try {
      final map = {for (final m in models) m.id: m};
      await _box.putAll(map);
    } catch (e) {
      throw CacheException('Failed to save issues: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete issue: $e');
    }
  }

  List<IssueModel> getPending() {
    return _box.values.where((m) => !m.isSynced).toList();
  }

  Future<void> markSynced(String id) async {
    final model = _box.get(id);
    if (model != null) {
      model.isSynced = true;
      await model.save();
    }
  }
}

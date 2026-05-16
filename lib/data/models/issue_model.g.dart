
part of 'issue_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IssueModelAdapter extends TypeAdapter<IssueModel> {
  @override
  final int typeId = 0;

  @override
  IssueModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IssueModel()
      ..id = fields[0] as String
      ..title = fields[1] as String
      ..description = fields[2] as String
      ..status = fields[3] as String
      ..priority = fields[4] as String
      ..assignee = fields[5] as String?
      ..createdAt = fields[6] as DateTime
      ..updatedAt = fields[7] as DateTime
      ..isSynced = fields[8] as bool;
  }

  @override
  void write(BinaryWriter writer, IssueModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.assignee)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'fixed_group.freezed.dart';
part 'fixed_group.g.dart';

@freezed
abstract class FixedGroup with _$FixedGroup {
  const factory FixedGroup({
    required String id,
    @JsonKey(name: 'class_definition_id') required String classDefinitionId,
    required String name,
    @JsonKey(name: 'max_members') required int maxMembers,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _FixedGroup;

  factory FixedGroup.fromJson(Map<String, dynamic> json) =>
      _$FixedGroupFromJson(json);
}

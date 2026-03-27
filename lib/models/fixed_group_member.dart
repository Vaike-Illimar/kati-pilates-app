import 'package:freezed_annotation/freezed_annotation.dart';

part 'fixed_group_member.freezed.dart';
part 'fixed_group_member.g.dart';

enum FixedGroupMemberStatus {
  @JsonValue('active')
  active,
  @JsonValue('paused')
  paused,
  @JsonValue('invited')
  invited,
  @JsonValue('declined')
  declined,
}

@freezed
abstract class FixedGroupMember with _$FixedGroupMember {
  const factory FixedGroupMember({
    required String id,
    @JsonKey(name: 'fixed_group_id') required String fixedGroupId,
    @JsonKey(name: 'user_id') required String userId,
    @Default(FixedGroupMemberStatus.active) FixedGroupMemberStatus status,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    @JsonKey(name: 'paused_at') DateTime? pausedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _FixedGroupMember;

  factory FixedGroupMember.fromJson(Map<String, dynamic> json) =>
      _$FixedGroupMemberFromJson(json);
}

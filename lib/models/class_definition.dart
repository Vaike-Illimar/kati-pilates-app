import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_definition.freezed.dart';
part 'class_definition.g.dart';

enum ClassLevel {
  @JsonValue('algaja')
  algaja,
  @JsonValue('kesktase')
  kesktase,
  @JsonValue('koik')
  koik,
}

@freezed
abstract class ClassDefinition with _$ClassDefinition {
  const factory ClassDefinition({
    required String id,
    required String name,
    String? description,
    @Default(ClassLevel.koik) ClassLevel level,
    @JsonKey(name: 'duration_minutes') required int durationMinutes,
    @JsonKey(name: 'max_participants') required int maxParticipants,
    @JsonKey(name: 'studio_id') String? studioId,
    @JsonKey(name: 'instructor_id') String? instructorId,
    @JsonKey(name: 'day_of_week') required int dayOfWeek,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ClassDefinition;

  factory ClassDefinition.fromJson(Map<String, dynamic> json) =>
      _$ClassDefinitionFromJson(json);
}

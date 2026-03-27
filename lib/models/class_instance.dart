import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_instance.freezed.dart';
part 'class_instance.g.dart';

@freezed
abstract class ClassInstance with _$ClassInstance {
  const factory ClassInstance({
    required String id,
    @JsonKey(name: 'class_definition_id') required String classDefinitionId,
    required DateTime date,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
    @JsonKey(name: 'instructor_id') String? instructorId,
    @JsonKey(name: 'studio_id') String? studioId,
    @JsonKey(name: 'max_participants') required int maxParticipants,
    @JsonKey(name: 'is_cancelled') @Default(false) bool isCancelled,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ClassInstance;

  factory ClassInstance.fromJson(Map<String, dynamic> json) =>
      _$ClassInstanceFromJson(json);
}

/// Maps to the class_instances_with_counts database view.
class ClassInstanceWithDetails {
  final String id;
  final String classDefinitionId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String? instructorId;
  final String? studioId;
  final int maxParticipants;
  final bool isCancelled;
  final String? notes;
  final DateTime createdAt;
  final String? className;
  final String? classDescription;
  final String? level;
  final int? durationMinutes;
  final String? instructorName;
  final String? studioName;
  final int confirmedCount;
  final int waitlistCount;
  final int availableSpots;

  const ClassInstanceWithDetails({
    required this.id,
    required this.classDefinitionId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.instructorId,
    this.studioId,
    required this.maxParticipants,
    this.isCancelled = false,
    this.notes,
    required this.createdAt,
    this.className,
    this.classDescription,
    this.level,
    this.durationMinutes,
    this.instructorName,
    this.studioName,
    this.confirmedCount = 0,
    this.waitlistCount = 0,
    this.availableSpots = 0,
  });

  factory ClassInstanceWithDetails.fromJson(Map<String, dynamic> json) {
    return ClassInstanceWithDetails(
      id: json['id'] as String,
      classDefinitionId: json['class_definition_id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      instructorId: json['instructor_id'] as String?,
      studioId: json['studio_id'] as String?,
      maxParticipants: json['max_participants'] as int,
      isCancelled: json['is_cancelled'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      className: json['class_name'] as String?,
      classDescription: json['class_description'] as String?,
      level: json['level'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      instructorName: json['instructor_name'] as String?,
      studioName: json['studio_name'] as String?,
      confirmedCount: json['confirmed_count'] as int? ?? 0,
      waitlistCount: json['waitlist_count'] as int? ?? 0,
      availableSpots: json['available_spots'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_definition_id': classDefinitionId,
      'date': date.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'instructor_id': instructorId,
      'studio_id': studioId,
      'max_participants': maxParticipants,
      'is_cancelled': isCancelled,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'class_name': className,
      'class_description': classDescription,
      'level': level,
      'duration_minutes': durationMinutes,
      'instructor_name': instructorName,
      'studio_name': studioName,
      'confirmed_count': confirmedCount,
      'waitlist_count': waitlistCount,
      'available_spots': availableSpots,
    };
  }
}

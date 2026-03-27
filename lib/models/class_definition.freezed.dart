// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'class_definition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClassDefinition {

 String get id; String get name; String? get description; ClassLevel get level;@JsonKey(name: 'duration_minutes') int get durationMinutes;@JsonKey(name: 'max_participants') int get maxParticipants;@JsonKey(name: 'studio_id') String? get studioId;@JsonKey(name: 'instructor_id') String? get instructorId;@JsonKey(name: 'day_of_week') int get dayOfWeek;@JsonKey(name: 'start_time') String get startTime;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of ClassDefinition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassDefinitionCopyWith<ClassDefinition> get copyWith => _$ClassDefinitionCopyWithImpl<ClassDefinition>(this as ClassDefinition, _$identity);

  /// Serializes this ClassDefinition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassDefinition&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.level, level) || other.level == level)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.studioId, studioId) || other.studioId == studioId)&&(identical(other.instructorId, instructorId) || other.instructorId == instructorId)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,level,durationMinutes,maxParticipants,studioId,instructorId,dayOfWeek,startTime,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'ClassDefinition(id: $id, name: $name, description: $description, level: $level, durationMinutes: $durationMinutes, maxParticipants: $maxParticipants, studioId: $studioId, instructorId: $instructorId, dayOfWeek: $dayOfWeek, startTime: $startTime, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ClassDefinitionCopyWith<$Res>  {
  factory $ClassDefinitionCopyWith(ClassDefinition value, $Res Function(ClassDefinition) _then) = _$ClassDefinitionCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, ClassLevel level,@JsonKey(name: 'duration_minutes') int durationMinutes,@JsonKey(name: 'max_participants') int maxParticipants,@JsonKey(name: 'studio_id') String? studioId,@JsonKey(name: 'instructor_id') String? instructorId,@JsonKey(name: 'day_of_week') int dayOfWeek,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$ClassDefinitionCopyWithImpl<$Res>
    implements $ClassDefinitionCopyWith<$Res> {
  _$ClassDefinitionCopyWithImpl(this._self, this._then);

  final ClassDefinition _self;
  final $Res Function(ClassDefinition) _then;

/// Create a copy of ClassDefinition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? level = null,Object? durationMinutes = null,Object? maxParticipants = null,Object? studioId = freezed,Object? instructorId = freezed,Object? dayOfWeek = null,Object? startTime = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as ClassLevel,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,studioId: freezed == studioId ? _self.studioId : studioId // ignore: cast_nullable_to_non_nullable
as String?,instructorId: freezed == instructorId ? _self.instructorId : instructorId // ignore: cast_nullable_to_non_nullable
as String?,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassDefinition].
extension ClassDefinitionPatterns on ClassDefinition {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassDefinition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassDefinition() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassDefinition value)  $default,){
final _that = this;
switch (_that) {
case _ClassDefinition():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassDefinition value)?  $default,){
final _that = this;
switch (_that) {
case _ClassDefinition() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  ClassLevel level, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'max_participants')  int maxParticipants, @JsonKey(name: 'studio_id')  String? studioId, @JsonKey(name: 'instructor_id')  String? instructorId, @JsonKey(name: 'day_of_week')  int dayOfWeek, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassDefinition() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.level,_that.durationMinutes,_that.maxParticipants,_that.studioId,_that.instructorId,_that.dayOfWeek,_that.startTime,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  ClassLevel level, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'max_participants')  int maxParticipants, @JsonKey(name: 'studio_id')  String? studioId, @JsonKey(name: 'instructor_id')  String? instructorId, @JsonKey(name: 'day_of_week')  int dayOfWeek, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ClassDefinition():
return $default(_that.id,_that.name,_that.description,_that.level,_that.durationMinutes,_that.maxParticipants,_that.studioId,_that.instructorId,_that.dayOfWeek,_that.startTime,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  ClassLevel level, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'max_participants')  int maxParticipants, @JsonKey(name: 'studio_id')  String? studioId, @JsonKey(name: 'instructor_id')  String? instructorId, @JsonKey(name: 'day_of_week')  int dayOfWeek, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ClassDefinition() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.level,_that.durationMinutes,_that.maxParticipants,_that.studioId,_that.instructorId,_that.dayOfWeek,_that.startTime,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassDefinition implements ClassDefinition {
  const _ClassDefinition({required this.id, required this.name, this.description, this.level = ClassLevel.koik, @JsonKey(name: 'duration_minutes') required this.durationMinutes, @JsonKey(name: 'max_participants') required this.maxParticipants, @JsonKey(name: 'studio_id') this.studioId, @JsonKey(name: 'instructor_id') this.instructorId, @JsonKey(name: 'day_of_week') required this.dayOfWeek, @JsonKey(name: 'start_time') required this.startTime, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _ClassDefinition.fromJson(Map<String, dynamic> json) => _$ClassDefinitionFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  ClassLevel level;
@override@JsonKey(name: 'duration_minutes') final  int durationMinutes;
@override@JsonKey(name: 'max_participants') final  int maxParticipants;
@override@JsonKey(name: 'studio_id') final  String? studioId;
@override@JsonKey(name: 'instructor_id') final  String? instructorId;
@override@JsonKey(name: 'day_of_week') final  int dayOfWeek;
@override@JsonKey(name: 'start_time') final  String startTime;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of ClassDefinition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassDefinitionCopyWith<_ClassDefinition> get copyWith => __$ClassDefinitionCopyWithImpl<_ClassDefinition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassDefinitionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassDefinition&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.level, level) || other.level == level)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.studioId, studioId) || other.studioId == studioId)&&(identical(other.instructorId, instructorId) || other.instructorId == instructorId)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,level,durationMinutes,maxParticipants,studioId,instructorId,dayOfWeek,startTime,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'ClassDefinition(id: $id, name: $name, description: $description, level: $level, durationMinutes: $durationMinutes, maxParticipants: $maxParticipants, studioId: $studioId, instructorId: $instructorId, dayOfWeek: $dayOfWeek, startTime: $startTime, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ClassDefinitionCopyWith<$Res> implements $ClassDefinitionCopyWith<$Res> {
  factory _$ClassDefinitionCopyWith(_ClassDefinition value, $Res Function(_ClassDefinition) _then) = __$ClassDefinitionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, ClassLevel level,@JsonKey(name: 'duration_minutes') int durationMinutes,@JsonKey(name: 'max_participants') int maxParticipants,@JsonKey(name: 'studio_id') String? studioId,@JsonKey(name: 'instructor_id') String? instructorId,@JsonKey(name: 'day_of_week') int dayOfWeek,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$ClassDefinitionCopyWithImpl<$Res>
    implements _$ClassDefinitionCopyWith<$Res> {
  __$ClassDefinitionCopyWithImpl(this._self, this._then);

  final _ClassDefinition _self;
  final $Res Function(_ClassDefinition) _then;

/// Create a copy of ClassDefinition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? level = null,Object? durationMinutes = null,Object? maxParticipants = null,Object? studioId = freezed,Object? instructorId = freezed,Object? dayOfWeek = null,Object? startTime = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ClassDefinition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as ClassLevel,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,studioId: freezed == studioId ? _self.studioId : studioId // ignore: cast_nullable_to_non_nullable
as String?,instructorId: freezed == instructorId ? _self.instructorId : instructorId // ignore: cast_nullable_to_non_nullable
as String?,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

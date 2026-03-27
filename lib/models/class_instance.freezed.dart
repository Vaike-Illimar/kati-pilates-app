// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'class_instance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClassInstance {

 String get id;@JsonKey(name: 'class_definition_id') String get classDefinitionId; DateTime get date;@JsonKey(name: 'start_time') String get startTime;@JsonKey(name: 'end_time') String get endTime;@JsonKey(name: 'instructor_id') String? get instructorId;@JsonKey(name: 'studio_id') String? get studioId;@JsonKey(name: 'max_participants') int get maxParticipants;@JsonKey(name: 'is_cancelled') bool get isCancelled; String? get notes;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of ClassInstance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassInstanceCopyWith<ClassInstance> get copyWith => _$ClassInstanceCopyWithImpl<ClassInstance>(this as ClassInstance, _$identity);

  /// Serializes this ClassInstance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassInstance&&(identical(other.id, id) || other.id == id)&&(identical(other.classDefinitionId, classDefinitionId) || other.classDefinitionId == classDefinitionId)&&(identical(other.date, date) || other.date == date)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.instructorId, instructorId) || other.instructorId == instructorId)&&(identical(other.studioId, studioId) || other.studioId == studioId)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.isCancelled, isCancelled) || other.isCancelled == isCancelled)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,classDefinitionId,date,startTime,endTime,instructorId,studioId,maxParticipants,isCancelled,notes,createdAt);

@override
String toString() {
  return 'ClassInstance(id: $id, classDefinitionId: $classDefinitionId, date: $date, startTime: $startTime, endTime: $endTime, instructorId: $instructorId, studioId: $studioId, maxParticipants: $maxParticipants, isCancelled: $isCancelled, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ClassInstanceCopyWith<$Res>  {
  factory $ClassInstanceCopyWith(ClassInstance value, $Res Function(ClassInstance) _then) = _$ClassInstanceCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'class_definition_id') String classDefinitionId, DateTime date,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'end_time') String endTime,@JsonKey(name: 'instructor_id') String? instructorId,@JsonKey(name: 'studio_id') String? studioId,@JsonKey(name: 'max_participants') int maxParticipants,@JsonKey(name: 'is_cancelled') bool isCancelled, String? notes,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$ClassInstanceCopyWithImpl<$Res>
    implements $ClassInstanceCopyWith<$Res> {
  _$ClassInstanceCopyWithImpl(this._self, this._then);

  final ClassInstance _self;
  final $Res Function(ClassInstance) _then;

/// Create a copy of ClassInstance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? classDefinitionId = null,Object? date = null,Object? startTime = null,Object? endTime = null,Object? instructorId = freezed,Object? studioId = freezed,Object? maxParticipants = null,Object? isCancelled = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,classDefinitionId: null == classDefinitionId ? _self.classDefinitionId : classDefinitionId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,instructorId: freezed == instructorId ? _self.instructorId : instructorId // ignore: cast_nullable_to_non_nullable
as String?,studioId: freezed == studioId ? _self.studioId : studioId // ignore: cast_nullable_to_non_nullable
as String?,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,isCancelled: null == isCancelled ? _self.isCancelled : isCancelled // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassInstance].
extension ClassInstancePatterns on ClassInstance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassInstance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassInstance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassInstance value)  $default,){
final _that = this;
switch (_that) {
case _ClassInstance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassInstance value)?  $default,){
final _that = this;
switch (_that) {
case _ClassInstance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'class_definition_id')  String classDefinitionId,  DateTime date, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime, @JsonKey(name: 'instructor_id')  String? instructorId, @JsonKey(name: 'studio_id')  String? studioId, @JsonKey(name: 'max_participants')  int maxParticipants, @JsonKey(name: 'is_cancelled')  bool isCancelled,  String? notes, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassInstance() when $default != null:
return $default(_that.id,_that.classDefinitionId,_that.date,_that.startTime,_that.endTime,_that.instructorId,_that.studioId,_that.maxParticipants,_that.isCancelled,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'class_definition_id')  String classDefinitionId,  DateTime date, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime, @JsonKey(name: 'instructor_id')  String? instructorId, @JsonKey(name: 'studio_id')  String? studioId, @JsonKey(name: 'max_participants')  int maxParticipants, @JsonKey(name: 'is_cancelled')  bool isCancelled,  String? notes, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ClassInstance():
return $default(_that.id,_that.classDefinitionId,_that.date,_that.startTime,_that.endTime,_that.instructorId,_that.studioId,_that.maxParticipants,_that.isCancelled,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'class_definition_id')  String classDefinitionId,  DateTime date, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime, @JsonKey(name: 'instructor_id')  String? instructorId, @JsonKey(name: 'studio_id')  String? studioId, @JsonKey(name: 'max_participants')  int maxParticipants, @JsonKey(name: 'is_cancelled')  bool isCancelled,  String? notes, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ClassInstance() when $default != null:
return $default(_that.id,_that.classDefinitionId,_that.date,_that.startTime,_that.endTime,_that.instructorId,_that.studioId,_that.maxParticipants,_that.isCancelled,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassInstance implements ClassInstance {
  const _ClassInstance({required this.id, @JsonKey(name: 'class_definition_id') required this.classDefinitionId, required this.date, @JsonKey(name: 'start_time') required this.startTime, @JsonKey(name: 'end_time') required this.endTime, @JsonKey(name: 'instructor_id') this.instructorId, @JsonKey(name: 'studio_id') this.studioId, @JsonKey(name: 'max_participants') required this.maxParticipants, @JsonKey(name: 'is_cancelled') this.isCancelled = false, this.notes, @JsonKey(name: 'created_at') required this.createdAt});
  factory _ClassInstance.fromJson(Map<String, dynamic> json) => _$ClassInstanceFromJson(json);

@override final  String id;
@override@JsonKey(name: 'class_definition_id') final  String classDefinitionId;
@override final  DateTime date;
@override@JsonKey(name: 'start_time') final  String startTime;
@override@JsonKey(name: 'end_time') final  String endTime;
@override@JsonKey(name: 'instructor_id') final  String? instructorId;
@override@JsonKey(name: 'studio_id') final  String? studioId;
@override@JsonKey(name: 'max_participants') final  int maxParticipants;
@override@JsonKey(name: 'is_cancelled') final  bool isCancelled;
@override final  String? notes;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of ClassInstance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassInstanceCopyWith<_ClassInstance> get copyWith => __$ClassInstanceCopyWithImpl<_ClassInstance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassInstanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassInstance&&(identical(other.id, id) || other.id == id)&&(identical(other.classDefinitionId, classDefinitionId) || other.classDefinitionId == classDefinitionId)&&(identical(other.date, date) || other.date == date)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.instructorId, instructorId) || other.instructorId == instructorId)&&(identical(other.studioId, studioId) || other.studioId == studioId)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.isCancelled, isCancelled) || other.isCancelled == isCancelled)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,classDefinitionId,date,startTime,endTime,instructorId,studioId,maxParticipants,isCancelled,notes,createdAt);

@override
String toString() {
  return 'ClassInstance(id: $id, classDefinitionId: $classDefinitionId, date: $date, startTime: $startTime, endTime: $endTime, instructorId: $instructorId, studioId: $studioId, maxParticipants: $maxParticipants, isCancelled: $isCancelled, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ClassInstanceCopyWith<$Res> implements $ClassInstanceCopyWith<$Res> {
  factory _$ClassInstanceCopyWith(_ClassInstance value, $Res Function(_ClassInstance) _then) = __$ClassInstanceCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'class_definition_id') String classDefinitionId, DateTime date,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'end_time') String endTime,@JsonKey(name: 'instructor_id') String? instructorId,@JsonKey(name: 'studio_id') String? studioId,@JsonKey(name: 'max_participants') int maxParticipants,@JsonKey(name: 'is_cancelled') bool isCancelled, String? notes,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$ClassInstanceCopyWithImpl<$Res>
    implements _$ClassInstanceCopyWith<$Res> {
  __$ClassInstanceCopyWithImpl(this._self, this._then);

  final _ClassInstance _self;
  final $Res Function(_ClassInstance) _then;

/// Create a copy of ClassInstance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? classDefinitionId = null,Object? date = null,Object? startTime = null,Object? endTime = null,Object? instructorId = freezed,Object? studioId = freezed,Object? maxParticipants = null,Object? isCancelled = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_ClassInstance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,classDefinitionId: null == classDefinitionId ? _self.classDefinitionId : classDefinitionId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,instructorId: freezed == instructorId ? _self.instructorId : instructorId // ignore: cast_nullable_to_non_nullable
as String?,studioId: freezed == studioId ? _self.studioId : studioId // ignore: cast_nullable_to_non_nullable
as String?,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,isCancelled: null == isCancelled ? _self.isCancelled : isCancelled // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

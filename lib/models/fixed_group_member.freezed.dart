// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fixed_group_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FixedGroupMember {

 String get id;@JsonKey(name: 'fixed_group_id') String get fixedGroupId;@JsonKey(name: 'user_id') String get userId; FixedGroupMemberStatus get status;@JsonKey(name: 'joined_at') DateTime? get joinedAt;@JsonKey(name: 'paused_at') DateTime? get pausedAt;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of FixedGroupMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FixedGroupMemberCopyWith<FixedGroupMember> get copyWith => _$FixedGroupMemberCopyWithImpl<FixedGroupMember>(this as FixedGroupMember, _$identity);

  /// Serializes this FixedGroupMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FixedGroupMember&&(identical(other.id, id) || other.id == id)&&(identical(other.fixedGroupId, fixedGroupId) || other.fixedGroupId == fixedGroupId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.pausedAt, pausedAt) || other.pausedAt == pausedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fixedGroupId,userId,status,joinedAt,pausedAt,createdAt);

@override
String toString() {
  return 'FixedGroupMember(id: $id, fixedGroupId: $fixedGroupId, userId: $userId, status: $status, joinedAt: $joinedAt, pausedAt: $pausedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FixedGroupMemberCopyWith<$Res>  {
  factory $FixedGroupMemberCopyWith(FixedGroupMember value, $Res Function(FixedGroupMember) _then) = _$FixedGroupMemberCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'fixed_group_id') String fixedGroupId,@JsonKey(name: 'user_id') String userId, FixedGroupMemberStatus status,@JsonKey(name: 'joined_at') DateTime? joinedAt,@JsonKey(name: 'paused_at') DateTime? pausedAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$FixedGroupMemberCopyWithImpl<$Res>
    implements $FixedGroupMemberCopyWith<$Res> {
  _$FixedGroupMemberCopyWithImpl(this._self, this._then);

  final FixedGroupMember _self;
  final $Res Function(FixedGroupMember) _then;

/// Create a copy of FixedGroupMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fixedGroupId = null,Object? userId = null,Object? status = null,Object? joinedAt = freezed,Object? pausedAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fixedGroupId: null == fixedGroupId ? _self.fixedGroupId : fixedGroupId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FixedGroupMemberStatus,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pausedAt: freezed == pausedAt ? _self.pausedAt : pausedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FixedGroupMember].
extension FixedGroupMemberPatterns on FixedGroupMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FixedGroupMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FixedGroupMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FixedGroupMember value)  $default,){
final _that = this;
switch (_that) {
case _FixedGroupMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FixedGroupMember value)?  $default,){
final _that = this;
switch (_that) {
case _FixedGroupMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'fixed_group_id')  String fixedGroupId, @JsonKey(name: 'user_id')  String userId,  FixedGroupMemberStatus status, @JsonKey(name: 'joined_at')  DateTime? joinedAt, @JsonKey(name: 'paused_at')  DateTime? pausedAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FixedGroupMember() when $default != null:
return $default(_that.id,_that.fixedGroupId,_that.userId,_that.status,_that.joinedAt,_that.pausedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'fixed_group_id')  String fixedGroupId, @JsonKey(name: 'user_id')  String userId,  FixedGroupMemberStatus status, @JsonKey(name: 'joined_at')  DateTime? joinedAt, @JsonKey(name: 'paused_at')  DateTime? pausedAt, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _FixedGroupMember():
return $default(_that.id,_that.fixedGroupId,_that.userId,_that.status,_that.joinedAt,_that.pausedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'fixed_group_id')  String fixedGroupId, @JsonKey(name: 'user_id')  String userId,  FixedGroupMemberStatus status, @JsonKey(name: 'joined_at')  DateTime? joinedAt, @JsonKey(name: 'paused_at')  DateTime? pausedAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FixedGroupMember() when $default != null:
return $default(_that.id,_that.fixedGroupId,_that.userId,_that.status,_that.joinedAt,_that.pausedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FixedGroupMember implements FixedGroupMember {
  const _FixedGroupMember({required this.id, @JsonKey(name: 'fixed_group_id') required this.fixedGroupId, @JsonKey(name: 'user_id') required this.userId, this.status = FixedGroupMemberStatus.active, @JsonKey(name: 'joined_at') this.joinedAt, @JsonKey(name: 'paused_at') this.pausedAt, @JsonKey(name: 'created_at') required this.createdAt});
  factory _FixedGroupMember.fromJson(Map<String, dynamic> json) => _$FixedGroupMemberFromJson(json);

@override final  String id;
@override@JsonKey(name: 'fixed_group_id') final  String fixedGroupId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey() final  FixedGroupMemberStatus status;
@override@JsonKey(name: 'joined_at') final  DateTime? joinedAt;
@override@JsonKey(name: 'paused_at') final  DateTime? pausedAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of FixedGroupMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FixedGroupMemberCopyWith<_FixedGroupMember> get copyWith => __$FixedGroupMemberCopyWithImpl<_FixedGroupMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FixedGroupMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FixedGroupMember&&(identical(other.id, id) || other.id == id)&&(identical(other.fixedGroupId, fixedGroupId) || other.fixedGroupId == fixedGroupId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.pausedAt, pausedAt) || other.pausedAt == pausedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fixedGroupId,userId,status,joinedAt,pausedAt,createdAt);

@override
String toString() {
  return 'FixedGroupMember(id: $id, fixedGroupId: $fixedGroupId, userId: $userId, status: $status, joinedAt: $joinedAt, pausedAt: $pausedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FixedGroupMemberCopyWith<$Res> implements $FixedGroupMemberCopyWith<$Res> {
  factory _$FixedGroupMemberCopyWith(_FixedGroupMember value, $Res Function(_FixedGroupMember) _then) = __$FixedGroupMemberCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'fixed_group_id') String fixedGroupId,@JsonKey(name: 'user_id') String userId, FixedGroupMemberStatus status,@JsonKey(name: 'joined_at') DateTime? joinedAt,@JsonKey(name: 'paused_at') DateTime? pausedAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$FixedGroupMemberCopyWithImpl<$Res>
    implements _$FixedGroupMemberCopyWith<$Res> {
  __$FixedGroupMemberCopyWithImpl(this._self, this._then);

  final _FixedGroupMember _self;
  final $Res Function(_FixedGroupMember) _then;

/// Create a copy of FixedGroupMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fixedGroupId = null,Object? userId = null,Object? status = null,Object? joinedAt = freezed,Object? pausedAt = freezed,Object? createdAt = null,}) {
  return _then(_FixedGroupMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fixedGroupId: null == fixedGroupId ? _self.fixedGroupId : fixedGroupId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FixedGroupMemberStatus,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pausedAt: freezed == pausedAt ? _self.pausedAt : pausedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

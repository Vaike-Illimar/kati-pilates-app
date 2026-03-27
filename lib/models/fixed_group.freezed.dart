// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fixed_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FixedGroup {

 String get id;@JsonKey(name: 'class_definition_id') String get classDefinitionId; String get name;@JsonKey(name: 'max_members') int get maxMembers;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of FixedGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FixedGroupCopyWith<FixedGroup> get copyWith => _$FixedGroupCopyWithImpl<FixedGroup>(this as FixedGroup, _$identity);

  /// Serializes this FixedGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FixedGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.classDefinitionId, classDefinitionId) || other.classDefinitionId == classDefinitionId)&&(identical(other.name, name) || other.name == name)&&(identical(other.maxMembers, maxMembers) || other.maxMembers == maxMembers)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,classDefinitionId,name,maxMembers,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'FixedGroup(id: $id, classDefinitionId: $classDefinitionId, name: $name, maxMembers: $maxMembers, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FixedGroupCopyWith<$Res>  {
  factory $FixedGroupCopyWith(FixedGroup value, $Res Function(FixedGroup) _then) = _$FixedGroupCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'class_definition_id') String classDefinitionId, String name,@JsonKey(name: 'max_members') int maxMembers,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$FixedGroupCopyWithImpl<$Res>
    implements $FixedGroupCopyWith<$Res> {
  _$FixedGroupCopyWithImpl(this._self, this._then);

  final FixedGroup _self;
  final $Res Function(FixedGroup) _then;

/// Create a copy of FixedGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? classDefinitionId = null,Object? name = null,Object? maxMembers = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,classDefinitionId: null == classDefinitionId ? _self.classDefinitionId : classDefinitionId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,maxMembers: null == maxMembers ? _self.maxMembers : maxMembers // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FixedGroup].
extension FixedGroupPatterns on FixedGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FixedGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FixedGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FixedGroup value)  $default,){
final _that = this;
switch (_that) {
case _FixedGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FixedGroup value)?  $default,){
final _that = this;
switch (_that) {
case _FixedGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'class_definition_id')  String classDefinitionId,  String name, @JsonKey(name: 'max_members')  int maxMembers, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FixedGroup() when $default != null:
return $default(_that.id,_that.classDefinitionId,_that.name,_that.maxMembers,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'class_definition_id')  String classDefinitionId,  String name, @JsonKey(name: 'max_members')  int maxMembers, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FixedGroup():
return $default(_that.id,_that.classDefinitionId,_that.name,_that.maxMembers,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'class_definition_id')  String classDefinitionId,  String name, @JsonKey(name: 'max_members')  int maxMembers, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FixedGroup() when $default != null:
return $default(_that.id,_that.classDefinitionId,_that.name,_that.maxMembers,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FixedGroup implements FixedGroup {
  const _FixedGroup({required this.id, @JsonKey(name: 'class_definition_id') required this.classDefinitionId, required this.name, @JsonKey(name: 'max_members') required this.maxMembers, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _FixedGroup.fromJson(Map<String, dynamic> json) => _$FixedGroupFromJson(json);

@override final  String id;
@override@JsonKey(name: 'class_definition_id') final  String classDefinitionId;
@override final  String name;
@override@JsonKey(name: 'max_members') final  int maxMembers;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of FixedGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FixedGroupCopyWith<_FixedGroup> get copyWith => __$FixedGroupCopyWithImpl<_FixedGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FixedGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FixedGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.classDefinitionId, classDefinitionId) || other.classDefinitionId == classDefinitionId)&&(identical(other.name, name) || other.name == name)&&(identical(other.maxMembers, maxMembers) || other.maxMembers == maxMembers)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,classDefinitionId,name,maxMembers,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'FixedGroup(id: $id, classDefinitionId: $classDefinitionId, name: $name, maxMembers: $maxMembers, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FixedGroupCopyWith<$Res> implements $FixedGroupCopyWith<$Res> {
  factory _$FixedGroupCopyWith(_FixedGroup value, $Res Function(_FixedGroup) _then) = __$FixedGroupCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'class_definition_id') String classDefinitionId, String name,@JsonKey(name: 'max_members') int maxMembers,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$FixedGroupCopyWithImpl<$Res>
    implements _$FixedGroupCopyWith<$Res> {
  __$FixedGroupCopyWithImpl(this._self, this._then);

  final _FixedGroup _self;
  final $Res Function(_FixedGroup) _then;

/// Create a copy of FixedGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? classDefinitionId = null,Object? name = null,Object? maxMembers = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FixedGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,classDefinitionId: null == classDefinitionId ? _self.classDefinitionId : classDefinitionId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,maxMembers: null == maxMembers ? _self.maxMembers : maxMembers // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

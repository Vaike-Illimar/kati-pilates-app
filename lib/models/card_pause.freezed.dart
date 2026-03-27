// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_pause.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CardPause {

 String get id;@JsonKey(name: 'card_id') String get cardId; PauseReason get reason;@JsonKey(name: 'start_date') DateTime get startDate;@JsonKey(name: 'end_date') DateTime get endDate; String? get notes;@JsonKey(name: 'extension_days') int get extensionDays;@JsonKey(name: 'created_by') String get createdBy;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of CardPause
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardPauseCopyWith<CardPause> get copyWith => _$CardPauseCopyWithImpl<CardPause>(this as CardPause, _$identity);

  /// Serializes this CardPause to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardPause&&(identical(other.id, id) || other.id == id)&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.extensionDays, extensionDays) || other.extensionDays == extensionDays)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cardId,reason,startDate,endDate,notes,extensionDays,createdBy,createdAt);

@override
String toString() {
  return 'CardPause(id: $id, cardId: $cardId, reason: $reason, startDate: $startDate, endDate: $endDate, notes: $notes, extensionDays: $extensionDays, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CardPauseCopyWith<$Res>  {
  factory $CardPauseCopyWith(CardPause value, $Res Function(CardPause) _then) = _$CardPauseCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'card_id') String cardId, PauseReason reason,@JsonKey(name: 'start_date') DateTime startDate,@JsonKey(name: 'end_date') DateTime endDate, String? notes,@JsonKey(name: 'extension_days') int extensionDays,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$CardPauseCopyWithImpl<$Res>
    implements $CardPauseCopyWith<$Res> {
  _$CardPauseCopyWithImpl(this._self, this._then);

  final CardPause _self;
  final $Res Function(CardPause) _then;

/// Create a copy of CardPause
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cardId = null,Object? reason = null,Object? startDate = null,Object? endDate = null,Object? notes = freezed,Object? extensionDays = null,Object? createdBy = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as PauseReason,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,extensionDays: null == extensionDays ? _self.extensionDays : extensionDays // ignore: cast_nullable_to_non_nullable
as int,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CardPause].
extension CardPausePatterns on CardPause {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardPause value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardPause() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardPause value)  $default,){
final _that = this;
switch (_that) {
case _CardPause():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardPause value)?  $default,){
final _that = this;
switch (_that) {
case _CardPause() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'card_id')  String cardId,  PauseReason reason, @JsonKey(name: 'start_date')  DateTime startDate, @JsonKey(name: 'end_date')  DateTime endDate,  String? notes, @JsonKey(name: 'extension_days')  int extensionDays, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardPause() when $default != null:
return $default(_that.id,_that.cardId,_that.reason,_that.startDate,_that.endDate,_that.notes,_that.extensionDays,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'card_id')  String cardId,  PauseReason reason, @JsonKey(name: 'start_date')  DateTime startDate, @JsonKey(name: 'end_date')  DateTime endDate,  String? notes, @JsonKey(name: 'extension_days')  int extensionDays, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _CardPause():
return $default(_that.id,_that.cardId,_that.reason,_that.startDate,_that.endDate,_that.notes,_that.extensionDays,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'card_id')  String cardId,  PauseReason reason, @JsonKey(name: 'start_date')  DateTime startDate, @JsonKey(name: 'end_date')  DateTime endDate,  String? notes, @JsonKey(name: 'extension_days')  int extensionDays, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CardPause() when $default != null:
return $default(_that.id,_that.cardId,_that.reason,_that.startDate,_that.endDate,_that.notes,_that.extensionDays,_that.createdBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardPause implements CardPause {
  const _CardPause({required this.id, @JsonKey(name: 'card_id') required this.cardId, required this.reason, @JsonKey(name: 'start_date') required this.startDate, @JsonKey(name: 'end_date') required this.endDate, this.notes, @JsonKey(name: 'extension_days') required this.extensionDays, @JsonKey(name: 'created_by') required this.createdBy, @JsonKey(name: 'created_at') required this.createdAt});
  factory _CardPause.fromJson(Map<String, dynamic> json) => _$CardPauseFromJson(json);

@override final  String id;
@override@JsonKey(name: 'card_id') final  String cardId;
@override final  PauseReason reason;
@override@JsonKey(name: 'start_date') final  DateTime startDate;
@override@JsonKey(name: 'end_date') final  DateTime endDate;
@override final  String? notes;
@override@JsonKey(name: 'extension_days') final  int extensionDays;
@override@JsonKey(name: 'created_by') final  String createdBy;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of CardPause
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardPauseCopyWith<_CardPause> get copyWith => __$CardPauseCopyWithImpl<_CardPause>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardPauseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardPause&&(identical(other.id, id) || other.id == id)&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.extensionDays, extensionDays) || other.extensionDays == extensionDays)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cardId,reason,startDate,endDate,notes,extensionDays,createdBy,createdAt);

@override
String toString() {
  return 'CardPause(id: $id, cardId: $cardId, reason: $reason, startDate: $startDate, endDate: $endDate, notes: $notes, extensionDays: $extensionDays, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CardPauseCopyWith<$Res> implements $CardPauseCopyWith<$Res> {
  factory _$CardPauseCopyWith(_CardPause value, $Res Function(_CardPause) _then) = __$CardPauseCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'card_id') String cardId, PauseReason reason,@JsonKey(name: 'start_date') DateTime startDate,@JsonKey(name: 'end_date') DateTime endDate, String? notes,@JsonKey(name: 'extension_days') int extensionDays,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$CardPauseCopyWithImpl<$Res>
    implements _$CardPauseCopyWith<$Res> {
  __$CardPauseCopyWithImpl(this._self, this._then);

  final _CardPause _self;
  final $Res Function(_CardPause) _then;

/// Create a copy of CardPause
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cardId = null,Object? reason = null,Object? startDate = null,Object? endDate = null,Object? notes = freezed,Object? extensionDays = null,Object? createdBy = null,Object? createdAt = null,}) {
  return _then(_CardPause(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as PauseReason,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,extensionDays: null == extensionDays ? _self.extensionDays : extensionDays // ignore: cast_nullable_to_non_nullable
as int,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Booking {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'class_instance_id') String get classInstanceId; BookingStatus get status;@JsonKey(name: 'waitlist_position') int? get waitlistPosition;@JsonKey(name: 'cancel_type') CancelType? get cancelType;@JsonKey(name: 'session_deducted') bool get sessionDeducted;@JsonKey(name: 'card_id') String? get cardId;@JsonKey(name: 'booked_at') DateTime get bookedAt;@JsonKey(name: 'cancelled_at') DateTime? get cancelledAt;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.classInstanceId, classInstanceId) || other.classInstanceId == classInstanceId)&&(identical(other.status, status) || other.status == status)&&(identical(other.waitlistPosition, waitlistPosition) || other.waitlistPosition == waitlistPosition)&&(identical(other.cancelType, cancelType) || other.cancelType == cancelType)&&(identical(other.sessionDeducted, sessionDeducted) || other.sessionDeducted == sessionDeducted)&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.bookedAt, bookedAt) || other.bookedAt == bookedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,classInstanceId,status,waitlistPosition,cancelType,sessionDeducted,cardId,bookedAt,cancelledAt,createdAt);

@override
String toString() {
  return 'Booking(id: $id, userId: $userId, classInstanceId: $classInstanceId, status: $status, waitlistPosition: $waitlistPosition, cancelType: $cancelType, sessionDeducted: $sessionDeducted, cardId: $cardId, bookedAt: $bookedAt, cancelledAt: $cancelledAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'class_instance_id') String classInstanceId, BookingStatus status,@JsonKey(name: 'waitlist_position') int? waitlistPosition,@JsonKey(name: 'cancel_type') CancelType? cancelType,@JsonKey(name: 'session_deducted') bool sessionDeducted,@JsonKey(name: 'card_id') String? cardId,@JsonKey(name: 'booked_at') DateTime bookedAt,@JsonKey(name: 'cancelled_at') DateTime? cancelledAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? classInstanceId = null,Object? status = null,Object? waitlistPosition = freezed,Object? cancelType = freezed,Object? sessionDeducted = null,Object? cardId = freezed,Object? bookedAt = null,Object? cancelledAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,classInstanceId: null == classInstanceId ? _self.classInstanceId : classInstanceId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,waitlistPosition: freezed == waitlistPosition ? _self.waitlistPosition : waitlistPosition // ignore: cast_nullable_to_non_nullable
as int?,cancelType: freezed == cancelType ? _self.cancelType : cancelType // ignore: cast_nullable_to_non_nullable
as CancelType?,sessionDeducted: null == sessionDeducted ? _self.sessionDeducted : sessionDeducted // ignore: cast_nullable_to_non_nullable
as bool,cardId: freezed == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String?,bookedAt: null == bookedAt ? _self.bookedAt : bookedAt // ignore: cast_nullable_to_non_nullable
as DateTime,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'class_instance_id')  String classInstanceId,  BookingStatus status, @JsonKey(name: 'waitlist_position')  int? waitlistPosition, @JsonKey(name: 'cancel_type')  CancelType? cancelType, @JsonKey(name: 'session_deducted')  bool sessionDeducted, @JsonKey(name: 'card_id')  String? cardId, @JsonKey(name: 'booked_at')  DateTime bookedAt, @JsonKey(name: 'cancelled_at')  DateTime? cancelledAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.userId,_that.classInstanceId,_that.status,_that.waitlistPosition,_that.cancelType,_that.sessionDeducted,_that.cardId,_that.bookedAt,_that.cancelledAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'class_instance_id')  String classInstanceId,  BookingStatus status, @JsonKey(name: 'waitlist_position')  int? waitlistPosition, @JsonKey(name: 'cancel_type')  CancelType? cancelType, @JsonKey(name: 'session_deducted')  bool sessionDeducted, @JsonKey(name: 'card_id')  String? cardId, @JsonKey(name: 'booked_at')  DateTime bookedAt, @JsonKey(name: 'cancelled_at')  DateTime? cancelledAt, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.userId,_that.classInstanceId,_that.status,_that.waitlistPosition,_that.cancelType,_that.sessionDeducted,_that.cardId,_that.bookedAt,_that.cancelledAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'class_instance_id')  String classInstanceId,  BookingStatus status, @JsonKey(name: 'waitlist_position')  int? waitlistPosition, @JsonKey(name: 'cancel_type')  CancelType? cancelType, @JsonKey(name: 'session_deducted')  bool sessionDeducted, @JsonKey(name: 'card_id')  String? cardId, @JsonKey(name: 'booked_at')  DateTime bookedAt, @JsonKey(name: 'cancelled_at')  DateTime? cancelledAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.userId,_that.classInstanceId,_that.status,_that.waitlistPosition,_that.cancelType,_that.sessionDeducted,_that.cardId,_that.bookedAt,_that.cancelledAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking implements Booking {
  const _Booking({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'class_instance_id') required this.classInstanceId, this.status = BookingStatus.confirmed, @JsonKey(name: 'waitlist_position') this.waitlistPosition, @JsonKey(name: 'cancel_type') this.cancelType, @JsonKey(name: 'session_deducted') this.sessionDeducted = false, @JsonKey(name: 'card_id') this.cardId, @JsonKey(name: 'booked_at') required this.bookedAt, @JsonKey(name: 'cancelled_at') this.cancelledAt, @JsonKey(name: 'created_at') required this.createdAt});
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'class_instance_id') final  String classInstanceId;
@override@JsonKey() final  BookingStatus status;
@override@JsonKey(name: 'waitlist_position') final  int? waitlistPosition;
@override@JsonKey(name: 'cancel_type') final  CancelType? cancelType;
@override@JsonKey(name: 'session_deducted') final  bool sessionDeducted;
@override@JsonKey(name: 'card_id') final  String? cardId;
@override@JsonKey(name: 'booked_at') final  DateTime bookedAt;
@override@JsonKey(name: 'cancelled_at') final  DateTime? cancelledAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.classInstanceId, classInstanceId) || other.classInstanceId == classInstanceId)&&(identical(other.status, status) || other.status == status)&&(identical(other.waitlistPosition, waitlistPosition) || other.waitlistPosition == waitlistPosition)&&(identical(other.cancelType, cancelType) || other.cancelType == cancelType)&&(identical(other.sessionDeducted, sessionDeducted) || other.sessionDeducted == sessionDeducted)&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.bookedAt, bookedAt) || other.bookedAt == bookedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,classInstanceId,status,waitlistPosition,cancelType,sessionDeducted,cardId,bookedAt,cancelledAt,createdAt);

@override
String toString() {
  return 'Booking(id: $id, userId: $userId, classInstanceId: $classInstanceId, status: $status, waitlistPosition: $waitlistPosition, cancelType: $cancelType, sessionDeducted: $sessionDeducted, cardId: $cardId, bookedAt: $bookedAt, cancelledAt: $cancelledAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'class_instance_id') String classInstanceId, BookingStatus status,@JsonKey(name: 'waitlist_position') int? waitlistPosition,@JsonKey(name: 'cancel_type') CancelType? cancelType,@JsonKey(name: 'session_deducted') bool sessionDeducted,@JsonKey(name: 'card_id') String? cardId,@JsonKey(name: 'booked_at') DateTime bookedAt,@JsonKey(name: 'cancelled_at') DateTime? cancelledAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? classInstanceId = null,Object? status = null,Object? waitlistPosition = freezed,Object? cancelType = freezed,Object? sessionDeducted = null,Object? cardId = freezed,Object? bookedAt = null,Object? cancelledAt = freezed,Object? createdAt = null,}) {
  return _then(_Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,classInstanceId: null == classInstanceId ? _self.classInstanceId : classInstanceId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,waitlistPosition: freezed == waitlistPosition ? _self.waitlistPosition : waitlistPosition // ignore: cast_nullable_to_non_nullable
as int?,cancelType: freezed == cancelType ? _self.cancelType : cancelType // ignore: cast_nullable_to_non_nullable
as CancelType?,sessionDeducted: null == sessionDeducted ? _self.sessionDeducted : sessionDeducted // ignore: cast_nullable_to_non_nullable
as bool,cardId: freezed == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String?,bookedAt: null == bookedAt ? _self.bookedAt : bookedAt // ignore: cast_nullable_to_non_nullable
as DateTime,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

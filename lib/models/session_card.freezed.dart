// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionCard {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'card_type') CardType get cardType;@JsonKey(name: 'total_sessions') int get totalSessions;@JsonKey(name: 'remaining_sessions') int get remainingSessions;@JsonKey(name: 'price_cents') int get priceCents;@JsonKey(name: 'valid_from') DateTime get validFrom;@JsonKey(name: 'valid_until') DateTime get validUntil;@JsonKey(name: 'original_valid_until') DateTime get originalValidUntil; CardStatus get status;@JsonKey(name: 'purchased_at') DateTime get purchasedAt;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of SessionCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionCardCopyWith<SessionCard> get copyWith => _$SessionCardCopyWithImpl<SessionCard>(this as SessionCard, _$identity);

  /// Serializes this SessionCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionCard&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.cardType, cardType) || other.cardType == cardType)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.remainingSessions, remainingSessions) || other.remainingSessions == remainingSessions)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.originalValidUntil, originalValidUntil) || other.originalValidUntil == originalValidUntil)&&(identical(other.status, status) || other.status == status)&&(identical(other.purchasedAt, purchasedAt) || other.purchasedAt == purchasedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,cardType,totalSessions,remainingSessions,priceCents,validFrom,validUntil,originalValidUntil,status,purchasedAt,createdAt,updatedAt);

@override
String toString() {
  return 'SessionCard(id: $id, userId: $userId, cardType: $cardType, totalSessions: $totalSessions, remainingSessions: $remainingSessions, priceCents: $priceCents, validFrom: $validFrom, validUntil: $validUntil, originalValidUntil: $originalValidUntil, status: $status, purchasedAt: $purchasedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SessionCardCopyWith<$Res>  {
  factory $SessionCardCopyWith(SessionCard value, $Res Function(SessionCard) _then) = _$SessionCardCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'card_type') CardType cardType,@JsonKey(name: 'total_sessions') int totalSessions,@JsonKey(name: 'remaining_sessions') int remainingSessions,@JsonKey(name: 'price_cents') int priceCents,@JsonKey(name: 'valid_from') DateTime validFrom,@JsonKey(name: 'valid_until') DateTime validUntil,@JsonKey(name: 'original_valid_until') DateTime originalValidUntil, CardStatus status,@JsonKey(name: 'purchased_at') DateTime purchasedAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$SessionCardCopyWithImpl<$Res>
    implements $SessionCardCopyWith<$Res> {
  _$SessionCardCopyWithImpl(this._self, this._then);

  final SessionCard _self;
  final $Res Function(SessionCard) _then;

/// Create a copy of SessionCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? cardType = null,Object? totalSessions = null,Object? remainingSessions = null,Object? priceCents = null,Object? validFrom = null,Object? validUntil = null,Object? originalValidUntil = null,Object? status = null,Object? purchasedAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as CardType,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,remainingSessions: null == remainingSessions ? _self.remainingSessions : remainingSessions // ignore: cast_nullable_to_non_nullable
as int,priceCents: null == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,originalValidUntil: null == originalValidUntil ? _self.originalValidUntil : originalValidUntil // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CardStatus,purchasedAt: null == purchasedAt ? _self.purchasedAt : purchasedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionCard].
extension SessionCardPatterns on SessionCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionCard value)  $default,){
final _that = this;
switch (_that) {
case _SessionCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionCard value)?  $default,){
final _that = this;
switch (_that) {
case _SessionCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'card_type')  CardType cardType, @JsonKey(name: 'total_sessions')  int totalSessions, @JsonKey(name: 'remaining_sessions')  int remainingSessions, @JsonKey(name: 'price_cents')  int priceCents, @JsonKey(name: 'valid_from')  DateTime validFrom, @JsonKey(name: 'valid_until')  DateTime validUntil, @JsonKey(name: 'original_valid_until')  DateTime originalValidUntil,  CardStatus status, @JsonKey(name: 'purchased_at')  DateTime purchasedAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionCard() when $default != null:
return $default(_that.id,_that.userId,_that.cardType,_that.totalSessions,_that.remainingSessions,_that.priceCents,_that.validFrom,_that.validUntil,_that.originalValidUntil,_that.status,_that.purchasedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'card_type')  CardType cardType, @JsonKey(name: 'total_sessions')  int totalSessions, @JsonKey(name: 'remaining_sessions')  int remainingSessions, @JsonKey(name: 'price_cents')  int priceCents, @JsonKey(name: 'valid_from')  DateTime validFrom, @JsonKey(name: 'valid_until')  DateTime validUntil, @JsonKey(name: 'original_valid_until')  DateTime originalValidUntil,  CardStatus status, @JsonKey(name: 'purchased_at')  DateTime purchasedAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SessionCard():
return $default(_that.id,_that.userId,_that.cardType,_that.totalSessions,_that.remainingSessions,_that.priceCents,_that.validFrom,_that.validUntil,_that.originalValidUntil,_that.status,_that.purchasedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'card_type')  CardType cardType, @JsonKey(name: 'total_sessions')  int totalSessions, @JsonKey(name: 'remaining_sessions')  int remainingSessions, @JsonKey(name: 'price_cents')  int priceCents, @JsonKey(name: 'valid_from')  DateTime validFrom, @JsonKey(name: 'valid_until')  DateTime validUntil, @JsonKey(name: 'original_valid_until')  DateTime originalValidUntil,  CardStatus status, @JsonKey(name: 'purchased_at')  DateTime purchasedAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SessionCard() when $default != null:
return $default(_that.id,_that.userId,_that.cardType,_that.totalSessions,_that.remainingSessions,_that.priceCents,_that.validFrom,_that.validUntil,_that.originalValidUntil,_that.status,_that.purchasedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionCard implements SessionCard {
  const _SessionCard({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'card_type') required this.cardType, @JsonKey(name: 'total_sessions') required this.totalSessions, @JsonKey(name: 'remaining_sessions') required this.remainingSessions, @JsonKey(name: 'price_cents') required this.priceCents, @JsonKey(name: 'valid_from') required this.validFrom, @JsonKey(name: 'valid_until') required this.validUntil, @JsonKey(name: 'original_valid_until') required this.originalValidUntil, this.status = CardStatus.active, @JsonKey(name: 'purchased_at') required this.purchasedAt, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _SessionCard.fromJson(Map<String, dynamic> json) => _$SessionCardFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'card_type') final  CardType cardType;
@override@JsonKey(name: 'total_sessions') final  int totalSessions;
@override@JsonKey(name: 'remaining_sessions') final  int remainingSessions;
@override@JsonKey(name: 'price_cents') final  int priceCents;
@override@JsonKey(name: 'valid_from') final  DateTime validFrom;
@override@JsonKey(name: 'valid_until') final  DateTime validUntil;
@override@JsonKey(name: 'original_valid_until') final  DateTime originalValidUntil;
@override@JsonKey() final  CardStatus status;
@override@JsonKey(name: 'purchased_at') final  DateTime purchasedAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of SessionCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionCardCopyWith<_SessionCard> get copyWith => __$SessionCardCopyWithImpl<_SessionCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionCard&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.cardType, cardType) || other.cardType == cardType)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.remainingSessions, remainingSessions) || other.remainingSessions == remainingSessions)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.originalValidUntil, originalValidUntil) || other.originalValidUntil == originalValidUntil)&&(identical(other.status, status) || other.status == status)&&(identical(other.purchasedAt, purchasedAt) || other.purchasedAt == purchasedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,cardType,totalSessions,remainingSessions,priceCents,validFrom,validUntil,originalValidUntil,status,purchasedAt,createdAt,updatedAt);

@override
String toString() {
  return 'SessionCard(id: $id, userId: $userId, cardType: $cardType, totalSessions: $totalSessions, remainingSessions: $remainingSessions, priceCents: $priceCents, validFrom: $validFrom, validUntil: $validUntil, originalValidUntil: $originalValidUntil, status: $status, purchasedAt: $purchasedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SessionCardCopyWith<$Res> implements $SessionCardCopyWith<$Res> {
  factory _$SessionCardCopyWith(_SessionCard value, $Res Function(_SessionCard) _then) = __$SessionCardCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'card_type') CardType cardType,@JsonKey(name: 'total_sessions') int totalSessions,@JsonKey(name: 'remaining_sessions') int remainingSessions,@JsonKey(name: 'price_cents') int priceCents,@JsonKey(name: 'valid_from') DateTime validFrom,@JsonKey(name: 'valid_until') DateTime validUntil,@JsonKey(name: 'original_valid_until') DateTime originalValidUntil, CardStatus status,@JsonKey(name: 'purchased_at') DateTime purchasedAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$SessionCardCopyWithImpl<$Res>
    implements _$SessionCardCopyWith<$Res> {
  __$SessionCardCopyWithImpl(this._self, this._then);

  final _SessionCard _self;
  final $Res Function(_SessionCard) _then;

/// Create a copy of SessionCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? cardType = null,Object? totalSessions = null,Object? remainingSessions = null,Object? priceCents = null,Object? validFrom = null,Object? validUntil = null,Object? originalValidUntil = null,Object? status = null,Object? purchasedAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SessionCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as CardType,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,remainingSessions: null == remainingSessions ? _self.remainingSessions : remainingSessions // ignore: cast_nullable_to_non_nullable
as int,priceCents: null == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,originalValidUntil: null == originalValidUntil ? _self.originalValidUntil : originalValidUntil // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CardStatus,purchasedAt: null == purchasedAt ? _self.purchasedAt : purchasedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

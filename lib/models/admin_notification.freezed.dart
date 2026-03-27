// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminNotification {

 String get id;@JsonKey(name: 'sender_id') String get senderId; String get subject; String get body;@JsonKey(name: 'notification_type') NotificationType get notificationType; NotificationStatus get status;@JsonKey(name: 'scheduled_at') DateTime? get scheduledAt;@JsonKey(name: 'sent_at') DateTime? get sentAt;@JsonKey(name: 'total_recipients') int get totalRecipients;@JsonKey(name: 'opened_count') int get openedCount;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of AdminNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminNotificationCopyWith<AdminNotification> get copyWith => _$AdminNotificationCopyWithImpl<AdminNotification>(this as AdminNotification, _$identity);

  /// Serializes this AdminNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body)&&(identical(other.notificationType, notificationType) || other.notificationType == notificationType)&&(identical(other.status, status) || other.status == status)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.totalRecipients, totalRecipients) || other.totalRecipients == totalRecipients)&&(identical(other.openedCount, openedCount) || other.openedCount == openedCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,subject,body,notificationType,status,scheduledAt,sentAt,totalRecipients,openedCount,createdAt);

@override
String toString() {
  return 'AdminNotification(id: $id, senderId: $senderId, subject: $subject, body: $body, notificationType: $notificationType, status: $status, scheduledAt: $scheduledAt, sentAt: $sentAt, totalRecipients: $totalRecipients, openedCount: $openedCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AdminNotificationCopyWith<$Res>  {
  factory $AdminNotificationCopyWith(AdminNotification value, $Res Function(AdminNotification) _then) = _$AdminNotificationCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'sender_id') String senderId, String subject, String body,@JsonKey(name: 'notification_type') NotificationType notificationType, NotificationStatus status,@JsonKey(name: 'scheduled_at') DateTime? scheduledAt,@JsonKey(name: 'sent_at') DateTime? sentAt,@JsonKey(name: 'total_recipients') int totalRecipients,@JsonKey(name: 'opened_count') int openedCount,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$AdminNotificationCopyWithImpl<$Res>
    implements $AdminNotificationCopyWith<$Res> {
  _$AdminNotificationCopyWithImpl(this._self, this._then);

  final AdminNotification _self;
  final $Res Function(AdminNotification) _then;

/// Create a copy of AdminNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderId = null,Object? subject = null,Object? body = null,Object? notificationType = null,Object? status = null,Object? scheduledAt = freezed,Object? sentAt = freezed,Object? totalRecipients = null,Object? openedCount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,notificationType: null == notificationType ? _self.notificationType : notificationType // ignore: cast_nullable_to_non_nullable
as NotificationType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NotificationStatus,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,totalRecipients: null == totalRecipients ? _self.totalRecipients : totalRecipients // ignore: cast_nullable_to_non_nullable
as int,openedCount: null == openedCount ? _self.openedCount : openedCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminNotification].
extension AdminNotificationPatterns on AdminNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminNotification value)  $default,){
final _that = this;
switch (_that) {
case _AdminNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminNotification value)?  $default,){
final _that = this;
switch (_that) {
case _AdminNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'sender_id')  String senderId,  String subject,  String body, @JsonKey(name: 'notification_type')  NotificationType notificationType,  NotificationStatus status, @JsonKey(name: 'scheduled_at')  DateTime? scheduledAt, @JsonKey(name: 'sent_at')  DateTime? sentAt, @JsonKey(name: 'total_recipients')  int totalRecipients, @JsonKey(name: 'opened_count')  int openedCount, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminNotification() when $default != null:
return $default(_that.id,_that.senderId,_that.subject,_that.body,_that.notificationType,_that.status,_that.scheduledAt,_that.sentAt,_that.totalRecipients,_that.openedCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'sender_id')  String senderId,  String subject,  String body, @JsonKey(name: 'notification_type')  NotificationType notificationType,  NotificationStatus status, @JsonKey(name: 'scheduled_at')  DateTime? scheduledAt, @JsonKey(name: 'sent_at')  DateTime? sentAt, @JsonKey(name: 'total_recipients')  int totalRecipients, @JsonKey(name: 'opened_count')  int openedCount, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AdminNotification():
return $default(_that.id,_that.senderId,_that.subject,_that.body,_that.notificationType,_that.status,_that.scheduledAt,_that.sentAt,_that.totalRecipients,_that.openedCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'sender_id')  String senderId,  String subject,  String body, @JsonKey(name: 'notification_type')  NotificationType notificationType,  NotificationStatus status, @JsonKey(name: 'scheduled_at')  DateTime? scheduledAt, @JsonKey(name: 'sent_at')  DateTime? sentAt, @JsonKey(name: 'total_recipients')  int totalRecipients, @JsonKey(name: 'opened_count')  int openedCount, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AdminNotification() when $default != null:
return $default(_that.id,_that.senderId,_that.subject,_that.body,_that.notificationType,_that.status,_that.scheduledAt,_that.sentAt,_that.totalRecipients,_that.openedCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminNotification implements AdminNotification {
  const _AdminNotification({required this.id, @JsonKey(name: 'sender_id') required this.senderId, required this.subject, required this.body, @JsonKey(name: 'notification_type') this.notificationType = NotificationType.uudine, this.status = NotificationStatus.draft, @JsonKey(name: 'scheduled_at') this.scheduledAt, @JsonKey(name: 'sent_at') this.sentAt, @JsonKey(name: 'total_recipients') this.totalRecipients = 0, @JsonKey(name: 'opened_count') this.openedCount = 0, @JsonKey(name: 'created_at') required this.createdAt});
  factory _AdminNotification.fromJson(Map<String, dynamic> json) => _$AdminNotificationFromJson(json);

@override final  String id;
@override@JsonKey(name: 'sender_id') final  String senderId;
@override final  String subject;
@override final  String body;
@override@JsonKey(name: 'notification_type') final  NotificationType notificationType;
@override@JsonKey() final  NotificationStatus status;
@override@JsonKey(name: 'scheduled_at') final  DateTime? scheduledAt;
@override@JsonKey(name: 'sent_at') final  DateTime? sentAt;
@override@JsonKey(name: 'total_recipients') final  int totalRecipients;
@override@JsonKey(name: 'opened_count') final  int openedCount;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of AdminNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminNotificationCopyWith<_AdminNotification> get copyWith => __$AdminNotificationCopyWithImpl<_AdminNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body)&&(identical(other.notificationType, notificationType) || other.notificationType == notificationType)&&(identical(other.status, status) || other.status == status)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.totalRecipients, totalRecipients) || other.totalRecipients == totalRecipients)&&(identical(other.openedCount, openedCount) || other.openedCount == openedCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,subject,body,notificationType,status,scheduledAt,sentAt,totalRecipients,openedCount,createdAt);

@override
String toString() {
  return 'AdminNotification(id: $id, senderId: $senderId, subject: $subject, body: $body, notificationType: $notificationType, status: $status, scheduledAt: $scheduledAt, sentAt: $sentAt, totalRecipients: $totalRecipients, openedCount: $openedCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AdminNotificationCopyWith<$Res> implements $AdminNotificationCopyWith<$Res> {
  factory _$AdminNotificationCopyWith(_AdminNotification value, $Res Function(_AdminNotification) _then) = __$AdminNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'sender_id') String senderId, String subject, String body,@JsonKey(name: 'notification_type') NotificationType notificationType, NotificationStatus status,@JsonKey(name: 'scheduled_at') DateTime? scheduledAt,@JsonKey(name: 'sent_at') DateTime? sentAt,@JsonKey(name: 'total_recipients') int totalRecipients,@JsonKey(name: 'opened_count') int openedCount,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$AdminNotificationCopyWithImpl<$Res>
    implements _$AdminNotificationCopyWith<$Res> {
  __$AdminNotificationCopyWithImpl(this._self, this._then);

  final _AdminNotification _self;
  final $Res Function(_AdminNotification) _then;

/// Create a copy of AdminNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderId = null,Object? subject = null,Object? body = null,Object? notificationType = null,Object? status = null,Object? scheduledAt = freezed,Object? sentAt = freezed,Object? totalRecipients = null,Object? openedCount = null,Object? createdAt = null,}) {
  return _then(_AdminNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,notificationType: null == notificationType ? _self.notificationType : notificationType // ignore: cast_nullable_to_non_nullable
as NotificationType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NotificationStatus,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,totalRecipients: null == totalRecipients ? _self.totalRecipients : totalRecipients // ignore: cast_nullable_to_non_nullable
as int,openedCount: null == openedCount ? _self.openedCount : openedCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

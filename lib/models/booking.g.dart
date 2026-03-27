// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  classInstanceId: json['class_instance_id'] as String,
  status:
      $enumDecodeNullable(_$BookingStatusEnumMap, json['status']) ??
      BookingStatus.confirmed,
  waitlistPosition: (json['waitlist_position'] as num?)?.toInt(),
  cancelType: $enumDecodeNullable(_$CancelTypeEnumMap, json['cancel_type']),
  sessionDeducted: json['session_deducted'] as bool? ?? false,
  cardId: json['card_id'] as String?,
  bookedAt: DateTime.parse(json['booked_at'] as String),
  cancelledAt: json['cancelled_at'] == null
      ? null
      : DateTime.parse(json['cancelled_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'class_instance_id': instance.classInstanceId,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'waitlist_position': instance.waitlistPosition,
  'cancel_type': _$CancelTypeEnumMap[instance.cancelType],
  'session_deducted': instance.sessionDeducted,
  'card_id': instance.cardId,
  'booked_at': instance.bookedAt.toIso8601String(),
  'cancelled_at': instance.cancelledAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};

const _$BookingStatusEnumMap = {
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.waitlisted: 'waitlisted',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.attended: 'attended',
  BookingStatus.noShow: 'no_show',
};

const _$CancelTypeEnumMap = {
  CancelType.normal: 'normal',
  CancelType.late: 'late',
};

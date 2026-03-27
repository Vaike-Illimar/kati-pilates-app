// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionCard _$SessionCardFromJson(Map<String, dynamic> json) => _SessionCard(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  cardType: $enumDecode(_$CardTypeEnumMap, json['card_type']),
  totalSessions: (json['total_sessions'] as num).toInt(),
  remainingSessions: (json['remaining_sessions'] as num).toInt(),
  priceCents: (json['price_cents'] as num).toInt(),
  validFrom: DateTime.parse(json['valid_from'] as String),
  validUntil: DateTime.parse(json['valid_until'] as String),
  originalValidUntil: DateTime.parse(json['original_valid_until'] as String),
  status:
      $enumDecodeNullable(_$CardStatusEnumMap, json['status']) ??
      CardStatus.active,
  purchasedAt: DateTime.parse(json['purchased_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SessionCardToJson(_SessionCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'card_type': _$CardTypeEnumMap[instance.cardType]!,
      'total_sessions': instance.totalSessions,
      'remaining_sessions': instance.remainingSessions,
      'price_cents': instance.priceCents,
      'valid_from': instance.validFrom.toIso8601String(),
      'valid_until': instance.validUntil.toIso8601String(),
      'original_valid_until': instance.originalValidUntil.toIso8601String(),
      'status': _$CardStatusEnumMap[instance.status]!,
      'purchased_at': instance.purchasedAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$CardTypeEnumMap = {
  CardType.fourSessions: '4_sessions',
  CardType.fiveSessions: '5_sessions',
  CardType.tenSessions: '10_sessions',
};

const _$CardStatusEnumMap = {
  CardStatus.active: 'active',
  CardStatus.paused: 'paused',
  CardStatus.expired: 'expired',
  CardStatus.depleted: 'depleted',
};

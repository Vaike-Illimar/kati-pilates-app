// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_pause.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CardPause _$CardPauseFromJson(Map<String, dynamic> json) => _CardPause(
  id: json['id'] as String,
  cardId: json['card_id'] as String,
  reason: $enumDecode(_$PauseReasonEnumMap, json['reason']),
  startDate: DateTime.parse(json['start_date'] as String),
  endDate: DateTime.parse(json['end_date'] as String),
  notes: json['notes'] as String?,
  extensionDays: (json['extension_days'] as num).toInt(),
  createdBy: json['created_by'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CardPauseToJson(_CardPause instance) =>
    <String, dynamic>{
      'id': instance.id,
      'card_id': instance.cardId,
      'reason': _$PauseReasonEnumMap[instance.reason]!,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'notes': instance.notes,
      'extension_days': instance.extensionDays,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$PauseReasonEnumMap = {
  PauseReason.haigus: 'haigus',
  PauseReason.vigastus: 'vigastus',
  PauseReason.puhkus: 'puhkus',
  PauseReason.muu: 'muu',
};

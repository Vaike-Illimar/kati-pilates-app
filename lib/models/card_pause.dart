import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_pause.freezed.dart';
part 'card_pause.g.dart';

enum PauseReason {
  @JsonValue('haigus')
  haigus,
  @JsonValue('vigastus')
  vigastus,
  @JsonValue('puhkus')
  puhkus,
  @JsonValue('muu')
  muu,
}

@freezed
abstract class CardPause with _$CardPause {
  const factory CardPause({
    required String id,
    @JsonKey(name: 'card_id') required String cardId,
    required PauseReason reason,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'end_date') required DateTime endDate,
    String? notes,
    @JsonKey(name: 'extension_days') required int extensionDays,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _CardPause;

  factory CardPause.fromJson(Map<String, dynamic> json) =>
      _$CardPauseFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_card.freezed.dart';
part 'session_card.g.dart';

enum CardType {
  @JsonValue('4_sessions')
  fourSessions,
  @JsonValue('5_sessions')
  fiveSessions,
  @JsonValue('10_sessions')
  tenSessions,
}

enum CardStatus {
  @JsonValue('active')
  active,
  @JsonValue('paused')
  paused,
  @JsonValue('expired')
  expired,
  @JsonValue('depleted')
  depleted,
}

@freezed
abstract class SessionCard with _$SessionCard {
  const factory SessionCard({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'card_type') required CardType cardType,
    @JsonKey(name: 'total_sessions') required int totalSessions,
    @JsonKey(name: 'remaining_sessions') required int remainingSessions,
    @JsonKey(name: 'price_cents') required int priceCents,
    @JsonKey(name: 'valid_from') required DateTime validFrom,
    @JsonKey(name: 'valid_until') required DateTime validUntil,
    @JsonKey(name: 'original_valid_until') required DateTime originalValidUntil,
    @Default(CardStatus.active) CardStatus status,
    @JsonKey(name: 'purchased_at') required DateTime purchasedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _SessionCard;

  factory SessionCard.fromJson(Map<String, dynamic> json) =>
      _$SessionCardFromJson(json);
}

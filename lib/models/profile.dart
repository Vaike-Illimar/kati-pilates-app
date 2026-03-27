import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

enum UserRole {
  @JsonValue('client')
  client,
  @JsonValue('instructor')
  instructor,
  @JsonValue('admin')
  admin,
}

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    required String email,
    String? phone,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default(UserRole.client) UserRole role,
    @JsonKey(name: 'has_pilates_experience') @Default(false) bool hasPilatesExperience,
    @JsonKey(name: 'training_location') String? trainingLocation,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

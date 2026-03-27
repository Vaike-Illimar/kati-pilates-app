import 'package:freezed_annotation/freezed_annotation.dart';

part 'studio.freezed.dart';
part 'studio.g.dart';

@freezed
abstract class Studio with _$Studio {
  const factory Studio({
    required String id,
    required String name,
    String? address,
    required int capacity,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Studio;

  factory Studio.fromJson(Map<String, dynamic> json) =>
      _$StudioFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

enum BookingStatus {
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('waitlisted')
  waitlisted,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('attended')
  attended,
  @JsonValue('no_show')
  noShow,
}

enum CancelType {
  @JsonValue('normal')
  normal,
  @JsonValue('late')
  late,
}

@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'class_instance_id') required String classInstanceId,
    @Default(BookingStatus.confirmed) BookingStatus status,
    @JsonKey(name: 'waitlist_position') int? waitlistPosition,
    @JsonKey(name: 'cancel_type') CancelType? cancelType,
    @JsonKey(name: 'session_deducted') @Default(false) bool sessionDeducted,
    @JsonKey(name: 'card_id') String? cardId,
    @JsonKey(name: 'booked_at') required DateTime bookedAt,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}

/// Maps to the bookings_detailed database view.
class BookingDetailed {
  final String id;
  final String userId;
  final String classInstanceId;
  final BookingStatus status;
  final int? waitlistPosition;
  final CancelType? cancelType;
  final bool sessionDeducted;
  final String? cardId;
  final DateTime bookedAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime? classDate;
  final String? classStartTime;
  final String? classEndTime;
  final String? className;
  final String? level;
  final int? durationMinutes;
  final String? instructorName;
  final String? studioName;

  const BookingDetailed({
    required this.id,
    required this.userId,
    required this.classInstanceId,
    this.status = BookingStatus.confirmed,
    this.waitlistPosition,
    this.cancelType,
    this.sessionDeducted = false,
    this.cardId,
    required this.bookedAt,
    this.cancelledAt,
    required this.createdAt,
    this.classDate,
    this.classStartTime,
    this.classEndTime,
    this.className,
    this.level,
    this.durationMinutes,
    this.instructorName,
    this.studioName,
  });

  factory BookingDetailed.fromJson(Map<String, dynamic> json) {
    return BookingDetailed(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      classInstanceId: json['class_instance_id'] as String,
      status: _bookingStatusFromJson(json['status'] as String),
      waitlistPosition: json['waitlist_position'] as int?,
      cancelType: json['cancel_type'] != null
          ? _cancelTypeFromJson(json['cancel_type'] as String)
          : null,
      sessionDeducted: json['session_deducted'] as bool? ?? false,
      cardId: json['card_id'] as String?,
      bookedAt: DateTime.parse(json['booked_at'] as String),
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      classDate: json['class_date'] != null
          ? DateTime.parse(json['class_date'] as String)
          : null,
      classStartTime: json['class_start_time'] as String?,
      classEndTime: json['class_end_time'] as String?,
      className: json['class_name'] as String?,
      level: json['level'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      instructorName: json['instructor_name'] as String?,
      studioName: json['studio_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'class_instance_id': classInstanceId,
      'status': status.name,
      'waitlist_position': waitlistPosition,
      'cancel_type': cancelType?.name,
      'session_deducted': sessionDeducted,
      'card_id': cardId,
      'booked_at': bookedAt.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'class_date': classDate?.toIso8601String(),
      'class_start_time': classStartTime,
      'class_end_time': classEndTime,
      'class_name': className,
      'level': level,
      'duration_minutes': durationMinutes,
      'instructor_name': instructorName,
      'studio_name': studioName,
    };
  }

  static BookingStatus _bookingStatusFromJson(String value) {
    switch (value) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'waitlisted':
        return BookingStatus.waitlisted;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'attended':
        return BookingStatus.attended;
      case 'no_show':
        return BookingStatus.noShow;
      default:
        return BookingStatus.confirmed;
    }
  }

  static CancelType _cancelTypeFromJson(String value) {
    switch (value) {
      case 'normal':
        return CancelType.normal;
      case 'late':
        return CancelType.late;
      default:
        return CancelType.normal;
    }
  }
}

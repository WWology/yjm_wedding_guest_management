import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'guest.freezed.dart';
part 'guest.g.dart';

@freezed
abstract class Guest with _$Guest {
  const factory Guest({
    required String id,
    required String name,
    String? phone,
    String? table,
    AttendanceStatus? attendanceStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Guest;

  factory Guest.fromJson(Map<String, dynamic> json) => _$GuestFromJson(json);
}

enum AttendanceStatus { attending, notAttending }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    
    if (value is Timestamp) {
      return value.toDate();
    }
    
    if (value is String) {
      return DateTime.parse(value);
    }
    
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}

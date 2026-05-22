import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

enum MessageStatus { failed, sending, sent, delivered }

class MessageStatusConverter extends TypeConverter<MessageStatus, int> {
  const MessageStatusConverter();

  @override
  MessageStatus fromSql(int fromDb) {
    return MessageStatus.values[fromDb];
  }

  @override
  int toSql(MessageStatus value) {
    return value.index;
  }
}

class UriTypeConverter extends TypeConverter<Uri, String> {
  const UriTypeConverter();

  @override
  Uri fromSql(String fromDb) {
    return Uri.parse(fromDb);
  }

  @override
  String toSql(Uri value) {
    return value.toString();
  }
}

class UuidValueConverter extends TypeConverter<UuidValue, String> {
  const UuidValueConverter();
  @override
  UuidValue fromSql(String fromDb) {
    return UuidValue.fromString(fromDb);
  }

  @override
  String toSql(UuidValue value) {
    return value.toString();
  }
}

class JsonValueConverter extends TypeConverter<Map<String, dynamic>, String> {
  const JsonValueConverter();
  @override
  Map<String, dynamic> fromSql(String fromDb) {
    return jsonDecode(fromDb);
  }

  @override
  String toSql(Map<String, dynamic> value) {
    return jsonEncode(value);
  }
}

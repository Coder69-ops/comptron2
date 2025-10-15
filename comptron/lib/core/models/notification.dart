import 'package:mongo_dart/mongo_dart.dart';

enum NotificationType { general, event, announcement, reminder }

class Notification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final ObjectId? eventId;
  final Map<String, dynamic>? data;

  const Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.eventId,
    this.data,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.general,
      ),
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      eventId: json['eventId'] != null
          ? ObjectId.fromHexString(json['eventId'])
          : null,
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'eventId': eventId?.oid,
      'data': data,
    };
  }

  Notification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    ObjectId? eventId,
    Map<String, dynamic>? data,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      eventId: eventId ?? this.eventId,
      data: data ?? this.data,
    );
  }
}

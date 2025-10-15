import 'package:mongo_dart/mongo_dart.dart';

enum AnnouncementPriority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case AnnouncementPriority.low:
        return 'Low';
      case AnnouncementPriority.medium:
        return 'Medium';
      case AnnouncementPriority.high:
        return 'High';
    }
  }
}

class Announcement {
  final ObjectId id;
  final String title;
  final String content;
  final AnnouncementPriority priority;
  final ObjectId? eventId;
  final bool isPublished;
  final ObjectId createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.priority = AnnouncementPriority.medium,
    this.eventId,
    this.isPublished = false,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['_id'] as ObjectId,
      title: json['title'] as String,
      content: json['content'] as String,
      priority: AnnouncementPriority.values.firstWhere(
        (e) => e.name == (json['priority'] as String),
        orElse: () => AnnouncementPriority.medium,
      ),
      eventId: json['eventId'] as ObjectId?,
      isPublished: json['isPublished'] as bool? ?? false,
      createdBy: json['createdBy'] as ObjectId,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'content': content,
      'priority': priority.name,
      'eventId': eventId,
      'isPublished': isPublished,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Announcement copyWith({
    ObjectId? id,
    String? title,
    String? content,
    AnnouncementPriority? priority,
    ObjectId? eventId,
    bool? isPublished,
    ObjectId? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      eventId: eventId ?? this.eventId,
      isPublished: isPublished ?? this.isPublished,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
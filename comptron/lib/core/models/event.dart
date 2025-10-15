import 'package:mongo_dart/mongo_dart.dart';

enum EventType {
  workshop,
  seminar,
  conference,
  meetup,
  other;

  String get label {
    switch (this) {
      case EventType.workshop:
        return 'Workshop';
      case EventType.seminar:
        return 'Seminar';
      case EventType.conference:
        return 'Conference';
      case EventType.meetup:
        return 'Meetup';
      case EventType.other:
        return 'Other';
    }
  }
}

class Event {
  final ObjectId id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final EventType type;
  final List<String> tags;
  final int capacity;
  final int registeredCount;
  final List<ObjectId> registeredUsers;
  final List<ObjectId> waitlistedUsers;
  final bool isPublished;
  final ObjectId createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl = '',
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.type,
    this.tags = const [],
    required this.capacity,
    this.registeredCount = 0,
    this.registeredUsers = const [],
    this.waitlistedUsers = const [],
    this.isPublished = false,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] as ObjectId,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      location: json['location'] as String,
      type: EventType.values.firstWhere(
        (e) => e.name == (json['type'] as String),
        orElse: () => EventType.other,
      ),
      tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
      capacity: json['capacity'] as int,
      registeredCount: json['registeredCount'] as int? ?? 0,
      registeredUsers: (json['registeredUsers'] as List?)
          ?.map((e) => e as ObjectId)
          .toList() ??
          [],
      waitlistedUsers: (json['waitlistedUsers'] as List?)
          ?.map((e) => e as ObjectId)
          .toList() ??
          [],
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
      'description': description,
      'imageUrl': imageUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'type': type.name,
      'tags': tags,
      'capacity': capacity,
      'registeredCount': registeredCount,
      'registeredUsers': registeredUsers,
      'waitlistedUsers': waitlistedUsers,
      'isPublished': isPublished,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isFull => registeredCount >= capacity;
  bool get hasWaitlist => waitlistedUsers.isNotEmpty;
  
  bool isRegistered(ObjectId userId) {
    return registeredUsers.contains(userId);
  }

  bool isWaitlisted(ObjectId userId) {
    return waitlistedUsers.contains(userId);
  }

  Event copyWith({
    ObjectId? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    EventType? type,
    List<String>? tags,
    int? capacity,
    int? registeredCount,
    List<ObjectId>? registeredUsers,
    List<ObjectId>? waitlistedUsers,
    bool? isPublished,
    ObjectId? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      capacity: capacity ?? this.capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      registeredUsers: registeredUsers ?? this.registeredUsers,
      waitlistedUsers: waitlistedUsers ?? this.waitlistedUsers,
      isPublished: isPublished ?? this.isPublished,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
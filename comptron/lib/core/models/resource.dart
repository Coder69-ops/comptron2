import 'package:mongo_dart/mongo_dart.dart';

class Resource {
  final ObjectId id;
  final String title;
  final String description;
  final String url;
  final String type;
  final List<String> tags;
  final ObjectId? eventId;
  final bool isPublished;
  final ObjectId createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.type,
    this.tags = const [],
    this.eventId,
    this.isPublished = false,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['_id'] as ObjectId,
      title: json['title'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
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
      'description': description,
      'url': url,
      'type': type,
      'tags': tags,
      'eventId': eventId,
      'isPublished': isPublished,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Resource copyWith({
    ObjectId? id,
    String? title,
    String? description,
    String? url,
    String? type,
    List<String>? tags,
    ObjectId? eventId,
    bool? isPublished,
    ObjectId? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      eventId: eventId ?? this.eventId,
      isPublished: isPublished ?? this.isPublished,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
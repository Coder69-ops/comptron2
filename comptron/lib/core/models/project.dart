import 'package:mongo_dart/mongo_dart.dart';

enum ProjectStatus {
  pending,
  approved,
  rejected;

  String get label {
    switch (this) {
      case ProjectStatus.pending:
        return 'Pending';
      case ProjectStatus.approved:
        return 'Approved';
      case ProjectStatus.rejected:
        return 'Rejected';
    }
  }
}

class Project {
  final ObjectId id;
  final String title;
  final String description;
  final String imageUrl;
  final String? videoUrl;
  final String githubUrl;
  final String liveUrl;
  final List<String> screenshots;
  final List<String> tags;
  final String authorName;
  final String authorEmail;
  final ObjectId authorId;
  final ProjectStatus status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ObjectId? approvedBy;
  final DateTime? approvedAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl = '',
    this.videoUrl,
    this.githubUrl = '',
    this.liveUrl = '',
    this.screenshots = const [],
    this.tags = const [],
    required this.authorName,
    required this.authorEmail,
    required this.authorId,
    this.status = ProjectStatus.pending,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.approvedBy,
    this.approvedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'] ?? ObjectId(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      videoUrl: json['videoUrl'],
      githubUrl: json['githubUrl'] ?? '',
      liveUrl: json['liveUrl'] ?? '',
      screenshots: List<String>.from(json['screenshots'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      authorName: json['authorName'] ?? '',
      authorEmail: json['authorEmail'] ?? '',
      authorId: json['authorId'] is String
          ? ObjectId.fromHexString(json['authorId'])
          : json['authorId'] ?? ObjectId(),
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString() == 'ProjectStatus.${json['status']}',
        orElse: () => ProjectStatus.pending,
      ),
      rejectionReason: json['rejectionReason'],
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      approvedBy: json['approvedBy'] is String
          ? ObjectId.fromHexString(json['approvedBy'])
          : json['approvedBy'],
      approvedAt: json['approvedAt'] is String
          ? DateTime.parse(json['approvedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'githubUrl': githubUrl,
      'liveUrl': liveUrl,
      'screenshots': screenshots,
      'tags': tags,
      'authorName': authorName,
      'authorEmail': authorEmail,
      'authorId': authorId,
      'status': status.toString().split('.').last,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
    };
  }

  Project copyWith({
    ObjectId? id,
    String? title,
    String? description,
    String? imageUrl,
    String? videoUrl,
    String? githubUrl,
    String? liveUrl,
    List<String>? screenshots,
    List<String>? tags,
    String? authorName,
    String? authorEmail,
    ObjectId? authorId,
    ProjectStatus? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    ObjectId? approvedBy,
    DateTime? approvedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      liveUrl: liveUrl ?? this.liveUrl,
      screenshots: screenshots ?? this.screenshots,
      tags: tags ?? this.tags,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      authorId: authorId ?? this.authorId,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}

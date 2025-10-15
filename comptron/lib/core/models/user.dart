import 'package:mongo_dart/mongo_dart.dart';

enum UserRole {
  student,
  admin;

  String get label {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

class User {
  final ObjectId id;
  final String email;
  final String name;
  final String avatarUrl;
  final UserRole role;
  final List<ObjectId> registeredEvents;
  final List<ObjectId> favoriteEvents;
  final List<String> badges;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl = '',
    required this.role,
    this.registeredEvents = const [],
    this.favoriteEvents = const [],
    this.badges = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle ObjectId deserialization safely
    ObjectId id;
    try {
      final idData = json['_id'];
      if (idData is ObjectId) {
        id = idData;
      } else if (idData is String) {
        id = ObjectId.fromHexString(idData);
      } else {
        // Fallback: create a new ObjectId
        id = ObjectId();
      }
    } catch (e) {
      // If ObjectId parsing fails, create a new one
      id = ObjectId();
    }

    return User(
      id: id,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] as String),
        orElse: () => UserRole.student,
      ),
      registeredEvents:
          (json['registeredEvents'] as List?)
              ?.map(
                (e) => e is ObjectId ? e : ObjectId.fromHexString(e.toString()),
              )
              .toList() ??
          [],
      favoriteEvents:
          (json['favoriteEvents'] as List?)
              ?.map(
                (e) => e is ObjectId ? e : ObjectId.fromHexString(e.toString()),
              )
              .toList() ??
          [],
      badges: (json['badges'] as List?)?.map((e) => e as String).toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id.oid, // Serialize ObjectId as string for storage compatibility
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'registeredEvents': registeredEvents.map((e) => e.oid).toList(),
      'favoriteEvents': favoriteEvents.map((e) => e.oid).toList(),
      'badges': badges,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    ObjectId? id,
    String? email,
    String? name,
    String? avatarUrl,
    UserRole? role,
    List<ObjectId>? registeredEvents,
    List<ObjectId>? favoriteEvents,
    List<String>? badges,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      registeredEvents: registeredEvents ?? this.registeredEvents,
      favoriteEvents: favoriteEvents ?? this.favoriteEvents,
      badges: badges ?? this.badges,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

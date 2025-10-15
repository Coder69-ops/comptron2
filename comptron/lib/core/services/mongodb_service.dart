import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart' hide Project;
import '../config/app_config.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../models/announcement.dart';
import '../models/resource.dart';
import '../models/project.dart';
import '../models/registration.dart';

class MongoDBService {
  static MongoDBService? _instance;
  static bool _isInitializing = false;
  static bool _isInitialized = false;
  late Db _db;

  // Collections
  late DbCollection _users;
  late DbCollection _events;
  late DbCollection _announcements;
  late DbCollection _resources;
  late DbCollection _registrations;
  late DbCollection _projects;

  MongoDBService._();

  static Future<MongoDBService> getInstance() async {
    if (_instance != null && _isInitialized) {
      return _instance!;
    }

    if (_isInitializing) {
      // Wait for initialization to complete
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (_instance != null && _isInitialized) {
        return _instance!;
      }
    }

    _instance ??= MongoDBService._();

    if (!_isInitialized && !_isInitializing) {
      _isInitializing = true;
      try {
        await _instance!._initialize();
        _isInitialized = true;
      } catch (e) {
        _isInitialized = false;
        rethrow;
      } finally {
        _isInitializing = false;
      }
    }

    return _instance!;
  }

  Future<void> _initialize() async {
    try {
      _db = await Db.create(AppConfig.mongodbUri);

      // Add timeout for database connection
      await _db.open().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            'MongoDB connection timeout',
            const Duration(seconds: 10),
          );
        },
      );

      _users = _db.collection(AppConfig.usersCollection);
      _events = _db.collection(AppConfig.eventsCollection);
      _announcements = _db.collection(AppConfig.announcementsCollection);
      _resources = _db.collection(AppConfig.resourcesCollection);
      _registrations = _db.collection(AppConfig.registrationsCollection);
      _projects = _db.collection('projects');

      // Create indexes with timeout
      await _createIndexes().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('Index creation timeout - continuing without indexes');
        },
      );
    } catch (e) {
      print('MongoDB initialization error: $e');
      rethrow;
    }
  }

  Future<void> _createIndexes() async {
    // Users collection indexes
    await _users.createIndex(key: 'email', unique: true);

    // Events collection indexes
    await _events.createIndex(key: 'startDate');
    await _events.createIndex(key: 'type');
    await _events.createIndex(key: 'tags');

    // Announcements collection indexes
    await _announcements.createIndex(key: 'createdAt');
    await _announcements.createIndex(key: 'eventId');

    // Resources collection indexes
    await _resources.createIndex(key: 'type');
    await _resources.createIndex(key: 'tags');
    await _resources.createIndex(key: 'eventId');

    // Registrations collection indexes
    await _registrations.createIndex(
      keys: {'eventId': 1, 'userId': 1},
      unique: true,
    );

    // Projects collection indexes
    await _projects.createIndex(key: 'status');
    await _projects.createIndex(key: 'authorId');
    await _projects.createIndex(key: 'createdAt');
    await _projects.createIndex(key: 'tags');
  }

  // User operations
  Future<User?> getUserById(ObjectId id) async {
    final doc = await _users.findOne(where.id(id));
    return doc == null ? null : User.fromJson(doc);
  }

  Future<User?> getUserByEmail(String email) async {
    final doc = await _users.findOne(where.eq('email', email));
    return doc == null ? null : User.fromJson(doc);
  }

  Future<User?> getUserByEmailAndPassword(
    String email,
    String hashedPassword,
  ) async {
    final doc = await _users.findOne(
      where.eq('email', email).eq('passwordHash', hashedPassword),
    );
    return doc == null ? null : User.fromJson(doc);
  }

  Future<void> createUser(User user) async {
    await _users.insert(user.toJson());
  }

  Future<void> createUserWithPassword(User user, String hashedPassword) async {
    final userJson = user.toJson();
    userJson['passwordHash'] = hashedPassword;
    await _users.insert(userJson);
  }

  Future<void> updateUser(User user) async {
    await _users.update(where.id(user.id), user.toJson());
  }

  // Event operations
  Future<List<Event>> getUpcomingEvents({
    int limit = 10,
    int skip = 0,
    String? type,
    List<String>? tags,
  }) async {
    return await _safeExecute<List<Event>>(() async {
      final query = where
          .gt('startDate', DateTime.now().toIso8601String())
          .eq('isPublished', true);

      if (type != null) {
        query.eq('type', type);
      }

      if (tags != null && tags.isNotEmpty) {
        query.oneFrom('tags', tags);
      }

      final docs = await _events.find(query).skip(skip).take(limit).toList();

      return docs.map((doc) => Event.fromJson(doc)).toList();
    }, fallback: <Event>[]);
  }

  Future<Event?> getEventById(ObjectId id) async {
    final doc = await _events.findOne(where.id(id));
    return doc == null ? null : Event.fromJson(doc);
  }

  Future<void> createEvent(Event event) async {
    await _events.insert(event.toJson());
  }

  Future<void> updateEvent(Event event) async {
    await _events.update(where.id(event.id), event.toJson());
  }

  Future<void> deleteEvent(ObjectId id) async {
    await _safeExecute(() async {
      await _events.remove(where.eq('_id', id));
    });
  }

  Future<List<Event>> getEvents({
    int limit = 20,
    String? type,
    List<String>? tags,
  }) async {
    return await _safeExecute<List<Event>>(() async {
      final query = where;

      if (type != null && type.isNotEmpty) {
        query.eq('type', type);
      }

      if (tags != null && tags.isNotEmpty) {
        query.oneFrom('tags', tags);
      }

      final docs = await _events.find(query).take(limit).toList();

      return docs.map((doc) => Event.fromJson(doc)).toList();
    }, fallback: <Event>[]);
  }

  // Announcement operations
  Future<List<Announcement>> getAnnouncements({
    int limit = 10,
    int skip = 0,
    ObjectId? eventId,
  }) async {
    return await _safeExecute<List<Announcement>>(() async {
      final query = where.eq('isPublished', true);

      if (eventId != null) {
        query.eq('eventId', eventId);
      }

      final docs = await _announcements
          .find(query)
          .skip(skip)
          .take(limit)
          .toList();

      return docs.map((doc) => Announcement.fromJson(doc)).toList();
    }, fallback: <Announcement>[]);
  }

  Future<void> createAnnouncement(Announcement announcement) async {
    await _announcements.insert(announcement.toJson());
  }

  Future<void> updateAnnouncement(
    ObjectId id,
    Announcement announcement,
  ) async {
    await _safeExecute(() async {
      await _announcements.update(where.eq('_id', id), announcement.toJson());
    });
  }

  Future<void> deleteAnnouncement(ObjectId id) async {
    await _safeExecute(() async {
      await _announcements.remove(where.eq('_id', id));
    });
  }

  // Resource operations
  Future<List<Resource>> getResources({
    int limit = 10,
    int skip = 0,
    String? type,
    List<String>? tags,
    ObjectId? eventId,
  }) async {
    return await _safeExecute<List<Resource>>(() async {
      final query = where.eq('isPublished', true);

      if (type != null) {
        query.eq('type', type);
      }

      if (tags != null && tags.isNotEmpty) {
        query.oneFrom('tags', tags);
      }

      if (eventId != null) {
        query.eq('eventId', eventId);
      }

      final docs = await _resources.find(query).skip(skip).take(limit).toList();

      return docs.map((doc) => Resource.fromJson(doc)).toList();
    }, fallback: <Resource>[]);
  }

  Future<void> createResource(Resource resource) async {
    await _resources.insert(resource.toJson());
  }

  Future<void> updateResource(ObjectId id, Resource resource) async {
    await _safeExecute(() async {
      await _resources.update(where.eq('_id', id), resource.toJson());
    });
  }

  Future<void> deleteResource(ObjectId id) async {
    await _safeExecute(() async {
      await _resources.remove(where.eq('_id', id));
    });
  }

  // Registration operations
  Future<bool> registerForEvent(ObjectId userId, ObjectId eventId) async {
    final event = await getEventById(eventId);
    if (event == null) return false;

    if (event.isFull) {
      // Add to waitlist
      await _events.update(where.id(eventId), {
        '\$push': {'waitlistedUsers': userId},
        '\$set': {'updatedAt': DateTime.now().toIso8601String()},
      });
      return false;
    }

    // Register the user
    await _events.update(where.id(eventId), {
      '\$push': {'registeredUsers': userId},
      '\$inc': {'registeredCount': 1},
      '\$set': {'updatedAt': DateTime.now().toIso8601String()},
    });

    await _users.update(where.id(userId), {
      '\$push': {'registeredEvents': eventId},
      '\$set': {'updatedAt': DateTime.now().toIso8601String()},
    });

    return true;
  }

  // Project operations
  Future<List<Project>> getApprovedProjects({
    int limit = 10,
    int skip = 0,
    List<String>? tags,
  }) async {
    return await _safeExecute<List<Project>>(() async {
      final query = where.eq('status', 'approved');

      if (tags != null && tags.isNotEmpty) {
        query.oneFrom('tags', tags);
      }

      final docs = await _projects.find(query).skip(skip).take(limit).toList();

      return docs.map((doc) => Project.fromJson(doc)).toList();
    }, fallback: <Project>[]);
  }

  Future<List<Project>> getAllProjects({
    int limit = 10,
    int skip = 0,
    String? status,
  }) async {
    var query = where;

    if (status != null) {
      query = query.eq('status', status);
    }

    final docs = await _projects.find(query).skip(skip).take(limit).toList();

    return docs.map((doc) => Project.fromJson(doc)).toList();
  }

  Future<Project?> getProjectById(ObjectId id) async {
    final doc = await _projects.findOne(where.id(id));
    return doc == null ? null : Project.fromJson(doc);
  }

  Future<void> createProject(Project project) async {
    await _projects.insert(project.toJson());
  }

  Future<void> updateProject(Project project) async {
    await _projects.update(where.id(project.id), project.toJson());
  }

  Future<List<Project>> getProjectsByStatus(
    ProjectStatus status, {
    int? limit,
  }) async {
    var query = where.eq('status', status.toString().split('.').last);
    query = query.sortBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final results = await _projects.find(query).toList();
    return results.map((json) => Project.fromJson(json)).toList();
  }

  Future<void> approveProject(ObjectId projectId, ObjectId approvedBy) async {
    await _projects.update(where.id(projectId), {
      '\$set': {
        'status': 'approved',
        'approvedBy': approvedBy,
        'approvedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    });
  }

  Future<void> rejectProject(ObjectId projectId, String reason) async {
    await _projects.update(where.id(projectId), {
      '\$set': {
        'status': 'rejected',
        'rejectionReason': reason,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    });
  }

  // Helper method to safely execute MongoDB operations
  Future<T> _safeExecute<T>(
    Future<T> Function() operation, {
    T? fallback,
  }) async {
    try {
      // Check if database is in a valid state
      if (_db.state != State.open) {
        throw Exception('Database connection is not open. State: ${_db.state}');
      }

      return await operation().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (fallback != null) {
            return fallback;
          }
          throw TimeoutException(
            'Operation timeout',
            const Duration(seconds: 30),
          );
        },
      );
    } catch (e) {
      print('MongoDB operation error: $e');
      if (fallback != null) {
        return fallback;
      }
      rethrow;
    }
  }

  // Reset connection if needed
  static Future<void> resetConnection() async {
    if (_instance != null) {
      try {
        await _instance!._db.close();
      } catch (e) {
        print('Error closing existing connection: $e');
      }
    }
    _instance = null;
    _isInitialized = false;
    _isInitializing = false;
  }

  // Registration Management
  Future<Registration> createRegistration({
    required ObjectId eventId,
    required ObjectId userId,
    required String eventTitle,
    required String userName,
    required String userEmail,
    String? studentId,
    String? personalEmail,
    String? phoneNumber,
    String? batch,
    String? section,
    required DateTime eventDate,
    Map<String, dynamic>? additionalData,
  }) async {
    final registrationId = ObjectId();
    final qrCode = Registration.generateQRCode(registrationId, eventId, userId);

    // Check if event is full
    final event = await getEventById(eventId);
    if (event == null) {
      throw Exception('Event not found');
    }

    // Check if user is already registered by userId, email, or studentId
    final existingRegistration = await _registrations.findOne({
      'eventId': eventId,
      'status': {'\$ne': 'cancelled'},
      '\$or': [
        {'userId': userId},
        {'userEmail': userEmail},
        {'studentId': studentId},
      ],
    });

    if (existingRegistration != null) {
      if (existingRegistration['userId'] == userId) {
        throw Exception('User already registered for this event');
      } else if (existingRegistration['userEmail'] == userEmail) {
        throw Exception(
          'This @nwu.ac.bd email is already registered for this event',
        );
      } else if (existingRegistration['studentId'] == studentId) {
        throw Exception('This student ID is already registered for this event');
      }
    }

    // Determine initial status based on capacity
    final confirmedCount = await _registrations.count({
      'eventId': eventId,
      'status': 'confirmed',
    });

    final status = confirmedCount >= event.capacity
        ? RegistrationStatus.waitlisted
        : RegistrationStatus.confirmed;

    final registration = Registration(
      id: registrationId,
      eventId: eventId,
      userId: userId,
      eventTitle: eventTitle,
      userName: userName,
      userEmail: userEmail,
      studentId: studentId,
      personalEmail: personalEmail,
      phoneNumber: phoneNumber,
      batch: batch,
      section: section,
      eventDate: eventDate,
      status: status,
      registeredAt: DateTime.now(),
      qrCode: qrCode,
      additionalData: additionalData,
    );

    await _registrations.insertOne(registration.toJson());

    // Update event registration count
    await updateEventRegistrationCount(eventId);

    return registration;
  }

  Future<List<Registration>> getUserRegistrations(ObjectId userId) async {
    try {
      final registrations = await _registrations.find({
        'userId': userId,
        'status': {'\$ne': 'cancelled'},
      }).toList();
      return registrations.map((json) => Registration.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching user registrations: $e');
      return [];
    }
  }

  Future<List<Registration>> getEventRegistrations(ObjectId eventId) async {
    try {
      final registrations = await _registrations.find({
        'eventId': eventId,
        'status': {'\$ne': 'cancelled'},
      }).toList();
      return registrations.map((json) => Registration.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching event registrations: $e');
      return [];
    }
  }

  Future<Registration?> getRegistrationByQR(String qrCode) async {
    try {
      final result = await _registrations.findOne({'qrCode': qrCode});
      return result != null ? Registration.fromJson(result) : null;
    } catch (e) {
      print('Error fetching registration by QR: $e');
      return null;
    }
  }

  Future<Registration?> getRegistration(
    ObjectId eventId,
    ObjectId userId,
  ) async {
    try {
      final result = await _registrations.findOne({
        'eventId': eventId,
        'userId': userId,
        'status': {'\$ne': 'cancelled'},
      });
      return result != null ? Registration.fromJson(result) : null;
    } catch (e) {
      print('Error fetching registration: $e');
      return null;
    }
  }

  Future<void> updateRegistrationStatus(
    ObjectId registrationId,
    RegistrationStatus status, {
    DateTime? checkedInAt,
  }) async {
    final updateData = {'status': status.name};

    if (status == RegistrationStatus.checkedIn && checkedInAt != null) {
      updateData['checkedInAt'] = checkedInAt.toIso8601String();
    }

    await _registrations.updateOne(
      {'_id': registrationId},
      {'\$set': updateData},
    );

    // Get registration to update event count
    final registration = await _registrations.findOne({'_id': registrationId});
    if (registration != null) {
      await updateEventRegistrationCount(registration['eventId'] as ObjectId);

      // If cancelling, try to promote from waitlist
      if (status == RegistrationStatus.cancelled) {
        await promoteFromWaitlist(registration['eventId'] as ObjectId);
      }
    }
  }

  Future<void> cancelRegistration(ObjectId registrationId) async {
    await updateRegistrationStatus(
      registrationId,
      RegistrationStatus.cancelled,
    );
  }

  Future<Registration> checkInUser(String qrCode, ObjectId adminId) async {
    final registration = await getRegistrationByQR(qrCode);

    if (registration == null) {
      throw Exception('Invalid QR code');
    }

    if (registration.isCheckedIn) {
      throw Exception('User already checked in');
    }

    if (registration.isCancelled) {
      throw Exception('Registration is cancelled');
    }

    // Check if event is today (allow check-in only on event day or within reasonable time)
    final now = DateTime.now();
    final eventDate = registration.eventDate;
    final daysDifference = eventDate.difference(now).inDays;

    if (daysDifference > 1 || daysDifference < -1) {
      throw Exception('Check-in only allowed on event day');
    }

    await updateRegistrationStatus(
      registration.id,
      RegistrationStatus.checkedIn,
      checkedInAt: now,
    );

    return registration.copyWith(
      status: RegistrationStatus.checkedIn,
      checkedInAt: now,
    );
  }

  Future<void> updateEventRegistrationCount(ObjectId eventId) async {
    final confirmedCount = await _registrations.count({
      'eventId': eventId,
      'status': 'confirmed',
    });

    final checkedInCount = await _registrations.count({
      'eventId': eventId,
      'status': 'checkedIn',
    });

    await _events.updateOne(
      {'_id': eventId},
      {
        '\$set': {'registeredCount': confirmedCount + checkedInCount},
      },
    );
  }

  Future<void> promoteFromWaitlist(ObjectId eventId) async {
    final event = await getEventById(eventId);
    if (event == null) return;

    final confirmedCount = await _registrations.count({
      'eventId': eventId,
      'status': 'confirmed',
    });

    if (confirmedCount < event.capacity) {
      // Find the oldest waitlisted registration
      final cursor = _registrations.find({
        'eventId': eventId,
        'status': 'waitlisted',
      });
      final waitlistRegistrations = await cursor.take(1).toList();

      if (waitlistRegistrations.isNotEmpty) {
        final registrationToPromote = waitlistRegistrations.first;
        await updateRegistrationStatus(
          registrationToPromote['_id'] as ObjectId,
          RegistrationStatus.confirmed,
        );
      }
    }
  }

  Future<Map<String, int>> getEventRegistrationStats(ObjectId eventId) async {
    final confirmed = await _registrations.count({
      'eventId': eventId,
      'status': 'confirmed',
    });

    final waitlisted = await _registrations.count({
      'eventId': eventId,
      'status': 'waitlisted',
    });

    final checkedIn = await _registrations.count({
      'eventId': eventId,
      'status': 'checkedIn',
    });

    return {
      'confirmed': confirmed,
      'waitlisted': waitlisted,
      'checkedIn': checkedIn,
      'total': confirmed + waitlisted + checkedIn,
    };
  }

  // Check if the service is properly initialized
  bool get isInitialized => _isInitialized && _db.state == State.open;

  Future<void> close() async {
    try {
      if (_db.state == State.open) {
        await _db.close();
      }
    } catch (e) {
      print('Error closing MongoDB connection: $e');
    } finally {
      _isInitialized = false;
    }
  }
}

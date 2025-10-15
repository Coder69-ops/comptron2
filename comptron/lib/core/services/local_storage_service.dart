import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../models/announcement.dart';
import '../models/resource.dart';
import '../models/notification.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  
  late Box _authBox;
  late Box _eventsBox;
  late Box _announcementsBox;
  late Box _resourcesBox;
  late Box _userBox;
  late Box _notificationsBox;

  LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    await Hive.initFlutter();
    
    _authBox = await Hive.openBox(AppConfig.authBox);
    _eventsBox = await Hive.openBox(AppConfig.eventsBox);
    _announcementsBox = await Hive.openBox(AppConfig.announcementsBox);
    _resourcesBox = await Hive.openBox(AppConfig.resourcesBox);
    _userBox = await Hive.openBox(AppConfig.userBox);
    _notificationsBox = await Hive.openBox('notifications');
  }

  // Auth data
  Future<void> saveAuthToken(String token) async {
    await _authBox.put('token', token);
  }

  String? getAuthToken() {
    return _authBox.get('token');
  }

  Future<void> clearAuth() async {
    await _authBox.clear();
  }

  // User data
  Future<void> saveUser(User user) async {
    await _userBox.put('currentUser', user.toJson());
  }

  User? getUser() {
    final userData = _userBox.get('currentUser');
    if (userData == null) return null;
    return User.fromJson(Map<String, dynamic>.from(userData));
  }

  // User authentication data (for offline use)
  Future<void> saveUserWithPassword(User user, String hashedPassword) async {
    final userData = user.toJson();
    userData['passwordHash'] = hashedPassword;
    await _userBox.put('user_${user.email}', userData);
    await saveUser(user); // Also save as current user
  }

  Future<User?> getUserByEmailAndPassword(String email, String hashedPassword) async {
    final userData = _userBox.get('user_$email');
    if (userData == null) return null;
    
    final userMap = Map<String, dynamic>.from(userData);
    final storedPasswordHash = userMap['passwordHash'];
    
    if (storedPasswordHash == hashedPassword) {
      userMap.remove('passwordHash'); // Remove password hash before creating User object
      return User.fromJson(userMap);
    }
    
    return null;
  }

  User? getUserByEmail(String email) {
    final userData = _userBox.get('user_$email');
    if (userData == null) return null;
    
    final userMap = Map<String, dynamic>.from(userData);
    userMap.remove('passwordHash'); // Remove password hash before creating User object
    return User.fromJson(userMap);
  }

  // Events
  Future<void> saveEvents(List<Event> events) async {
    final eventsData = events.map((e) => e.toJson()).toList();
    await _eventsBox.put('events', eventsData);
  }

  List<Event> getEvents() {
    final eventsData = _eventsBox.get('events', defaultValue: []);
    return (eventsData as List)
        .map((e) => Event.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // Announcements
  Future<void> saveAnnouncements(List<Announcement> announcements) async {
    final announcementsData = announcements.map((a) => a.toJson()).toList();
    await _announcementsBox.put('announcements', announcementsData);
  }

  List<Announcement> getAnnouncements() {
    final announcementsData = _announcementsBox.get('announcements', defaultValue: []);
    return (announcementsData as List)
        .map((a) => Announcement.fromJson(Map<String, dynamic>.from(a)))
        .toList();
  }

  // Resources
  Future<void> saveResources(List<Resource> resources) async {
    final resourcesData = resources.map((r) => r.toJson()).toList();
    await _resourcesBox.put('resources', resourcesData);
  }

  List<Resource> getResources() {
    final resourcesData = _resourcesBox.get('resources', defaultValue: []);
    return (resourcesData as List)
        .map((r) => Resource.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  // Notifications
  Future<void> saveNotification(Notification notification) async {
    await _notificationsBox.put(notification.id, notification.toJson());
  }

  List<Notification> getNotifications() {
    final notificationsData = _notificationsBox.values.toList();
    return notificationsData
        .map((n) => Notification.fromJson(Map<String, dynamic>.from(n)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> updateNotification(Notification notification) async {
    await _notificationsBox.put(notification.id, notification.toJson());
  }

  Future<void> clearNotifications() async {
    await _notificationsBox.clear();
  }

  Future<void> clearAll() async {
    await Future.wait([
      _authBox.clear(),
      _eventsBox.clear(),
      _announcementsBox.clear(),
      _resourcesBox.clear(),
      _userBox.clear(),
      _notificationsBox.clear(),
    ]);
  }
}
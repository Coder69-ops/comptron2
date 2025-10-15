class AppConfig {
  static const String mongodbUri = 'mongodb+srv://oveisawesome_db_user:1rj2ogNr7hO7XUG0@cluster0.pkrk3ft.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';
  static const String databaseName = 'comptron';

  // Collections
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String announcementsCollection = 'announcements';
  static const String resourcesCollection = 'resources';
  static const String registrationsCollection = 'registrations';

  // FCM
  static const String firebaseServerKey = 'YOUR_FIREBASE_SERVER_KEY';

  // Hive box names
  static const String authBox = 'auth';
  static const String eventsBox = 'events';
  static const String announcementsBox = 'announcements';
  static const String resourcesBox = 'resources';
  static const String userBox = 'user';
}
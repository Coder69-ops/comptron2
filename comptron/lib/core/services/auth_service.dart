import 'package:google_sign_in/google_sign_in.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';
import 'local_storage_service.dart';
import 'mongodb_service.dart';

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
}

class AuthService {
  static AuthService? _instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late LocalStorageService _storage;
  MongoDBService? _mongodb; // Make nullable to handle connection failures
  User? _currentUser;

  AuthService._();

  static Future<AuthService> getInstance() async {
    if (_instance == null) {
      _instance = AuthService._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    _storage = await LocalStorageService.getInstance();

    try {
      _mongodb = await MongoDBService.getInstance();
    } catch (e) {
      print(
        'Warning: MongoDB connection failed during auth initialization: $e',
      );
      // Continue without MongoDB - we'll use offline mode
    }

    // Try to restore user session
    await _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final token = _storage.getAuthToken();
      if (token != null) {
        // Try to validate the token
        try {
          // Simple token validation - check if it contains expected parts
          final parts = token.split('.');
          if (parts.length >= 2) {
            // Token seems valid, restore user
            _currentUser = _storage.getUser();

            // If no user found but token exists, try to create admin user for testing
            if (_currentUser == null) {
              await _createTestAdminUser();
            }
          } else {
            // Invalid token format, clear it
            print('Invalid token format, clearing auth: $token');
            await _storage.clearAuth();
          }
        } catch (e) {
          // Invalid token format, clear it
          print('Invalid token format, clearing auth: $e');
          await _storage.clearAuth();
        }
      } else {
        // No token, try to create admin user for testing
        await _createTestAdminUser();
      }
    } catch (e) {
      print('Error restoring session: $e');
      // Clear any corrupted data
      await _storage.clearAuth();
    }
  }

  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthenticationException('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Verify the Google token (simplified - in production, verify with Google's API)
      if (googleAuth.idToken == null) {
        throw AuthenticationException('Failed to get Google ID token');
      }

      // Extract user info from Google token
      final userInfo = JwtDecoder.decode(googleAuth.idToken!);
      final email = userInfo['email'] as String;
      final name = userInfo['name'] as String? ?? '';
      final picture = userInfo['picture'] as String? ?? '';

      // Check if user exists in MongoDB
      User? user;
      try {
        user = await _mongodb?.getUserByEmail(email);
      } catch (e) {
        print('Warning: Could not check user in MongoDB: $e');
      }

      if (user == null) {
        // Create new user
        user = User(
          id: ObjectId(),
          email: email,
          name: name,
          avatarUrl: picture,
          role: UserRole.student,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        try {
          await _mongodb?.createUser(user);
        } catch (e) {
          print('Warning: Could not save user to MongoDB: $e');
          // Save locally for offline use
          await _storage.saveUser(user);
        }
      }

      // Create our own JWT token for session management
      final sessionToken = _createSessionToken(user);
      await _storage.saveAuthToken(sessionToken);

      // Save user data locally
      await _storage.saveUser(user);
      _currentUser = user;

      return user;
    } catch (e) {
      throw AuthenticationException(e.toString());
    }
  }

  Future<User> signInWithEmailPassword(String email, String password) async {
    // Validate input
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }

    // Hash the password
    final hashedPassword = password.hashCode.toString();

    print('Working in offline mode, checking local storage only');
    print('Looking for user: $email with hash: $hashedPassword');

    // Try local storage
    final user = await _storage.getUserByEmailAndPassword(
      email,
      hashedPassword,
    );

    if (user == null) {
      print('User not found or wrong password');
      throw Exception('Invalid email or password');
    }

    print('User found: ${user.name} (${user.role})');

    // Create session token
    final sessionToken = _createSessionToken(user);
    await _storage.saveAuthToken(sessionToken);
    await _storage.saveUser(user);
    _currentUser = user;

    return user;
  }

  Future<User> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw AuthenticationException('All fields are required');
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw AuthenticationException('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw AuthenticationException(
          'Password must be at least 6 characters long',
        );
      }

      // Check if user exists locally first
      final localUser = _storage.getUserByEmail(email);
      if (localUser != null) {
        throw AuthenticationException('User already exists with this email');
      }

      // Skip MongoDB check for now - working in offline mode
      print('Working in offline mode, skipping MongoDB user check');

      // Hash the password
      final hashedPassword = password.hashCode.toString();

      // Create new user
      final user = User(
        id: ObjectId(),
        email: email,
        name: name,
        avatarUrl: '',
        role: UserRole.student,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Skip MongoDB save for now - working in offline mode
      print('Working in offline mode, skipping MongoDB save');

      // Always store locally with password hash for offline use
      await _storage.saveUserWithPassword(user, hashedPassword);

      // Create session token
      final sessionToken = _createSessionToken(user);
      await _storage.saveAuthToken(sessionToken);
      await _storage.saveUser(user);
      _currentUser = user;

      return user;
    } catch (e) {
      if (e is AuthenticationException) {
        rethrow;
      }
      throw AuthenticationException('Sign up failed: ${e.toString()}');
    }
  }

  String _createSessionToken(User user) {
    // Simple JWT-like token (in production, use proper JWT library)
    final payload = {
      'userId': user.id.oid,
      'email': user.email,
      'exp': DateTime.now()
          .add(const Duration(days: 30))
          .millisecondsSinceEpoch,
    };

    final payloadBase64 = base64Url.encode(utf8.encode(json.encode(payload)));
    final signature = _hashPassword('${payloadBase64}your-secret-key');

    return '$payloadBase64.$signature';
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode('${password}your-salt-key');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _createTestAdminUser() async {
    try {
      // Check if admin user already exists locally
      final existingUser = _storage.getUserByEmail('admin@comptron.dev');
      if (existingUser != null) {
        print('Admin user found in storage');
        return;
      }

      print('No admin user found, but main.dart should have created one');
    } catch (e) {
      print('Error checking for admin user: $e');
    }
  }

  Future<void> signOut() async {
    await Future.wait([_googleSignIn.signOut(), _storage.clearAuth()]);
    _currentUser = null;
  }

  bool get isAuthenticated {
    final token = _storage.getAuthToken();
    return token != null &&
        !JwtDecoder.isExpired(token) &&
        _currentUser != null;
  }

  User? get currentUser => _currentUser;
}

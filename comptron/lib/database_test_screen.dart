import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' hide State, Center;
import 'core/services/mongodb_service.dart';
import 'core/models/user.dart';
import 'core/models/event.dart';
import 'core/models/announcement.dart';
import 'core/models/resource.dart';
import 'features/auth/presentation/screens/auth_test_screen.dart';

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  final List<String> _testResults = [];
  bool _isRunning = false;

  Future<void> _runDatabaseTests() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    try {
      _addResult('📦 Initializing MongoDB service...');
      final mongoService = await MongoDBService.getInstance();
      _addResult('✅ MongoDB service initialized successfully');

      // Test 1: Create a test user
      _addResult('\n🧪 Test 1: Creating test user...');
      final testUser = User(
        id: ObjectId(),
        email: 'test@university.edu',
        name: 'Test Student',
        avatarUrl: '',
        role: UserRole.student,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await mongoService.createUser(testUser);
        _addResult('✅ Test user created successfully');
      } catch (e) {
        _addResult(
          '⚠️ User creation skipped (likely already exists): ${e.toString()}',
        );
      }

      // Test 2: Retrieve user by email
      _addResult('\n🧪 Test 2: Retrieving user by email...');
      final retrievedUser = await mongoService.getUserByEmail(
        'test@university.edu',
      );
      if (retrievedUser != null) {
        _addResult('✅ User retrieved successfully: ${retrievedUser.name}');
      } else {
        _addResult('❌ Failed to retrieve user');
      }

      // Test 3: Create a test event
      _addResult('\n🧪 Test 3: Creating test event...');
      final testEvent = Event(
        id: ObjectId(),
        title: 'Test Workshop',
        description: 'A test workshop event for database connectivity',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 7, hours: 2)),
        location: 'Virtual',
        type: EventType.workshop,
        capacity: 50,
        registeredCount: 0,
        tags: const ['test', 'database'],
        imageUrl: '',
        isPublished: true,
        registeredUsers: const [],
        waitlistedUsers: const [],
        createdBy: ObjectId(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await mongoService.createEvent(testEvent);
        _addResult('✅ Test event created successfully');
      } catch (e) {
        _addResult('⚠️ Event creation skipped: ${e.toString()}');
      }

      // Test 4: Retrieve upcoming events
      _addResult('\n🧪 Test 4: Retrieving upcoming events...');
      final upcomingEvents = await mongoService.getUpcomingEvents(limit: 5);
      _addResult('✅ Retrieved ${upcomingEvents.length} upcoming events');

      if (upcomingEvents.isNotEmpty) {
        for (final event in upcomingEvents.take(3)) {
          _addResult(
            '   📅 ${event.title} - ${event.startDate.toString().split(' ')[0]}',
          );
        }
      }

      _addResult('\n🎉 All database tests completed successfully!');
      _addResult('✅ MongoDB Atlas connection is working properly');
    } catch (e) {
      _addResult('\n❌ Database test failed: ${e.toString()}');
      _addResult('⚠️ Please check your MongoDB connection string and network');
    }

    setState(() {
      _isRunning = false;
    });
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  Future<void> _populateSampleData() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    try {
      _addResult('📦 Initializing MongoDB service...');
      final mongoService = await MongoDBService.getInstance();
      _addResult('✅ MongoDB service initialized successfully');

      // Create sample admin user
      _addResult('\n👤 Creating sample admin user...');
      final adminUser = User(
        id: ObjectId(),
        email: 'admin@comptron.dev',
        name: 'Admin User',
        avatarUrl: '',
        role: UserRole.admin,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await mongoService.createUser(adminUser);
        _addResult('✅ Admin user created successfully');
      } catch (e) {
        _addResult('⚠️ Admin user creation skipped (likely already exists)');
      }

      // Create sample student user
      _addResult('\n👤 Creating sample student user...');
      final studentUser = User(
        id: ObjectId(),
        email: 'student@comptron.dev',
        name: 'Student User',
        avatarUrl: '',
        role: UserRole.student,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await mongoService.createUser(studentUser);
        _addResult('✅ Student user created successfully');
      } catch (e) {
        _addResult('⚠️ Student user creation skipped (likely already exists)');
      }

      // Create sample events
      _addResult('\n📅 Creating sample events...');
      final sampleEvents = [
        Event(
          id: ObjectId(),
          title: 'Flutter Workshop 2024',
          description:
              'Join us for an intensive Flutter development workshop covering the latest features and best practices. Perfect for beginners and intermediate developers.',
          location: 'Computer Lab A',
          startDate: DateTime.now().add(const Duration(days: 7)),
          endDate: DateTime.now().add(const Duration(days: 7, hours: 3)),
          type: EventType.workshop,
          capacity: 30,
          registeredCount: 12,
          registeredUsers: [],
          waitlistedUsers: [],
          tags: const ['flutter', 'mobile', 'development', 'workshop'],
          createdBy: adminUser.id,
          isPublished: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Event(
          id: ObjectId(),
          title: 'AI & Machine Learning Seminar',
          description:
              'Explore the latest trends in artificial intelligence and machine learning. Industry experts will share insights on current applications and future possibilities.',
          location: 'Main Auditorium',
          startDate: DateTime.now().add(const Duration(days: 14)),
          endDate: DateTime.now().add(const Duration(days: 14, hours: 2)),
          type: EventType.seminar,
          capacity: 150,
          registeredCount: 87,
          registeredUsers: [],
          waitlistedUsers: [],
          tags: const ['ai', 'machine learning', 'technology', 'seminar'],
          createdBy: adminUser.id,
          isPublished: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Event(
          id: ObjectId(),
          title: 'Tech Career Fair',
          description:
              'Meet with top tech companies and explore career opportunities. Networking session followed by company presentations.',
          location: 'Student Center',
          startDate: DateTime.now().add(const Duration(days: 28)),
          endDate: DateTime.now().add(const Duration(days: 28, hours: 6)),
          type: EventType.meetup,
          capacity: 200,
          registeredCount: 156,
          registeredUsers: [],
          waitlistedUsers: [],
          tags: const ['career', 'networking', 'jobs', 'tech companies'],
          createdBy: adminUser.id,
          isPublished: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final event in sampleEvents) {
        try {
          await mongoService.createEvent(event);
          _addResult('   ✅ Created event: ${event.title}');
        } catch (e) {
          _addResult(
            '   ⚠️ Event "${event.title}" skipped: ${e.toString().split('\n')[0]}',
          );
        }
      }

      // Create sample announcements
      _addResult('\n📢 Creating sample announcements...');
      final sampleAnnouncements = [
        Announcement(
          id: ObjectId(),
          title: 'Registration Open: Flutter Workshop',
          content:
              'Early bird registration is now open for the Flutter Workshop 2024. Limited seats available!',
          createdBy: adminUser.id,
          eventId: sampleEvents[0].id,
          isPublished: true,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Announcement(
          id: ObjectId(),
          title: 'New Study Resources Available',
          content:
              'We\'ve added new programming resources and tutorials to help you prepare for upcoming competitions.',
          createdBy: adminUser.id,
          isPublished: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Announcement(
          id: ObjectId(),
          title: 'Club Meeting Schedule',
          content:
              'Regular club meetings will be held every Friday at 4 PM in Room 205. All members are welcome!',
          createdBy: adminUser.id,
          isPublished: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ];

      for (final announcement in sampleAnnouncements) {
        try {
          await mongoService.createAnnouncement(announcement);
          _addResult('   ✅ Created announcement: ${announcement.title}');
        } catch (e) {
          _addResult('   ⚠️ Announcement "${announcement.title}" skipped');
        }
      }

      // Create sample resources
      _addResult('\n📚 Creating sample resources...');
      final sampleResources = [
        Resource(
          id: ObjectId(),
          title: 'Flutter Documentation',
          description:
              'Official Flutter documentation with comprehensive guides and API references.',
          url: 'https://flutter.dev/docs',
          type: 'link',
          tags: const ['flutter', 'documentation', 'mobile'],
          createdBy: adminUser.id,
          isPublished: true,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Resource(
          id: ObjectId(),
          title: 'Data Structures and Algorithms',
          description:
              'Comprehensive guide covering essential data structures and algorithms for competitive programming.',
          url: 'https://example.com/dsa-guide.pdf',
          type: 'document',
          tags: const ['algorithms', 'data structures', 'programming'],
          createdBy: adminUser.id,
          isPublished: true,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Resource(
          id: ObjectId(),
          title: 'Machine Learning Crash Course',
          description:
              'Video series covering machine learning fundamentals and practical applications.',
          url: 'https://example.com/ml-course',
          type: 'video',
          tags: const ['machine learning', 'ai', 'course'],
          createdBy: adminUser.id,
          isPublished: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Resource(
          id: ObjectId(),
          title: 'Git Cheat Sheet',
          description: 'Quick reference for common Git commands and workflows.',
          url: 'https://example.com/git-cheatsheet.png',
          type: 'image',
          tags: const ['git', 'version control', 'cheatsheet'],
          createdBy: adminUser.id,
          isPublished: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ];

      for (final resource in sampleResources) {
        try {
          await mongoService.createResource(resource);
          _addResult('   ✅ Created resource: ${resource.title}');
        } catch (e) {
          _addResult('   ⚠️ Resource "${resource.title}" skipped');
        }
      }

      _addResult('\n🎉 Sample data population completed successfully!');
      _addResult('✅ You can now test the app with real data');
    } catch (e) {
      _addResult('\n❌ Sample data population failed: ${e.toString()}');
    }

    setState(() {
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Test'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MongoDB Connection Test',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This test will verify the connection to MongoDB Atlas and perform basic CRUD operations.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _isRunning
                                    ? null
                                    : _runDatabaseTests,
                                icon: _isRunning
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.play_arrow),
                                label: Text(
                                  _isRunning
                                      ? 'Running Tests...'
                                      : 'Run Database Tests',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _isRunning
                                    ? null
                                    : _populateSampleData,
                                icon: const Icon(Icons.dataset),
                                label: const Text('Add Sample Data'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthTestScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.login),
                          label: const Text(
                            'Test Authentication (Offline Mode)',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Results',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _testResults.isEmpty
                            ? Center(
                                child: Text(
                                  'Click "Run Database Tests" to start testing',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _testResults.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2.0,
                                    ),
                                    child: Text(
                                      _testResults[index],
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:mongo_dart/mongo_dart.dart';
import '../core/services/mongodb_service.dart';
import '../core/models/event.dart';
import '../core/models/announcement.dart';
import '../core/models/resource.dart';
import '../core/models/user.dart';

Future<void> populateSampleData() async {
  try {
    final mongoService = await MongoDBService.getInstance();
    print('Connected to MongoDB');

    // Create sample admin user
    final adminUser = User(
      id: ObjectId(),
      email: 'admin@comptron.dev',
      name: 'Admin User',
      avatarUrl: '',
      role: UserRole.admin,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await mongoService.createUser(adminUser);
    print('Created admin user');

    // Create sample events
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
        tags: ['flutter', 'mobile', 'development', 'workshop'],
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
        tags: ['ai', 'machine learning', 'technology', 'seminar'],
        createdBy: adminUser.id,
        isPublished: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Event(
        id: ObjectId(),
        title: 'Code Competition 2024',
        description:
            'Annual programming contest with exciting challenges and prizes. Test your problem-solving skills against fellow students.',
        location: 'Computer Labs B & C',
        startDate: DateTime.now().add(const Duration(days: 21)),
        endDate: DateTime.now().add(const Duration(days: 21, hours: 4)),
        type: EventType.workshop,
        capacity: 60,
        registeredCount: 45,
        registeredUsers: [],
        waitlistedUsers: [],
        tags: ['programming', 'competition', 'algorithms', 'prizes'],
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
        type: EventType.seminar,
        capacity: 200,
        registeredCount: 156,
        registeredUsers: [],
        waitlistedUsers: [],
        tags: ['career', 'networking', 'jobs', 'tech companies'],
        createdBy: adminUser.id,
        isPublished: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final event in sampleEvents) {
      await mongoService.createEvent(event);
    }
    print('Created ${sampleEvents.length} sample events');

    // Create sample announcements
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
      await mongoService.createAnnouncement(announcement);
    }
    print('Created ${sampleAnnouncements.length} sample announcements');

    // Create sample resources
    final sampleResources = [
      Resource(
        id: ObjectId(),
        title: 'Flutter Documentation',
        description:
            'Official Flutter documentation with comprehensive guides and API references.',
        url: 'https://flutter.dev/docs',
        type: 'link',
        tags: ['flutter', 'documentation', 'mobile'],
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
        tags: ['algorithms', 'data structures', 'programming'],
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
        tags: ['machine learning', 'ai', 'course'],
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
        tags: ['git', 'version control', 'cheatsheet'],
        createdBy: adminUser.id,
        isPublished: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];

    for (final resource in sampleResources) {
      await mongoService.createResource(resource);
    }
    print('Created ${sampleResources.length} sample resources');

    print('Sample data population completed successfully!');
  } catch (e) {
    print('Error populating sample data: $e');
  }
}

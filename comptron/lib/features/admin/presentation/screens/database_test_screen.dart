import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' hide State;
import '../../../../core/services/mongodb_service.dart';
import '../../../../core/models/event.dart';
import '../../../../core/models/announcement.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  bool _isConnected = false;
  bool _isLoading = false;
  String _statusMessage = 'Not tested';
  final List<String> _testResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Test'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomCard(
              child: Column(
                children: [
                  Icon(
                    _isConnected ? Icons.check_circle : Icons.error_outline,
                    size: 64,
                    color: _isConnected ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'MongoDB Connection',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusMessage,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Test Connection',
              isLoading: _isLoading,
              onPressed: _testConnection,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Add Sample Data',
              isOutlined: true,
              onPressed: _isConnected ? _addSampleData : null,
            ),
            const SizedBox(height: 24),
            if (_testResults.isNotEmpty) ...[
              Text(
                'Test Results:',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: CustomCard(
                  child: ListView.builder(
                    itemCount: _testResults.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '${index + 1}. ${_testResults[index]}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing connection...';
      _testResults.clear();
    });

    try {
      // Initialize MongoDB service
      await MongoDBService.getInstance();

      setState(() {
        _isConnected = true;
        _statusMessage = 'Connected successfully!';
        _testResults.add('✅ MongoDB connection established');
        _testResults.add('✅ Database initialized');
        _testResults.add('✅ Collections ready');
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _statusMessage = 'Connection failed: ${e.toString()}';
        _testResults.add('❌ Connection failed: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addSampleData() async {
    if (!_isConnected) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final mongoService = await MongoDBService.getInstance();

      // Create sample event
      final sampleEvent = Event(
        id: ObjectId(),
        title: 'Flutter Workshop 2025',
        description:
            'Learn Flutter development with hands-on projects and expert guidance.',
        imageUrl:
            'https://images.unsplash.com/photo-1551434678-e076c223a692?w=500',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 7, hours: 3)),
        location: 'Tech Center, Room 101',
        type: EventType.workshop,
        tags: ['Flutter', 'Mobile Development', 'Programming'],
        capacity: 50,
        isPublished: true,
        createdBy: ObjectId(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await mongoService.createEvent(sampleEvent);

      // Create sample announcement
      final sampleAnnouncement = Announcement(
        id: ObjectId(),
        title: 'Welcome to Comptron!',
        content:
            'We are excited to have you join our university club events platform. Stay tuned for upcoming workshops, seminars, and networking events.',
        priority: AnnouncementPriority.high,
        isPublished: true,
        createdBy: ObjectId(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await mongoService.createAnnouncement(sampleAnnouncement);

      setState(() {
        _testResults.add('✅ Sample event created');
        _testResults.add('✅ Sample announcement created');
        _testResults.add('✅ Sample data added successfully');
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample data added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _testResults.add('❌ Failed to add sample data: $e');
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add sample data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

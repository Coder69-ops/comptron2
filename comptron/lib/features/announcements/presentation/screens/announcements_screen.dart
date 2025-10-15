import 'package:flutter/material.dart';
import '../../../../core/models/announcement.dart';
import '../../../../core/services/mongodb_service.dart';
import '../widgets/announcement_card.dart';
import '../../../../core/widgets/custom_card.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<Announcement> _announcements = []; // Will be populated from API
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final mongoService = await MongoDBService.getInstance();
      final announcements = await mongoService.getAnnouncements(limit: 50);

      if (mounted) {
        setState(() {
          _announcements = announcements;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _announcements = [];
          _isLoading = false;
        });
      }

      // Log error silently
      print('Announcements loading error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notification settings
            },
          ),
        ],
      ),
      body: _isLoading
          ? ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => const LoadingCard(),
            )
          : _announcements.isEmpty
          ? const EmptyStateCard(
              title: 'No Announcements',
              message: 'There are no announcements at the moment.',
              icon: Icons.announcement,
            )
          : RefreshIndicator(
              onRefresh: _loadAnnouncements,
              child: ListView.builder(
                itemCount: _announcements.length,
                itemBuilder: (context, index) {
                  final announcement = _announcements[index];
                  return AnnouncementCard(
                    announcement: announcement,
                    onTap: () {
                      // Navigate to announcement details
                      _showAnnouncementDetails(context, announcement);
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: "announcements_fab",
        onPressed: () {
          // TODO: Implement add announcement (for admin)
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAnnouncementDetails(
    BuildContext context,
    Announcement announcement,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(
                        announcement.priority,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      announcement.priority.label,
                      style: TextStyle(
                        color: _getPriorityColor(announcement.priority),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(announcement.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                announcement.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    announcement.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.high:
        return Colors.red;
      case AnnouncementPriority.medium:
        return Colors.orange;
      case AnnouncementPriority.low:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

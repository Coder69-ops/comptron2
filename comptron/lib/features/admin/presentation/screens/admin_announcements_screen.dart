import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' hide State, Center;
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/models/user.dart';
import '../../../../core/models/announcement.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/mongodb_service.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() =>
      _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  User? _currentUser;
  bool _isLoading = true;
  bool _isLoadingAnnouncements = false;
  List<Announcement> _announcements = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authService = await AuthService.getInstance();
      setState(() {
        _currentUser = authService.currentUser;
        _isLoading = false;
      });
      if (_currentUser?.role == UserRole.admin) {
        _loadAnnouncements();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoadingAnnouncements = true;
      _error = '';
    });

    try {
      final mongoService = await MongoDBService.getInstance();
      final announcements = await mongoService.getAnnouncements(limit: 50);

      setState(() {
        _announcements = announcements;
        _isLoadingAnnouncements = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to load announcements. Working in offline mode.';
        _isLoadingAnnouncements = false;
      });
    }
  }

  Future<void> _deleteAnnouncement(Announcement announcement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: Text(
          'Are you sure you want to delete "${announcement.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final mongoService = await MongoDBService.getInstance();
        await mongoService.deleteAnnouncement(announcement.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Announcement "${announcement.title}" deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }

        _loadAnnouncements();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete announcement: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _togglePublished(Announcement announcement) async {
    try {
      final mongoService = await MongoDBService.getInstance();
      await mongoService.updateAnnouncement(
        announcement.id,
        announcement.copyWith(isPublished: !announcement.isPublished),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              announcement.isPublished
                  ? 'Announcement unpublished'
                  : 'Announcement published',
            ),
            backgroundColor: Colors.blue,
          ),
        );
      }

      _loadAnnouncements();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update announcement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateAnnouncementDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    AnnouncementPriority priority = AnnouncementPriority.medium;
    bool isPublished = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Announcement'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AnnouncementPriority>(
                  value: priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: AnnouncementPriority.values.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p.label));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      priority = value ?? AnnouncementPriority.medium;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Publish immediately'),
                  value: isPublished,
                  onChanged: (value) {
                    setDialogState(() {
                      isPublished = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty ||
                    contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final mongoService = await MongoDBService.getInstance();
                  final announcement = Announcement(
                    id: ObjectId(),
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    priority: priority,
                    isPublished: isPublished,
                    createdBy: _currentUser!.id,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  await mongoService.createAnnouncement(announcement);

                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Announcement created successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }

                  _loadAnnouncements();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create announcement: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Security check - only allow admin users
    if (_currentUser?.role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Admin Access Required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You need admin privileges to access this section.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Management'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnnouncements,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoadingAnnouncements
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _loadAnnouncements,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _announcements.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Announcements',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first announcement to get started.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _announcements.length,
              itemBuilder: (context, index) {
                final announcement = _announcements[index];
                return _buildAnnouncementCard(announcement);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateAnnouncementDialog,
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: announcement.isPublished
                      ? Colors.green[100]
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      announcement.isPublished
                          ? Icons.check_circle
                          : Icons.schedule,
                      size: 14,
                      color: announcement.isPublished
                          ? Colors.green[700]
                          : Colors.orange[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      announcement.isPublished ? 'Published' : 'Draft',
                      style: TextStyle(
                        color: announcement.isPublished
                            ? Colors.green[700]
                            : Colors.orange[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(
                    announcement.priority,
                  ).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  announcement.priority.label,
                  style: TextStyle(
                    color: _getPriorityColor(announcement.priority),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'publish':
                      _togglePublished(announcement);
                      break;
                    case 'delete':
                      _deleteAnnouncement(announcement);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'publish',
                    child: ListTile(
                      leading: Icon(
                        announcement.isPublished
                            ? Icons.unpublished
                            : Icons.publish,
                        color: announcement.isPublished
                            ? Colors.orange[700]
                            : Colors.green[700],
                      ),
                      title: Text(
                        announcement.isPublished ? 'Unpublish' : 'Publish',
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            announcement.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            announcement.content,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Created ${_formatDate(announcement.createdAt)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.low:
        return Colors.blue[600]!;
      case AnnouncementPriority.medium:
        return Colors.orange[600]!;
      case AnnouncementPriority.high:
        return Colors.red[600]!;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

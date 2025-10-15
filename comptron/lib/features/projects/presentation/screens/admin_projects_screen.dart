import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' hide State, Project, Center;
import '../../../../core/models/project.dart';
import '../../../../core/services/mongodb_service.dart';
import 'project_details_screen.dart';

class AdminProjectsScreen extends StatefulWidget {
  const AdminProjectsScreen({super.key});

  @override
  State<AdminProjectsScreen> createState() => _AdminProjectsScreenState();
}

class _AdminProjectsScreenState extends State<AdminProjectsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<Project> _pendingProjects = [];
  final List<Project> _approvedProjects = [];
  final List<Project> _rejectedProjects = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProjects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final mongoService = await MongoDBService.getInstance();

      final pending = await mongoService.getProjectsByStatus(
        ProjectStatus.pending,
      );
      final approved = await mongoService.getProjectsByStatus(
        ProjectStatus.approved,
        limit: 20,
      );
      final rejected = await mongoService.getProjectsByStatus(
        ProjectStatus.rejected,
        limit: 20,
      );

      setState(() {
        _pendingProjects.clear();
        _pendingProjects.addAll(pending);
        _approvedProjects.clear();
        _approvedProjects.addAll(approved);
        _rejectedProjects.clear();
        _rejectedProjects.addAll(rejected);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to connect to server. Working in offline mode.';
        print('Admin projects loading error: $e');
        _isLoading = false;
      });
    }
  }

  Future<void> _approveProject(Project project) async {
    try {
      final mongoService = await MongoDBService.getInstance();
      // TODO: Replace with actual admin user ID from authentication
      final adminId = ObjectId();
      await mongoService.approveProject(project.id, adminId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${project.title}" approved'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _loadProjects();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectProject(Project project) async {
    final reason = await _showRejectDialog();
    if (reason == null || reason.isEmpty) return;

    try {
      final mongoService = await MongoDBService.getInstance();
      await mongoService.rejectProject(project.id, reason);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${project.title}" rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      _loadProjects();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending (${_pendingProjects.length})'),
            Tab(text: 'Approved (${_approvedProjects.length})'),
            Tab(text: 'Rejected (${_rejectedProjects.length})'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
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
                    onPressed: _loadProjects,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProjectList(_pendingProjects, true),
                _buildProjectList(_approvedProjects, false),
                _buildProjectList(_rejectedProjects, false),
              ],
            ),
    );
  }

  Widget _buildProjectList(List<Project> projects, bool showActions) {
    if (projects.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64),
            SizedBox(height: 16),
            Text('No projects found'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: project.imageUrl.isNotEmpty
                  ? NetworkImage(project.imageUrl)
                  : null,
              child: project.imageUrl.isEmpty
                  ? const Icon(Icons.lightbulb_outline)
                  : null,
            ),
            title: Text(
              project.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('by ${project.authorName}'),
                const SizedBox(height: 4),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (project.rejectionReason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Reason: ${project.rejectionReason}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: project.tags.take(3).map((tag) {
                    return Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ),
            trailing: showActions
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProjectDetailsScreen(project: project),
                            ),
                          );
                          break;
                        case 'approve':
                          _approveProject(project);
                          break;
                        case 'reject':
                          _rejectProject(project);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility),
                          title: Text('View Details'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'approve',
                        child: ListTile(
                          leading: Icon(Icons.check, color: Colors.green),
                          title: Text('Approve'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'reject',
                        child: ListTile(
                          leading: Icon(Icons.close, color: Colors.red),
                          title: Text('Reject'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  )
                : IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProjectDetailsScreen(project: project),
                        ),
                      );
                    },
                  ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectDetailsScreen(project: project),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

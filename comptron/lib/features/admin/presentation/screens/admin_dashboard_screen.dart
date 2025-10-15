import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/models/user.dart';
import '../../../../core/models/event.dart';
import '../../../../core/models/announcement.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/mongodb_service.dart';
import 'quick_db_test.dart';
import '../../../projects/presentation/screens/admin_projects_screen.dart';
import 'admin_announcements_screen.dart';
import 'admin_resources_screen.dart';
import 'admin_events_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  User? _currentUser;
  bool _isLoading = true;
  bool _isLoadingStats = true;

  // Statistics
  int _totalEvents = 0;
  int _upcomingEvents = 0;
  int _totalAnnouncements = 0;
  int _publishedAnnouncements = 0;
  int _totalResources = 0;
  int _activeUsers = 0;
  List<Event> _recentEvents = [];
  List<Announcement> _recentAnnouncements = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStatistics();
  }

  Future<void> _loadUserData() async {
    try {
      final authService = await AuthService.getInstance();
      setState(() {
        _currentUser = authService.currentUser;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final mongoService = await MongoDBService.getInstance();

      // Load events
      final allEvents = await mongoService.getEvents(limit: 100);
      final upcomingEvents = await mongoService.getUpcomingEvents(limit: 50);

      // Load announcements
      final allAnnouncements = await mongoService.getAnnouncements(limit: 100);
      final publishedAnnouncements = allAnnouncements
          .where((a) => a.isPublished)
          .toList();

      // Load resources
      final allResources = await mongoService.getResources(limit: 100);

      // Get recent items for activity feed
      final recentEvents = allEvents.take(5).toList();
      final recentAnnouncements = allAnnouncements.take(5).toList();

      setState(() {
        _totalEvents = allEvents.length;
        _upcomingEvents = upcomingEvents.length;
        _totalAnnouncements = allAnnouncements.length;
        _publishedAnnouncements = publishedAnnouncements.length;
        _totalResources = allResources.length;
        _activeUsers = 1; // For now, just the admin user
        _recentEvents = recentEvents;
        _recentAnnouncements = recentAnnouncements;
        _isLoadingStats = false;
      });
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoadingStats = true;
    });
    await _loadStatistics();
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
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              CustomCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.red[100],
                          child: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.red[600],
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${_currentUser?.name ?? 'Admin'}',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'System Administrator',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'ADMIN',
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: Colors.green[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'ONLINE',
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            context,
                            Icons.event_available,
                            'Create Event',
                            Colors.blue,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminEventsScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildQuickAction(
                            context,
                            Icons.campaign,
                            'Announcement',
                            Colors.orange,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AdminAnnouncementsScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildQuickAction(
                            context,
                            Icons.folder_shared,
                            'Resource',
                            Colors.purple,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AdminResourcesScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Statistics Overview
              Row(
                children: [
                  Text(
                    'System Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_isLoadingStats)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Primary Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedStatCard(
                      context,
                      'Total Events',
                      _isLoadingStats ? '-' : _totalEvents.toString(),
                      Icons.event,
                      Colors.blue,
                      subtitle: _isLoadingStats
                          ? ''
                          : '$_upcomingEvents upcoming',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEnhancedStatCard(
                      context,
                      'Announcements',
                      _isLoadingStats ? '-' : _totalAnnouncements.toString(),
                      Icons.campaign,
                      Colors.orange,
                      subtitle: _isLoadingStats
                          ? ''
                          : '$_publishedAnnouncements published',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Secondary Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedStatCard(
                      context,
                      'Resources',
                      _isLoadingStats ? '-' : _totalResources.toString(),
                      Icons.folder,
                      Colors.purple,
                      subtitle: 'Learning materials',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEnhancedStatCard(
                      context,
                      'Active Users',
                      _isLoadingStats ? '-' : _activeUsers.toString(),
                      Icons.people,
                      Colors.green,
                      subtitle: 'System users',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Management Functions
              Text(
                'Management Functions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Content Management Section
              _buildSectionCard(
                context,
                'Content Management',
                'Create and manage app content',
                [
                  _buildFunctionTile(
                    context,
                    Icons.event,
                    'Event Management',
                    'Create, edit, and manage events',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminEventsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildFunctionTile(
                    context,
                    Icons.campaign,
                    'Announcements',
                    'Create and publish announcements',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AdminAnnouncementsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildFunctionTile(
                    context,
                    Icons.folder_shared,
                    'Resources',
                    'Manage learning resources and materials',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminResourcesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildFunctionTile(
                    context,
                    Icons.lightbulb_outline,
                    'Project Management',
                    'Review and approve student projects',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminProjectsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // System Administration Section
              _buildSectionCard(
                context,
                'System Administration',
                'Advanced system management and monitoring',
                [
                  _buildFunctionTile(
                    context,
                    Icons.people,
                    'User Management',
                    'Manage user accounts and permissions',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User management coming soon!'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                  _buildFunctionTile(
                    context,
                    Icons.analytics,
                    'Analytics Dashboard',
                    'View detailed app analytics and reports',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Analytics dashboard coming soon!'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                  _buildFunctionTile(
                    context,
                    Icons.settings,
                    'System Settings',
                    'Configure app settings and preferences',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('System settings coming soon!'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                  _buildFunctionTile(
                    context,
                    Icons.storage,
                    'Database Tools',
                    'Test database connection and operations',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuickDBTest(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              if (subtitle != null)
                Icon(Icons.trending_up, color: Colors.green[600], size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    String subtitle,
    List<Widget> children,
  ) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFunctionTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

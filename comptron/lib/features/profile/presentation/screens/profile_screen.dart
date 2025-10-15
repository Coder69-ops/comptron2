import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/models/user.dart';
import '../../../admin/presentation/screens/quick_db_test.dart';
import '../../../projects/presentation/screens/admin_projects_screen.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;

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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettings(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 24),
            _buildStatsSection(context),
            const SizedBox(height: 24),
            _buildMenuSection(context),
            const SizedBox(height: 24),
            _buildSignOutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(
              context,
            ).primaryColor.withValues(alpha: 0.1),
            backgroundImage:
                (_currentUser != null && _currentUser!.avatarUrl.isNotEmpty)
                ? NetworkImage(_currentUser!.avatarUrl)
                : null,
            child: (_currentUser == null || _currentUser!.avatarUrl.isEmpty)
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            _currentUser?.name ?? 'Unknown User',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _currentUser?.email ?? 'No email',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _currentUser?.role.toString().split('.').last.toUpperCase() ??
                  'USER',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem(context, 'Events Attended', '12')),
              Expanded(child: _buildStatItem(context, 'Upcoming Events', '3')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem(context, 'Badges Earned', '5')),
              Expanded(child: _buildStatItem(context, 'Points', '240')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          Icons.event,
          'My Events',
          'View registered events',
          () {},
        ),
        _buildMenuItem(
          context,
          Icons.favorite,
          'Favorites',
          'Manage favorite events',
          () {},
        ),
        _buildMenuItem(
          context,
          Icons.qr_code,
          'My QR Codes',
          'View event QR codes',
          () {},
        ),
        _buildMenuItem(
          context,
          Icons.notifications,
          'Notifications',
          'Manage notification settings',
          () {},
        ),
        _buildMenuItem(
          context,
          Icons.help,
          'Help & Support',
          'Get help and contact support',
          () {},
        ),
        // Admin-only menu items
        if (_currentUser?.role == UserRole.admin)
          ..._buildAdminMenuItems(context),
        // Developer tools (visible to all users for debugging)
        ..._buildDeveloperMenuItems(context),
        _buildMenuItem(
          context,
          Icons.info,
          'About',
          'App version and information',
          () {},
        ),
      ],
    );
  }

  List<Widget> _buildAdminMenuItems(BuildContext context) {
    return [
      // Admin Section Header
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.red[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'Admin Panel',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
          ],
        ),
      ),
      _buildMenuItem(
        context,
        Icons.dashboard,
        'Admin Dashboard',
        'Overview of all admin functions',
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            ),
          );
        },
        isAdminItem: true,
      ),
      _buildMenuItem(
        context,
        Icons.lightbulb_outline,
        'Manage Projects',
        'Review and approve student projects',
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminProjectsScreen(),
            ),
          );
        },
        isAdminItem: true,
      ),
      _buildMenuItem(
        context,
        Icons.event_note,
        'Manage Events',
        'Create and manage events',
        () {
          // TODO: Navigate to admin events screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin Events management coming soon!'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        isAdminItem: true,
      ),
      _buildMenuItem(
        context,
        Icons.announcement,
        'Manage Announcements',
        'Create and manage announcements',
        () {
          // TODO: Navigate to admin announcements screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin Announcements management coming soon!'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        isAdminItem: true,
      ),
      _buildMenuItem(
        context,
        Icons.folder_shared,
        'Manage Resources',
        'Create and manage learning resources',
        () {
          // TODO: Navigate to admin resources screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin Resources management coming soon!'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        isAdminItem: true,
      ),
      _buildMenuItem(
        context,
        Icons.people,
        'Manage Users',
        'View and manage user accounts',
        () {
          // TODO: Navigate to admin users screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User management coming soon!'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        isAdminItem: true,
      ),
    ];
  }

  List<Widget> _buildDeveloperMenuItems(BuildContext context) {
    return [
      // Developer Tools Section Header
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(
          children: [
            Icon(Icons.code, color: Colors.blue[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'Developer Tools',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
      ),
      _buildMenuItem(
        context,
        Icons.admin_panel_settings,
        'Setup Admin Account',
        'Create admin@comptron.dev with password: admin123',
        () => _setupAdminAccount(),
        isDevItem: true,
      ),
      _buildMenuItem(
        context,
        Icons.storage,
        'Database Test',
        'Test MongoDB connection and data',
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuickDBTest()),
          );
        },
        isDevItem: true,
      ),
    ];
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isAdminItem = false,
    bool isDevItem = false,
  }) {
    Color getItemColor() {
      if (isAdminItem) return Colors.red[600] ?? Colors.red;
      if (isDevItem) return Colors.blue[600] ?? Colors.blue;
      return Theme.of(context).primaryColor;
    }

    return CustomCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: getItemColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: isAdminItem
                  ? Border.all(color: Colors.red[200] ?? Colors.red, width: 1)
                  : null,
            ),
            child: Icon(icon, color: getItemColor()),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return CustomButton(
      text: 'Sign Out',
      onPressed: () {
        _showSignOutDialog(context);
      },
      isOutlined: true,
      width: double.infinity,
      color: Colors.red,
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Settings',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Push Notifications'),
              trailing: Switch(
                value: true, // TODO: Get from user preferences
                onChanged: (value) {
                  // TODO: Update notification settings
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: const Text('English'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show language selection
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setupAdminAccount() async {
    try {
      final authService = await AuthService.getInstance();
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text(
              'Please log in first, then use this button to create admin account.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Promoting to admin...'),
            ],
          ),
        ),
      );

      // For offline-first approach, we'll create a special admin account
      // You can either promote current user or create a dedicated admin account
      await authService.signUpWithEmailPassword(
        'admin@comptron.dev',
        'admin123',
        'Admin User',
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Admin Account Created!'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin account has been created successfully:'),
                SizedBox(height: 8),
                Text('Email: admin@comptron.dev'),
                Text('Password: admin123'),
                SizedBox(height: 8),
                Text(
                  'You can now sign out and log in with these credentials to access admin features.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to create admin account: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final authService = await AuthService.getInstance();
                await authService.signOut();
                if (mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to sign out: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

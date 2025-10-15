import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/navigation_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/announcements/presentation/screens/announcements_screen.dart';
import '../../features/projects/presentation/screens/projects_screen.dart';
import '../../features/resources/presentation/screens/resources_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

class BaseLayout extends StatelessWidget {
  const BaseLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationService(),
      child: const BaseLayoutContent(),
    );
  }
}

class BaseLayoutContent extends StatefulWidget {
  const BaseLayoutContent({super.key});

  @override
  State<BaseLayoutContent> createState() => _BaseLayoutContentState();
}

class _BaseLayoutContentState extends State<BaseLayoutContent>
    with TickerProviderStateMixin {
  late AnimationController _navAnimationController;
  late Animation<double> _navSlideAnimation;
  User? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _navSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _navAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _navAnimationController.forward();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authService = await AuthService.getInstance();
      setState(() {
        _currentUser = authService.currentUser;
        _isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  @override
  void dispose() {
    _navAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigationService = context.watch<NavigationService>();

    // Show loading while user data is being fetched
    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          // Add a subtle offline indicator if needed
          // This can be toggled based on connection status
          Container(
            height: 0, // Hidden for now, can be made visible when offline
            color: Colors.orange.withValues(alpha: 0.8),
            child: const Center(
              child: Text(
                'Working in offline mode',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  ),
                );
              },
              child: IndexedStack(
                key: ValueKey(navigationService.currentItem.index),
                index: _getAdjustedNavigationIndex(
                  navigationService.currentItem,
                ),
                children: _buildNavigationScreens(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(_navSlideAnimation),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NavigationBar(
              selectedIndex: _getDisplayIndex(navigationService.currentItem),
              onDestinationSelected: (index) {
                navigationService.navigateTo(
                  _getNavigationItemFromIndex(index),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              height: 70,
              destinations: _buildNavigationDestinations(navigationService),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavigationScreens() {
    final screens = <Widget>[
      const EventsScreen(),
      const AnnouncementsScreen(),
      const ProjectsScreen(),
      const ResourcesScreen(),
    ];

    // Only add admin screen if user is admin
    if (_currentUser?.role == UserRole.admin) {
      screens.add(const AdminDashboardScreen());
    }

    screens.add(const ProfileScreen());
    return screens;
  }

  List<NavigationDestination> _buildNavigationDestinations(
    NavigationService navigationService,
  ) {
    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: _buildNavIcon(
          Icons.event_outlined,
          Icons.event,
          0,
          _getDisplayIndex(navigationService.currentItem),
        ),
        label: 'Events',
      ),
      NavigationDestination(
        icon: _buildNavIcon(
          Icons.campaign_outlined,
          Icons.campaign,
          1,
          _getDisplayIndex(navigationService.currentItem),
        ),
        label: 'Announcements',
      ),
      NavigationDestination(
        icon: _buildNavIcon(
          Icons.lightbulb_outline,
          Icons.lightbulb,
          2,
          _getDisplayIndex(navigationService.currentItem),
        ),
        label: 'Projects',
      ),
      NavigationDestination(
        icon: _buildNavIcon(
          Icons.folder_outlined,
          Icons.folder,
          3,
          _getDisplayIndex(navigationService.currentItem),
        ),
        label: 'Resources',
      ),
    ];

    // Only add admin destination if user is admin
    if (_currentUser?.role == UserRole.admin) {
      destinations.add(
        NavigationDestination(
          icon: _buildNavIcon(
            Icons.admin_panel_settings_outlined,
            Icons.admin_panel_settings,
            4,
            _getDisplayIndex(navigationService.currentItem),
          ),
          label: 'Admin',
        ),
      );
    }

    // Profile is always last
    final profileIndex = _currentUser?.role == UserRole.admin ? 5 : 4;
    destinations.add(
      NavigationDestination(
        icon: _buildNavIcon(
          Icons.person_outline,
          Icons.person,
          profileIndex,
          _getDisplayIndex(navigationService.currentItem),
        ),
        label: 'Profile',
      ),
    );

    return destinations;
  }

  int _getAdjustedNavigationIndex(NavigationItem item) {
    switch (item) {
      case NavigationItem.events:
        return 0;
      case NavigationItem.announcements:
        return 1;
      case NavigationItem.projects:
        return 2;
      case NavigationItem.resources:
        return 3;
      case NavigationItem.admin:
        return _currentUser?.role == UserRole.admin
            ? 4
            : 5; // Fallback to profile if not admin
      case NavigationItem.profile:
        return _currentUser?.role == UserRole.admin ? 5 : 4;
    }
  }

  int _getDisplayIndex(NavigationItem item) {
    switch (item) {
      case NavigationItem.events:
        return 0;
      case NavigationItem.announcements:
        return 1;
      case NavigationItem.projects:
        return 2;
      case NavigationItem.resources:
        return 3;
      case NavigationItem.admin:
        return _currentUser?.role == UserRole.admin
            ? 4
            : -1; // -1 means not displayed
      case NavigationItem.profile:
        return _currentUser?.role == UserRole.admin ? 5 : 4;
    }
  }

  NavigationItem _getNavigationItemFromIndex(int index) {
    if (_currentUser?.role == UserRole.admin) {
      switch (index) {
        case 0:
          return NavigationItem.events;
        case 1:
          return NavigationItem.announcements;
        case 2:
          return NavigationItem.projects;
        case 3:
          return NavigationItem.resources;
        case 4:
          return NavigationItem.admin;
        case 5:
          return NavigationItem.profile;
        default:
          return NavigationItem.events;
      }
    } else {
      switch (index) {
        case 0:
          return NavigationItem.events;
        case 1:
          return NavigationItem.announcements;
        case 2:
          return NavigationItem.projects;
        case 3:
          return NavigationItem.resources;
        case 4:
          return NavigationItem.profile;
        default:
          return NavigationItem.events;
      }
    }
  }

  Widget _buildNavIcon(
    IconData outlinedIcon,
    IconData filledIcon,
    int index,
    int selectedIndex,
  ) {
    final isSelected = index == selectedIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isSelected ? filledIcon : outlinedIcon,
        color: isSelected
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

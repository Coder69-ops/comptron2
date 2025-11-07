import 'package:flutter/material.dart';
import '../../../../core/models/event.dart';
import '../../../../core/services/mongodb_service.dart';
import '../widgets/event_filters.dart';
import '../../../../core/widgets/custom_card.dart';
import 'event_details_screen.dart';
import '../../../../sample_data_populator.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Event> _events = []; // Will be populated from API
  List<Event> _filteredEvents = [];
  EventType? _selectedType;
  List<String> _selectedTags = [];
  bool _isLoading = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final mongoService = await MongoDBService.getInstance();
      // Try to get upcoming events first, fall back to all events if none found
      List<Event> events = await mongoService.getUpcomingEvents(limit: 50);

      // If no upcoming events, try to get all events
      if (events.isEmpty) {
        events = await mongoService.getEvents(limit: 50);
      }

      if (mounted) {
        setState(() {
          _events = events;
          _filteredEvents = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _events = [];
          _filteredEvents = [];
        });
      }

      // Show error message for debugging
      print('Events loading error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load events: $e'),
            action: SnackBarAction(label: 'Retry', onPressed: _loadEvents),
          ),
        );
      }
    }

    if (mounted) {
      _fadeController.forward();
    }
  }

  Future<void> _populateSampleData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await populateSampleData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample events created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reload events after populating sample data
      await _loadEvents();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create sample data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterEvents() {
    setState(() {
      _filteredEvents = _events.where((event) {
        final matchesSearch = event.title.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        );
        final matchesType =
            _selectedType == null || event.type == _selectedType;
        final matchesTags =
            _selectedTags.isEmpty ||
            _selectedTags.any((tag) => event.tags.contains(tag));

        return matchesSearch && matchesType && matchesTags;
      }).toList();
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: EventFilters(
          selectedType: _selectedType,
          selectedTags: _selectedTags,
          onTypeChanged: (type) {
            setState(() {
              _selectedType = type;
            });
            _filterEvents();
          },
          onTagsChanged: (tags) {
            setState(() {
              _selectedTags = tags;
            });
            _filterEvents();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Events',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.withOpacity(0.15),
                      Colors.purple.withOpacity(0.12),
                      Colors.pink.withOpacity(0.08),
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Theme.of(
                          context,
                        ).scaffoldBackgroundColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.tune),
                      if (_selectedType != null || _selectedTags.isNotEmpty)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: _showFilters,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Enhanced Search Bar
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.1),
                          Colors.purple.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => _filterEvents(),
                      decoration: InputDecoration(
                        hintText: 'Search amazing events...',
                        hintStyle: TextStyle(
                          color: Colors.grey.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        prefixIcon: Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.purple],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            color: Colors.white,
                          ),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterEvents();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Quick Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Events',
                          _events.length.toString(),
                          Icons.event_rounded,
                          [Colors.orange, Colors.deepOrange],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'This Month',
                          _getThisMonthCount().toString(),
                          Icons.calendar_month_rounded,
                          [Colors.green, Colors.teal],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Events List or Empty State
          if (_isLoading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: const LoadingCard(),
                ),
                childCount: 5,
              ),
            )
          else if (_events.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModernEmptyState(
                      'No Events Yet',
                      'Ready to discover amazing events? Let\'s create some sample events to get started!',
                      Icons.celebration_rounded,
                      [Colors.orange, Colors.pink],
                      _populateSampleData,
                      'Create Sample Events',
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loadEvents,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            )
          else if (_filteredEvents.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: _buildModernEmptyState(
                  'No Matching Events',
                  'Try adjusting your search terms or filters to find more events.',
                  Icons.search_off_rounded,
                  [Colors.blue, Colors.purple],
                  null,
                  null,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final event = _filteredEvents[index];
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: _buildModernEventCard(event, index),
                    ),
                  );
                }, childCount: _filteredEvents.length),
              ),
            ),
        ],
      ),
      floatingActionButton: AnimatedScale(
        scale: _isLoading ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          heroTag: "events_fab",
          onPressed: () {
            // TODO: Create new event (admin only)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Create event feature coming soon!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Create Event'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    List<Color> gradientColors,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernEventCard(Event event, int index) {
    final gradientColors = _getEventGradientColors(index);
    final isUpcoming = event.startDate.isAfter(DateTime.now());

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: event),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradientColors[0].withOpacity(0.1),
              gradientColors[1].withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: gradientColors[0].withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getEventIcon(index),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isUpcoming ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isUpcoming ? 'UPCOMING' : 'ONGOING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: gradientColors[0],
                    size: 16,
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Event Details
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildEventDetailRow(
                      Icons.access_time_rounded,
                      _formatEventDateTime(event.startDate),
                      gradientColors[0],
                    ),
                    SizedBox(height: 12),
                    _buildEventDetailRow(
                      Icons.location_on_rounded,
                      event.location.isNotEmpty
                          ? event.location
                          : 'Virtual Event',
                      gradientColors[1],
                    ),
                    SizedBox(height: 12),
                    _buildEventDetailRow(
                      Icons.people_rounded,
                      '${event.registeredCount}/${event.capacity} registered',
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetailRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _getEventGradientColors(int index) {
    final colorSets = [
      [Colors.blue, Colors.cyan],
      [Colors.purple, Colors.pink],
      [Colors.orange, Colors.red],
      [Colors.green, Colors.teal],
      [Colors.indigo, Colors.blue],
      [Colors.pink, Colors.purple],
    ];
    return colorSets[index % colorSets.length];
  }

  IconData _getEventIcon(int index) {
    final icons = [
      Icons.event_rounded,
      Icons.work_rounded,
      Icons.school_rounded,
      Icons.celebration_rounded,
      Icons.computer_rounded,
      Icons.groups_rounded,
    ];
    return icons[index % icons.length];
  }

  String _formatEventDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now).inDays;

    if (difference == 0) {
      return 'Today at ${_formatTime(dateTime)}';
    } else if (difference == 1) {
      return 'Tomorrow at ${_formatTime(dateTime)}';
    } else if (difference < 7) {
      return '${_formatDayOfWeek(dateTime)} at ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDayOfWeek(DateTime dateTime) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dateTime.weekday - 1];
  }

  int _getThisMonthCount() {
    final now = DateTime.now();
    return _events
        .where(
          (event) =>
              event.startDate.month == now.month &&
              event.startDate.year == now.year,
        )
        .length;
  }

  Widget _buildModernEmptyState(
    String title,
    String message,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback? onButtonPressed,
    String? buttonText,
  ) {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientColors[0].withOpacity(0.1),
            gradientColors[1].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gradientColors[0].withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, size: 48, color: Colors.white),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          if (onButtonPressed != null && buttonText != null) ...[
            SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onButtonPressed,
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  buttonText,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

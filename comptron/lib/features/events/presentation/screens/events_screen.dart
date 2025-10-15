import 'package:flutter/material.dart';
import '../../../../core/models/event.dart';
import '../../../../core/services/mongodb_service.dart';
import '../widgets/event_card.dart';
import '../widgets/event_filters.dart';
import '../../../../core/widgets/custom_card.dart';
import 'event_details_screen.dart';
import 'event_registration_screen.dart';

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
      final events = await mongoService.getUpcomingEvents(limit: 50);

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

      // Only show error message if it's not a connection timeout or state issue
      // to avoid spamming users with MongoDB connection errors
      print('Events loading error: $e');
    }

    if (mounted) {
      _fadeController.forward();
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
                      Theme.of(context).primaryColor.withOpacity(0.08),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                    ],
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
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
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
                onChanged: (value) {
                  _filterEvents();
                  setState(() {});
                },
              ),
            ),
          ),
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
            const SliverFillRemaining(
              child: Center(
                child: EmptyStateCard(
                  title: 'No Events',
                  message:
                      'There are no events available at the moment. Check back later!',
                  icon: Icons.event_busy,
                ),
              ),
            )
          else if (_filteredEvents.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: EmptyStateCard(
                  title: 'No Results',
                  message:
                      'No events match your search criteria. Try adjusting your filters.',
                  icon: Icons.search_off,
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
                      child: EventCard(
                        event: event,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailsScreen(event: event),
                            ),
                          );
                        },
                        onRegister: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventRegistrationScreen(event: event),
                            ),
                          );
                        },
                      ),
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
}

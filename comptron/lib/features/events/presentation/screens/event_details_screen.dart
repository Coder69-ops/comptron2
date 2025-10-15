import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/models/event.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import 'event_registration_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: event.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: event.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    )
                  : Container(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.event,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          event.type.label,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (event.isFull)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Full',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(context),
                  const SizedBox(height: 24),
                  if (event.tags.isNotEmpty) _buildTagsSection(context),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Add to Calendar',
                  isOutlined: true,
                  onPressed: () => _addToCalendar(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Register',
                  onPressed: event.isFull
                      ? null
                      : () => _registerForEvent(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          _buildInfoRow(
            context,
            Icons.calendar_today,
            'Date',
            _formatDate(event.startDate),
          ),
          const Divider(),
          _buildInfoRow(
            context,
            Icons.access_time,
            'Time',
            _formatTime(event.startDate, event.endDate),
          ),
          const Divider(),
          _buildInfoRow(context, Icons.location_on, 'Location', event.location),
          const Divider(),
          _buildInfoRow(
            context,
            Icons.people,
            'Capacity',
            '${event.registeredCount}/${event.capacity}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: event.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tag,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Share Event',
            isOutlined: true,
            onPressed: () => _shareEvent(),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () => _toggleFavorite(),
          icon: const Icon(Icons.favorite_border),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime start, DateTime end) {
    return '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  }

  void _addToCalendar() async {
    // Create Google Calendar URL
    final startDate = event.startDate
        .toUtc()
        .toIso8601String()
        .replaceAll(':', '%3A')
        .replaceAll('-', '');
    final endDate = event.endDate
        .toUtc()
        .toIso8601String()
        .replaceAll(':', '%3A')
        .replaceAll('-', '');
    final title = Uri.encodeComponent(event.title);
    final description = Uri.encodeComponent(event.description);
    final location = Uri.encodeComponent(event.location);

    final calendarUrl =
        'https://calendar.google.com/calendar/render?action=TEMPLATE&text=$title&dates=$startDate/$endDate&details=$description&location=$location';

    final uri = Uri.parse(calendarUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _registerForEvent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventRegistrationScreen(event: event),
      ),
    );
  }

  void _shareEvent() {
    // TODO: Implement share functionality
  }

  void _toggleFavorite() {
    // TODO: Implement favorite toggle
  }
}

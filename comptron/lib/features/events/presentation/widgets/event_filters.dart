import 'package:flutter/material.dart';
import '../../../../core/models/event.dart';

class EventFilters extends StatefulWidget {
  final EventType? selectedType;
  final List<String> selectedTags;
  final Function(EventType?) onTypeChanged;
  final Function(List<String>) onTagsChanged;

  const EventFilters({
    super.key,
    this.selectedType,
    this.selectedTags = const [],
    required this.onTypeChanged,
    required this.onTagsChanged,
  });

  @override
  State<EventFilters> createState() => _EventFiltersState();
}

class _EventFiltersState extends State<EventFilters> {
  final List<String> _availableTags = [
    'Technology',
    'Business',
    'Design',
    'Marketing',
    'Programming',
    'AI/ML',
    'Web Development',
    'Mobile Development',
    'Data Science',
    'Career',
    'Networking',
    'Innovation',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onTypeChanged(null);
                  widget.onTagsChanged([]);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Event Type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: widget.selectedType == null,
                onSelected: (selected) {
                  widget.onTypeChanged(null);
                },
              ),
              ...EventType.values.map(
                (type) => FilterChip(
                  label: Text(type.label),
                  selected: widget.selectedType == type,
                  onSelected: (selected) {
                    widget.onTypeChanged(selected ? type : null);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tags',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _availableTags.map(
              (tag) => FilterChip(
                label: Text(tag),
                selected: widget.selectedTags.contains(tag),
                onSelected: (selected) {
                  final newTags = List<String>.from(widget.selectedTags);
                  if (selected) {
                    newTags.add(tag);
                  } else {
                    newTags.remove(tag);
                  }
                  widget.onTagsChanged(newTags);
                },
              ),
            ).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
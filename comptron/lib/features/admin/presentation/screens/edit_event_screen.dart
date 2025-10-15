import 'package:flutter/material.dart';
import '../../../../core/models/event.dart';
import '../../../../core/services/mongodb_service.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;

  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _capacityController;
  late final TextEditingController _imageUrlController;

  late DateTime _startDate;
  late DateTime _endDate;
  late EventType _selectedType;
  late bool _isPublished;
  bool _isLoading = false;
  late List<String> _tags;
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(
      text: widget.event.description,
    );
    _locationController = TextEditingController(text: widget.event.location);
    _capacityController = TextEditingController(
      text: widget.event.capacity.toString(),
    );
    _imageUrlController = TextEditingController(text: widget.event.imageUrl);

    _startDate = widget.event.startDate;
    _endDate = widget.event.endDate;
    _selectedType = widget.event.type;
    _isPublished = widget.event.isPublished;
    _tags = List.from(widget.event.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _imageUrlController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedEvent = widget.event.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        location: _locationController.text.trim(),
        type: _selectedType,
        tags: _tags,
        capacity: int.parse(_capacityController.text),
        isPublished: _isPublished,
        updatedAt: DateTime.now(),
      );

      final mongoService = await MongoDBService.getInstance();
      await mongoService.updateEvent(updatedEvent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _selectDateTime(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStartDate ? _startDate : _endDate,
        ),
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isStartDate) {
            _startDate = dateTime;
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(hours: 2));
            }
          } else {
            _endDate = dateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateEvent,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter event title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter event description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location*',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter event location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Event Type
              DropdownButtonFormField<EventType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Event Type*',
                  border: OutlineInputBorder(),
                ),
                items: EventType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.label));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Capacity
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity*',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter event capacity';
                  }
                  final capacity = int.tryParse(value);
                  if (capacity == null || capacity <= 0) {
                    return 'Please enter a valid capacity';
                  }
                  if (capacity < widget.event.registeredCount) {
                    return 'Capacity cannot be less than current registrations (${widget.event.registeredCount})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image URL
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Registration Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registration Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.people, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.event.registeredCount}/${widget.event.capacity} registered',
                          ),
                        ],
                      ),
                      if (widget.event.waitlistedUsers.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.list_alt, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.event.waitlistedUsers.length} on waitlist',
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: ListTile(
                        title: const Text('Start Date & Time'),
                        subtitle: Text(
                          '${_startDate.day}/${_startDate.month}/${_startDate.year} at ${_startDate.hour.toString().padLeft(2, '0')}:${_startDate.minute.toString().padLeft(2, '0')}',
                        ),
                        leading: const Icon(Icons.schedule),
                        onTap: () => _selectDateTime(true),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: ListTile(
                        title: const Text('End Date & Time'),
                        subtitle: Text(
                          '${_endDate.day}/${_endDate.month}/${_endDate.year} at ${_endDate.hour.toString().padLeft(2, '0')}:${_endDate.minute.toString().padLeft(2, '0')}',
                        ),
                        leading: const Icon(Icons.schedule_outlined),
                        onTap: () => _selectDateTime(false),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tags
              Text('Tags', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        labelText: 'Add tag',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(onPressed: _addTag, icon: const Icon(Icons.add)),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeTag(tag),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),

              // Publish Option
              SwitchListTile(
                title: const Text('Publish Event'),
                subtitle: const Text('Make this event visible to users'),
                value: _isPublished,
                onChanged: (value) {
                  setState(() {
                    _isPublished = value;
                  });
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

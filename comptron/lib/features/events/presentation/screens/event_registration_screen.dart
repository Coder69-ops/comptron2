import 'package:flutter/material.dart';
import '../../../../core/models/event.dart';
import '../../../../core/models/registration.dart';
import '../../../../core/services/mongodb_service.dart';
import '../../../../core/services/auth_service.dart';
import 'event_qr_screen.dart';

class EventRegistrationScreen extends StatefulWidget {
  final Event event;

  const EventRegistrationScreen({super.key, required this.event});

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _personalEmailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _batchController = TextEditingController();
  final _sectionController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  bool _isRegistering = false;
  Registration? _existingRegistration;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkExistingRegistration();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _personalEmailController.dispose();
    _phoneController.dispose();
    _batchController.dispose();
    _sectionController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingRegistration() async {
    try {
      final authService = await AuthService.getInstance();
      final currentUser = authService.currentUser;

      if (currentUser != null) {
        final mongoService = await MongoDBService.getInstance();
        final registration = await mongoService.getRegistration(
          widget.event.id,
          currentUser.id,
        );

        setState(() {
          _existingRegistration = registration;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerForEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      final authService = await AuthService.getInstance();
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        throw Exception('Please log in to register for events');
      }

      // Validate @nwu.ac.bd email format
      final nwuEmail = _emailController.text.trim();
      if (!Registration.isValidNwuEmail(nwuEmail)) {
        throw Exception(
          'Please enter a valid @nwu.ac.bd email in format: 20232002010@nwu.ac.bd',
        );
      }

      final studentId = Registration.extractStudentId(nwuEmail);
      if (studentId.isEmpty) {
        throw Exception('Could not extract student ID from email');
      }

      final mongoService = await MongoDBService.getInstance();
      final registration = await mongoService.createRegistration(
        eventId: widget.event.id,
        userId: currentUser.id,
        eventTitle: widget.event.title,
        userName: _nameController.text.trim(),
        userEmail: nwuEmail,
        studentId: studentId,
        personalEmail: _personalEmailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        batch: _batchController.text.trim(),
        section: _sectionController.text.trim(),
        eventDate: widget.event.startDate,
        additionalData: _additionalInfoController.text.trim().isNotEmpty
            ? {'additionalInfo': _additionalInfoController.text.trim()}
            : null,
      );

      setState(() {
        _existingRegistration = registration;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              registration.isWaitlisted
                  ? 'Added to waitlist! You\'ll be notified if a spot opens up.'
                  : 'Successfully registered for the event!',
            ),
            backgroundColor: registration.isWaitlisted
                ? Colors.orange
                : Colors.green,
            action: SnackBarAction(
              label: 'View QR',
              onPressed: () => _viewQRCode(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  Future<void> _cancelRegistration() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Registration'),
        content: const Text(
          'Are you sure you want to cancel your registration? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Registration'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cancel Registration'),
          ),
        ],
      ),
    );

    if (confirmed == true && _existingRegistration != null) {
      try {
        final mongoService = await MongoDBService.getInstance();
        await mongoService.cancelRegistration(_existingRegistration!.id);

        setState(() {
          _existingRegistration = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel registration: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _viewQRCode() {
    if (_existingRegistration != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EventQRScreen(registration: _existingRegistration!),
        ),
      );
    }
  }

  Color _getStatusColor(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.confirmed:
        return Colors.green;
      case RegistrationStatus.waitlisted:
        return Colors.orange;
      case RegistrationStatus.checkedIn:
        return Colors.blue;
      case RegistrationStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.confirmed:
        return Icons.check_circle;
      case RegistrationStatus.waitlisted:
        return Icons.schedule;
      case RegistrationStatus.checkedIn:
        return Icons.verified;
      case RegistrationStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Registration')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Event Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.event.startDate.day}/${widget.event.startDate.month}/${widget.event.startDate.year} at ${widget.event.startDate.hour.toString().padLeft(2, '0')}:${widget.event.startDate.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.event.location,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Capacity Information
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.event.registeredCount}/${widget.event.capacity} registered',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        if (widget.event.isFull)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'FULL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: widget.event.capacity > 0
                          ? widget.event.registeredCount / widget.event.capacity
                          : 0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.event.isFull ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Registration Status or Form
            if (_existingRegistration != null) ...[
              // Show existing registration status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getStatusIcon(_existingRegistration!.status),
                            color: _getStatusColor(
                              _existingRegistration!.status,
                            ),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Registration ${_existingRegistration!.status.label}',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _existingRegistration!.status.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Student Details Section
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registration Details',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Name',
                              _existingRegistration!.userName,
                            ),
                            if (_existingRegistration!.studentId != null)
                              _buildDetailRow(
                                'Student ID',
                                _existingRegistration!.studentId!,
                              ),
                            _buildDetailRow(
                              'University Email',
                              _existingRegistration!.userEmail,
                            ),
                            if (_existingRegistration!.personalEmail != null)
                              _buildDetailRow(
                                'Personal Email',
                                _existingRegistration!.personalEmail!,
                              ),
                            if (_existingRegistration!.phoneNumber != null)
                              _buildDetailRow(
                                'Phone Number',
                                _existingRegistration!.phoneNumber!,
                              ),
                            if (_existingRegistration!.batch != null)
                              _buildDetailRow(
                                'Batch',
                                _existingRegistration!.batch!,
                              ),
                            if (_existingRegistration!.section != null)
                              _buildDetailRow(
                                'Section',
                                _existingRegistration!.section!,
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Registered on: ${_existingRegistration!.registeredAt.day}/${_existingRegistration!.registeredAt.month}/${_existingRegistration!.registeredAt.year}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),

                      if (_existingRegistration!.isCheckedIn &&
                          _existingRegistration!.checkedInAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Checked in on: ${_existingRegistration!.checkedInAt!.day}/${_existingRegistration!.checkedInAt!.month}/${_existingRegistration!.checkedInAt!.year} at ${_existingRegistration!.checkedInAt!.hour.toString().padLeft(2, '0')}:${_existingRegistration!.checkedInAt!.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          if (!_existingRegistration!.isCancelled) ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _cancelRegistration,
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Cancel Registration'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _viewQRCode,
                              icon: const Icon(Icons.qr_code),
                              label: const Text('Show QR Code'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Show registration form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Register for Event',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 16),

                        if (widget.event.isFull) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'This event is currently full. You will be added to the waitlist and notified if a spot becomes available.',
                                    style: TextStyle(color: Colors.orange[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Student Information Form
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name *',
                            hintText: 'Enter your full name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'University Email *',
                            hintText: '20232002010@nwu.ac.bd',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.school),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'University email is required';
                            }
                            if (!Registration.isValidNwuEmail(value.trim())) {
                              return 'Please enter valid @nwu.ac.bd email\nFormat: 20232002010@nwu.ac.bd';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _personalEmailController,
                          decoration: const InputDecoration(
                            labelText: 'Personal Email *',
                            hintText: 'your.personal@gmail.com',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Personal email is required';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value.trim())) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number *',
                            hintText: '+880 1234567890',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _batchController,
                                decoration: const InputDecoration(
                                  labelText: 'Batch *',
                                  hintText: '2023',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Batch is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _sectionController,
                                decoration: const InputDecoration(
                                  labelText: 'Section *',
                                  hintText: 'A',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.class_),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Section is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Additional Information (Optional)
                        TextFormField(
                          controller: _additionalInfoController,
                          decoration: const InputDecoration(
                            labelText: 'Additional Information (Optional)',
                            hintText: 'Any special requirements or notes...',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.notes),
                          ),
                          maxLines: 3,
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isRegistering
                                ? null
                                : _registerForEvent,
                            icon: _isRegistering
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.app_registration),
                            label: Text(
                              _isRegistering
                                  ? 'Registering...'
                                  : widget.event.isFull
                                  ? 'Join Waitlist'
                                  : 'Register Now',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Event Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About This Event',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.event.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    if (widget.event.tags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.event.tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: Colors.grey[200],
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Theme.of(context).primaryColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).textTheme.labelMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    const months = [
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

    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year\n$hour:$minute';
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.labelLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
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
        appBar: AppBar(
          title: const Text(
            'Event Registration',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading event details...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Registration',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _checkExistingRegistration,
            tooltip: 'Refresh',
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Information Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title
                    Text(
                      widget.event.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Event Details in Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.schedule_rounded,
                            title: 'Date & Time',
                            subtitle: _formatDateTime(widget.event.startDate),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.location_on_rounded,
                            title: 'Location',
                            subtitle: widget.event.location.isNotEmpty
                                ? widget.event.location
                                : 'To be announced',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Capacity Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).shadowColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_rounded,
                                    size: 20,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Registration Status',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              if (widget.event.isFull)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'FULL',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${widget.event.registeredCount} registered',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.7),
                                    ),
                              ),
                              Text(
                                '${widget.event.capacity - widget.event.registeredCount} spots left',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: widget.event.isFull
                                          ? Colors.red
                                          : Colors.green.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: widget.event.capacity > 0
                                  ? widget.event.registeredCount /
                                        widget.event.capacity
                                  : 0,
                              backgroundColor: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.event.isFull
                                    ? Colors.red
                                    : Theme.of(context).primaryColor,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
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
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getStatusColor(
                        _existingRegistration!.status,
                      ).withOpacity(0.1),
                      _getStatusColor(
                        _existingRegistration!.status,
                      ).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getStatusColor(
                      _existingRegistration!.status,
                    ).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            _existingRegistration!.status,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  _existingRegistration!.status,
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(
                                _getStatusIcon(_existingRegistration!.status),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Registration ${_existingRegistration!.status.label}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(
                                            _existingRegistration!.status,
                                          ),
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _existingRegistration!.status.description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withOpacity(0.7),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Student Details Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).shadowColor.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Form Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person_add_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Register for Event',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.color,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

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
                        _buildFormField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          icon: Icons.person_outline_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildFormField(
                          controller: _emailController,
                          label: 'University Email',
                          hint: '20232002010@nwu.ac.bd',
                          icon: Icons.school_outlined,
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
                        const SizedBox(height: 20),

                        _buildFormField(
                          controller: _personalEmailController,
                          label: 'Personal Email',
                          hint: 'your.personal@gmail.com',
                          icon: Icons.email_outlined,
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
                        const SizedBox(height: 20),

                        _buildFormField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: '+880 1234567890',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            if (!RegExp(
                              r'^\+?[\d\s\-\(\)]{10,}$',
                            ).hasMatch(value.trim())) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField(
                                controller: _batchController,
                                label: 'Batch',
                                hint: '2023',
                                icon: Icons.calendar_today_outlined,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Batch is required';
                                  }
                                  if (!RegExp(
                                    r'^\d{4}$',
                                  ).hasMatch(value.trim())) {
                                    return 'Enter valid year (e.g., 2023)';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormField(
                                controller: _sectionController,
                                label: 'Section',
                                hint: 'A',
                                icon: Icons.class_outlined,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Section is required';
                                  }
                                  if (value.trim().length > 2) {
                                    return 'Section should be 1-2 characters';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Additional Information (Optional)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Additional Information (Optional)',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.labelLarge?.color,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _additionalInfoController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText:
                                    'Any special requirements, dietary restrictions, or notes...',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(bottom: 60),
                                  child: Icon(
                                    Icons.notes_outlined,
                                    color: Theme.of(
                                      context,
                                    ).iconTheme.color?.withOpacity(0.6),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: _isRegistering
                                ? null
                                : LinearGradient(
                                    colors: [
                                      Theme.of(context).primaryColor,
                                      Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.8),
                                    ],
                                  ),
                          ),
                          child: ElevatedButton(
                            onPressed: _isRegistering
                                ? null
                                : _registerForEvent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRegistering
                                  ? Theme.of(
                                      context,
                                    ).disabledColor.withOpacity(0.3)
                                  : Colors.transparent,
                              foregroundColor: _isRegistering
                                  ? Theme.of(context).disabledColor
                                  : Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isRegistering
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Registering...',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        widget.event.isFull
                                            ? Icons.list_alt_rounded
                                            : Icons
                                                  .check_circle_outline_rounded,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.event.isFull
                                            ? 'Join Waitlist'
                                            : 'Register Now',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'About This Event',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

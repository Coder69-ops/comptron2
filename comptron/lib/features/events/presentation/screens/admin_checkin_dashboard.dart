import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/event.dart';
import '../../../../core/models/registration.dart';
import '../../../../core/services/mongodb_service.dart';
import 'admin_qr_scanner_screen.dart';

class AdminCheckInDashboard extends StatefulWidget {
  final Event event;

  const AdminCheckInDashboard({super.key, required this.event});

  @override
  State<AdminCheckInDashboard> createState() => _AdminCheckInDashboardState();
}

class _AdminCheckInDashboardState extends State<AdminCheckInDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Registration> _allRegistrations = [];
  List<Registration> _confirmedRegistrations = [];
  List<Registration> _waitlistedRegistrations = [];
  List<Registration> _checkedInRegistrations = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRegistrations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRegistrations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final mongoService = await MongoDBService.getInstance();
      final registrations = await mongoService.getEventRegistrations(
        widget.event.id,
      );

      setState(() {
        _allRegistrations = registrations;
        _filterRegistrations();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading registrations: $e')),
        );
      }
    }
  }

  void _filterRegistrations() {
    final query = _searchQuery.toLowerCase();

    final filteredRegistrations = _allRegistrations.where((reg) {
      return reg.userName.toLowerCase().contains(query) ||
          reg.userEmail.toLowerCase().contains(query) ||
          (reg.studentId?.toLowerCase().contains(query) ?? false) ||
          (reg.personalEmail?.toLowerCase().contains(query) ?? false) ||
          (reg.phoneNumber?.toLowerCase().contains(query) ?? false) ||
          (reg.batch?.toLowerCase().contains(query) ?? false) ||
          (reg.section?.toLowerCase().contains(query) ?? false);
    }).toList();

    _confirmedRegistrations = filteredRegistrations
        .where((reg) => reg.status == RegistrationStatus.confirmed)
        .toList();
    _waitlistedRegistrations = filteredRegistrations
        .where((reg) => reg.status == RegistrationStatus.waitlisted)
        .toList();
    _checkedInRegistrations = filteredRegistrations
        .where((reg) => reg.status == RegistrationStatus.checkedIn)
        .toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterRegistrations();
    });
  }

  Future<void> _manualCheckIn(Registration registration) async {
    try {
      final mongoService = await MongoDBService.getInstance();
      await mongoService.checkInUser(
        widget.event.id.toString(),
        registration.userId,
      );

      HapticFeedback.lightImpact();
      await _loadRegistrations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${registration.userName} checked in successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking in user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _promoteFromWaitlist(Registration registration) async {
    try {
      final mongoService = await MongoDBService.getInstance();
      await mongoService.updateRegistrationStatus(
        registration.id,
        RegistrationStatus.confirmed,
      );

      HapticFeedback.lightImpact();
      await _loadRegistrations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${registration.userName} promoted from waitlist'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error promoting user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminQRScannerScreen(event: widget.event),
      ),
    ).then((_) => _loadRegistrations());
  }

  @override
  Widget build(BuildContext context) {
    final checkedInCount = _allRegistrations.where((r) => r.isCheckedIn).length;
    final confirmedCount = _allRegistrations.where((r) => r.isConfirmed).length;
    final waitlistCount = _allRegistrations.where((r) => r.isWaitlisted).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.event.title),
            Text(
              '${checkedInCount}/${confirmedCount} checked in',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadRegistrations,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'All',
              icon: Badge(
                label: Text('${_allRegistrations.length}'),
                child: const Icon(Icons.people),
              ),
            ),
            Tab(
              text: 'Confirmed',
              icon: Badge(
                label: Text('$confirmedCount'),
                child: const Icon(Icons.check_circle),
              ),
            ),
            Tab(
              text: 'Waitlist',
              icon: Badge(
                label: Text('$waitlistCount'),
                child: const Icon(Icons.schedule),
              ),
            ),
            Tab(
              text: 'Checked In',
              icon: Badge(
                label: Text('$checkedInCount'),
                child: const Icon(Icons.verified),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Statistics Cards
          if (!_isLoading)
            Container(
              height: 88,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Check-in Rate',
                      confirmedCount > 0
                          ? '${((checkedInCount / confirmedCount) * 100).round()}%'
                          : '0%',
                      Icons.trending_up,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Capacity',
                      '${widget.event.registeredCount}/${widget.event.capacity}',
                      Icons.event_seat,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Waitlist',
                      '$waitlistCount',
                      Icons.schedule,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Tab Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRegistrationList(_allRegistrations, showAll: true),
                      _buildRegistrationList(_confirmedRegistrations),
                      _buildRegistrationList(_waitlistedRegistrations),
                      _buildRegistrationList(_checkedInRegistrations),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openQRScanner,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationList(
    List<Registration> registrations, {
    bool showAll = false,
  }) {
    if (registrations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No registrations found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRegistrations,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: registrations.length,
        itemBuilder: (context, index) {
          final registration = registrations[index];
          return _buildRegistrationCard(registration, showAll: showAll);
        },
      ),
    );
  }

  Widget _buildRegistrationCard(
    Registration registration, {
    bool showAll = false,
  }) {
    Color statusColor;
    IconData statusIcon;

    switch (registration.status) {
      case RegistrationStatus.confirmed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case RegistrationStatus.waitlisted:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case RegistrationStatus.checkedIn:
        statusColor = Colors.blue;
        statusIcon = Icons.verified;
        break;
      case RegistrationStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          registration.userName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (registration.studentId != null) ...[
              Text(
                'ID: ${registration.studentId}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
            ],
            Text(registration.userEmail),
            const SizedBox(height: 2),
            if (registration.batch != null && registration.section != null) ...[
              Text(
                'Batch ${registration.batch} - Section ${registration.section}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
            ],
            if (registration.phoneNumber != null) ...[
              Text(
                'Phone: ${registration.phoneNumber}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                if (showAll) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      registration.status.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  'Registered: ${registration.registeredAt.day}/${registration.registeredAt.month}/${registration.registeredAt.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (registration.checkedInAt != null) ...[
              const SizedBox(height: 2),
              Text(
                'Checked in: ${registration.checkedInAt!.day}/${registration.checkedInAt!.month}/${registration.checkedInAt!.year} at ${registration.checkedInAt!.hour.toString().padLeft(2, '0')}:${registration.checkedInAt!.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: _buildActionButton(registration),
        onTap: () => _showRegistrationDetails(registration),
      ),
    );
  }

  Widget? _buildActionButton(Registration registration) {
    if (registration.isWaitlisted) {
      return TextButton(
        onPressed: () => _promoteFromWaitlist(registration),
        child: const Text('Promote'),
      );
    } else if (registration.isConfirmed) {
      return TextButton(
        onPressed: () => _manualCheckIn(registration),
        child: const Text('Check In'),
      );
    } else if (registration.isCheckedIn) {
      return Icon(Icons.verified, color: Colors.green[600]);
    }
    return null;
  }

  void _showRegistrationDetails(Registration registration) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // User Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _getStatusColor(
                      registration.status,
                    ).withOpacity(0.1),
                    child: Icon(
                      _getStatusIcon(registration.status),
                      color: _getStatusColor(registration.status),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          registration.userName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          registration.userEmail,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(registration.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(registration.status),
                      color: _getStatusColor(registration.status),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      registration.status.label.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(registration.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Details
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Registration ID',
                        registration.id.toString(),
                      ),
                      _buildDetailRow(
                        'QR Code',
                        registration.qrCode.substring(0, 16) + '...',
                      ),
                      _buildDetailRow(
                        'Registered At',
                        '${registration.registeredAt.day}/${registration.registeredAt.month}/${registration.registeredAt.year} at ${registration.registeredAt.hour.toString().padLeft(2, '0')}:${registration.registeredAt.minute.toString().padLeft(2, '0')}',
                      ),

                      if (registration.checkedInAt != null)
                        _buildDetailRow(
                          'Checked In At',
                          '${registration.checkedInAt!.day}/${registration.checkedInAt!.month}/${registration.checkedInAt!.year} at ${registration.checkedInAt!.hour.toString().padLeft(2, '0')}:${registration.checkedInAt!.minute.toString().padLeft(2, '0')}',
                        ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            if (registration.isWaitlisted)
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _promoteFromWaitlist(registration);
                                },
                                icon: const Icon(Icons.arrow_upward),
                                label: const Text('Promote from Waitlist'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            if (registration.isConfirmed)
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _manualCheckIn(registration);
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Manual Check-in'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            if (registration.isCheckedIn)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.verified, color: Colors.green),
                                    SizedBox(width: 8),
                                    Text(
                                      'User is checked in',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
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
}

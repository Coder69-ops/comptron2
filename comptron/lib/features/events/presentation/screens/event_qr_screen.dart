import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/models/registration.dart';

class EventQRScreen extends StatefulWidget {
  final Registration registration;

  const EventQRScreen({super.key, required this.registration});

  @override
  State<EventQRScreen> createState() => _EventQRScreenState();
}

class _EventQRScreenState extends State<EventQRScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  double _brightness = 1.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.registration.isConfirmed) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _copyQRCode() {
    Clipboard.setData(ClipboardData(text: widget.registration.qrCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _adjustBrightness() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Screen Brightness'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Adjust brightness for better QR code scanning'),
            const SizedBox(height: 16),
            Slider(
              value: _brightness,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: '${(_brightness * 100).round()}%',
              onChanged: (value) {
                setState(() {
                  _brightness = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.registration.status) {
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

  IconData _getStatusIcon() {
    switch (widget.registration.status) {
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
    final screenHeight = MediaQuery.of(context).size.height;
    final qrSize = (screenHeight * 0.25).clamp(200.0, 250.0);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(1 - _brightness + 0.1),
      appBar: AppBar(
        title: const Text('Event QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _adjustBrightness,
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Adjust Brightness',
          ),
          IconButton(
            onPressed: _copyQRCode,
            icon: const Icon(Icons.copy),
            tooltip: 'Copy QR Code',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Event Title
              Text(
                widget.registration.eventTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Event Date
              Text(
                '${widget.registration.eventDate.day}/${widget.registration.eventDate.month}/${widget.registration.eventDate.year}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Registration Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getStatusIcon(), color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.registration.status.label.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // QR Code Container
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.registration.isConfirmed
                        ? _pulseAnimation.value
                        : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor().withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: widget.registration.qrCode,
                        version: QrVersions.auto,
                        size: qrSize,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // QR Code ID
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ID: ${widget.registration.qrCode.substring(0, 8)}...',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'monospace',
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Instructions
              if (widget.registration.isConfirmed) ...[
                _buildInstructionCard(
                  Icons.info_outline,
                  'Show this QR code to event organizers for check-in',
                  'Keep your screen bright and steady for easy scanning',
                  Colors.green,
                ),
              ] else if (widget.registration.isWaitlisted) ...[
                _buildInstructionCard(
                  Icons.schedule,
                  'You\'re on the waitlist',
                  'We\'ll notify you if a spot becomes available',
                  Colors.orange,
                ),
              ] else if (widget.registration.isCheckedIn) ...[
                _buildInstructionCard(
                  Icons.verified,
                  'Successfully Checked In!',
                  widget.registration.checkedInAt != null
                      ? 'Checked in on ${widget.registration.checkedInAt!.day}/${widget.registration.checkedInAt!.month}/${widget.registration.checkedInAt!.year} at ${widget.registration.checkedInAt!.hour.toString().padLeft(2, '0')}:${widget.registration.checkedInAt!.minute.toString().padLeft(2, '0')}'
                      : 'Check-in confirmed',
                  Colors.blue,
                ),
              ],

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _adjustBrightness,
                      icon: const Icon(
                        Icons.brightness_6,
                        color: Colors.white70,
                      ),
                      label: const Text(
                        'Brightness',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _copyQRCode,
                      icon: const Icon(Icons.copy, color: Colors.white70),
                      label: const Text(
                        'Copy Code',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color.withOpacity(0.9), size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

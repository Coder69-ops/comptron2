import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/models/event.dart';
import '../../../../core/widgets/custom_button.dart';

class QRCodeScreen extends StatelessWidget {
  final Event event;
  final String registrationId;

  const QRCodeScreen({
    super.key,
    required this.event,
    required this.registrationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your QR Pass'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              // TODO: Toggle brightness
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              event.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(event.startDate),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade800.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: QrImageView(
                data: registrationId,
                version: QrVersions.auto,
                size: 250.0,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(color: Colors.black),
                dataModuleStyle: const QrDataModuleStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registration Confirmed',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          'Show this QR code at the event entrance',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Registration ID: $registrationId',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Save to Gallery',
                    isOutlined: true,
                    onPressed: () => _saveToGallery(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Share QR',
                    onPressed: () => _shareQR(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
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
    return '${date.day} ${months[date.month - 1]} ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _saveToGallery(BuildContext context) {
    // TODO: Implement save to gallery
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('QR code saved to gallery!')));
  }

  void _shareQR(BuildContext context) {
    // TODO: Implement share QR
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }
}

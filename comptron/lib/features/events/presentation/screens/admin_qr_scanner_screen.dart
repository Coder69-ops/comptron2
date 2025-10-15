import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/models/event.dart';
import '../../../../core/models/registration.dart';
import '../../../../core/services/mongodb_service.dart';

class AdminQRScannerScreen extends StatefulWidget {
  final Event event;

  const AdminQRScannerScreen({super.key, required this.event});

  @override
  State<AdminQRScannerScreen> createState() => _AdminQRScannerScreenState();
}

class _AdminQRScannerScreenState extends State<AdminQRScannerScreen>
    with TickerProviderStateMixin {
  late MobileScannerController controller;
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  bool _isScanning = true;
  bool _isProcessing = false;
  String? _lastScannedCode;
  Registration? _scannedRegistration;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onQRCodeDetected(BarcodeCapture capture) async {
    if (_isProcessing || !_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? qrCode = barcodes.first.rawValue;
    if (qrCode == null || qrCode == _lastScannedCode) return;

    setState(() {
      _isProcessing = true;
      _lastScannedCode = qrCode;
      _errorMessage = null;
    });

    HapticFeedback.lightImpact();

    try {
      final mongoService = await MongoDBService.getInstance();
      final registration = await mongoService.getRegistrationByQR(qrCode);

      if (registration == null) {
        _showError('Invalid QR code - registration not found');
        return;
      }

      if (registration.eventId != widget.event.id.toString()) {
        _showError('QR code is for a different event');
        return;
      }

      if (registration.isCancelled) {
        _showError('Registration has been cancelled');
        return;
      }

      if (registration.isWaitlisted) {
        _showError('User is still on the waitlist');
        return;
      }

      if (registration.isCheckedIn) {
        _showAlreadyCheckedIn(registration);
        return;
      }

      // Check in the user
      final updatedRegistration = await mongoService.checkInUser(
        widget.event.id.toString(),
        registration.userId,
      );

      _showCheckInSuccess(updatedRegistration);
    } catch (e) {
      _showError('Error processing QR code: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });

      // Resume scanning after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _lastScannedCode = null;
          });
        }
      });
    }
  }

  void _showError(String message) {
    HapticFeedback.heavyImpact();
    setState(() {
      _errorMessage = message;
      _scannedRegistration = null;
    });
  }

  void _showAlreadyCheckedIn(Registration registration) {
    HapticFeedback.mediumImpact();
    setState(() {
      _scannedRegistration = registration;
      _errorMessage = null;
    });
  }

  void _showCheckInSuccess(Registration registration) {
    HapticFeedback.selectionClick();
    setState(() {
      _scannedRegistration = registration;
      _errorMessage = null;
    });
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });

    if (_isScanning) {
      _animationController.repeat();
    } else {
      _animationController.stop();
    }
  }

  void _resetScanner() {
    setState(() {
      _lastScannedCode = null;
      _scannedRegistration = null;
      _errorMessage = null;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Check-in: ${widget.event.title}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _toggleScanning,
            icon: Icon(_isScanning ? Icons.pause : Icons.play_arrow),
            tooltip: _isScanning ? 'Pause Scanning' : 'Resume Scanning',
          ),
          IconButton(
            onPressed: _resetScanner,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Scanner',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera View
          if (_isScanning)
            MobileScanner(controller: controller, onDetect: _onQRCodeDetected),

          // Scanning Overlay
          if (_isScanning) ...[
            // Dark overlay with cutout
            Container(
              decoration: ShapeDecoration(
                shape: QRScannerOverlayShape(
                  borderColor: Colors.white,
                  borderRadius: 16,
                  borderLength: 40,
                  borderWidth: 4,
                  cutOutSize: 280,
                ),
              ),
            ),

            // Animated scanning line
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 140,
                  top:
                      MediaQuery.of(context).size.height / 2 -
                      140 +
                      (_scanAnimation.value * 280),
                  child: Container(
                    width: 280,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.green,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],

          // Instructions
          if (_isScanning &&
              !_isProcessing &&
              _scannedRegistration == null &&
              _errorMessage == null)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Point camera at QR code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Align QR code within the frame',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          // Processing Indicator
          if (_isProcessing)
            const Center(
              child: Card(
                color: Colors.black87,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Processing QR Code...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Success/Error Results
          if (_scannedRegistration != null || _errorMessage != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _errorMessage != null
                      ? Colors.red[800]
                      : Colors.green[800],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: _errorMessage != null
                    ? _buildErrorResult()
                    : _buildSuccessResult(),
              ),
            ),

          // Status Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
              child: SafeArea(
                child: Row(
                  children: [
                    Icon(
                      _isScanning ? Icons.qr_code_scanner : Icons.pause_circle,
                      color: _isScanning ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isScanning ? 'Scanning Active' : 'Scanning Paused',
                      style: TextStyle(
                        color: _isScanning ? Colors.green : Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.event.capacity - widget.event.registeredCount} spots left',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorResult() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 48),
        const SizedBox(height: 12),
        const Text(
          'Check-in Failed',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _resetScanner,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red[800],
          ),
          child: const Text('Try Again'),
        ),
      ],
    );
  }

  Widget _buildSuccessResult() {
    final registration = _scannedRegistration!;
    final isAlreadyCheckedIn =
        registration.isCheckedIn && registration.checkedInAt != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isAlreadyCheckedIn ? Icons.info_outline : Icons.check_circle_outline,
          color: Colors.white,
          size: 48,
        ),
        const SizedBox(height: 12),
        Text(
          isAlreadyCheckedIn ? 'Already Checked In' : 'Check-in Successful!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Name', registration.userName, Icons.person),
              const SizedBox(height: 8),
              if (registration.studentId != null) ...[
                _buildInfoRow(
                  'Student ID',
                  registration.studentId!,
                  Icons.badge,
                ),
                const SizedBox(height: 8),
              ],
              _buildInfoRow(
                'University Email',
                registration.userEmail,
                Icons.school,
              ),
              const SizedBox(height: 8),
              if (registration.personalEmail != null) ...[
                _buildInfoRow(
                  'Personal Email',
                  registration.personalEmail!,
                  Icons.email,
                ),
                const SizedBox(height: 8),
              ],
              if (registration.phoneNumber != null) ...[
                _buildInfoRow('Phone', registration.phoneNumber!, Icons.phone),
                const SizedBox(height: 8),
              ],
              if (registration.batch != null && registration.section != null)
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        'Batch',
                        registration.batch!,
                        Icons.calendar_today,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoRow(
                        'Section',
                        registration.section!,
                        Icons.class_,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (registration.checkedInAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Checked in: ${registration.checkedInAt!.day}/${registration.checkedInAt!.month}/${registration.checkedInAt!.year} at ${registration.checkedInAt!.hour.toString().padLeft(2, '0')}:${registration.checkedInAt!.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _resetScanner,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.green[800],
          ),
          child: const Text('Continue Scanning'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QRScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QRScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()..addRect(rect);
    Path oval = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutSize,
            height: cutOutSize,
          ),
          Radius.circular(borderRadius),
        ),
      );
    return Path.combine(PathOperation.difference, path, oval);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final borderOffset = borderWidth / 2;

    final mArea = ((width - cutOutSize) / 2);
    final mAreaW = ((height - cutOutSize) / 2);

    final overlayPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final mPath = Path();

    // Top-left
    mPath.moveTo(mArea - borderOffset + borderRadius, mAreaW - borderOffset);
    mPath.lineTo(mArea - borderOffset + borderLength, mAreaW - borderOffset);
    mPath.moveTo(mArea - borderOffset, mAreaW - borderOffset + borderRadius);
    mPath.lineTo(mArea - borderOffset, mAreaW - borderOffset + borderLength);

    // Top-right
    mPath.moveTo(
      width - mArea + borderOffset - borderLength,
      mAreaW - borderOffset,
    );
    mPath.lineTo(
      width - mArea + borderOffset - borderRadius,
      mAreaW - borderOffset,
    );
    mPath.moveTo(
      width - mArea + borderOffset,
      mAreaW - borderOffset + borderRadius,
    );
    mPath.lineTo(
      width - mArea + borderOffset,
      mAreaW - borderOffset + borderLength,
    );

    // Bottom-left
    mPath.moveTo(
      mArea - borderOffset + borderRadius,
      height - mAreaW + borderOffset,
    );
    mPath.lineTo(
      mArea - borderOffset + borderLength,
      height - mAreaW + borderOffset,
    );
    mPath.moveTo(
      mArea - borderOffset,
      height - mAreaW + borderOffset - borderRadius,
    );
    mPath.lineTo(
      mArea - borderOffset,
      height - mAreaW + borderOffset - borderLength,
    );

    // Bottom-right
    mPath.moveTo(
      width - mArea + borderOffset - borderLength,
      height - mAreaW + borderOffset,
    );
    mPath.lineTo(
      width - mArea + borderOffset - borderRadius,
      height - mAreaW + borderOffset,
    );
    mPath.moveTo(
      width - mArea + borderOffset,
      height - mAreaW + borderOffset - borderRadius,
    );
    mPath.lineTo(
      width - mArea + borderOffset,
      height - mAreaW + borderOffset - borderLength,
    );

    canvas.drawPath(getOuterPath(rect), overlayPaint);
    canvas.drawPath(mPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QRScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}

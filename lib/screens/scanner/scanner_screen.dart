import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:clipboard/clipboard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartqr_plus/models/qr_history_model.dart';
import 'package:smartqr_plus/services/storage_service.dart';
import 'package:smartqr_plus/utils/app_colors.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isScanning = true;
  String? _lastScannedData;
  QRHistoryModel? _lastScannedQR;
  CameraFacing _currentFacing = CameraFacing.back;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcodeCapture(BarcodeCapture barcodeCapture) {
    if (!_isScanning) return;

    final barcodes = barcodeCapture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    final data = barcode.rawValue!;
    
    // Prevent duplicate scans
    if (data == _lastScannedData) return;
    
    setState(() {
      _lastScannedData = data;
      _isScanning = false;
    });

    _controller.stop();
    
    // Detect QR type
    final qrType = _detectQRType(data);
    
    final qrModel = QRHistoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: data,
      type: qrType,
      createdAt: DateTime.now(),
      isGenerated: false,
    );

    _lastScannedQR = qrModel;
    
    // Save to history
    StorageService().saveQRHistory(qrModel);
    
    // Show result dialog
    _showScanResult(data, qrType);
  }

  QRType _detectQRType(String data) {
    if (data.startsWith('http://') || data.startsWith('https://')) {
      return QRType.url;
    } else if (data.startsWith('tel:')) {
      return QRType.phone;
    } else if (data.startsWith('mailto:')) {
      return QRType.email;
    } else if (data.startsWith('WIFI:')) {
      return QRType.wifi;
    } else if (data.startsWith('BEGIN:VCARD')) {
      return QRType.vcard;
    } else if (data.startsWith('sms:')) {
      return QRType.sms;
    } else {
      return QRType.text;
    }
  }

  void _showScanResult(String data, QRType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScanResultSheet(
        data: data,
        type: type,
        onRescan: () {
          setState(() {
            _lastScannedData = null;
            _isScanning = true;
          });
          _controller.start();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_currentFacing == CameraFacing.front
                ? Icons.camera_rear
                : Icons.camera_front),
            onPressed: () {
              setState(() {
                _currentFacing = _currentFacing == CameraFacing.front
                    ? CameraFacing.back
                    : CameraFacing.front;
              });
              _controller.switchCamera();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcodeCapture,
          ),
          
          // Overlay
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: AppColors.primary,
                borderRadius: 16,
                borderLength: 30,
                cutOutSize: 250,
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withOpacity(0.7)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  _isScanning
                      ? 'Point camera at QR code'
                      : 'QR Code detected!',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          
          // Flashlight Toggle
          Positioned(
            top: 100,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: () {
                _controller.toggleTorch();
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.flashlight_on),
            ),
          ),
        ],
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
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
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _cutOutSize = cutOutSize < width || cutOutSize < height
        ? (width < height ? width * 0.8 : height * 0.8)
        : cutOutSize;
    final _left = (width - _cutOutSize) / 2;
    final _top = (height - _cutOutSize) / 2;
    final _right = _left + _cutOutSize;
    final _bottom = _top + _cutOutSize;

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTRB(0, 0, width, height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(_left, _top, _right, _bottom),
          Radius.circular(borderRadius),
        ),
      );

    canvas.drawPath(path, Paint()..color = overlayColor);

    final _borderPath = Path()
      ..moveTo(_left + borderRadius, _top)
      ..lineTo(_left + borderLength, _top)
      ..moveTo(_left, _top + borderRadius)
      ..lineTo(_left, _top + borderLength)
      ..moveTo(_left + borderRadius, _bottom)
      ..lineTo(_left + borderLength, _bottom)
      ..moveTo(_left, _bottom - borderRadius)
      ..lineTo(_left, _bottom - borderLength)
      ..moveTo(_right - borderLength, _top)
      ..lineTo(_right - borderRadius, _top)
      ..moveTo(_right, _top + borderRadius)
      ..lineTo(_right, _top + borderLength)
      ..moveTo(_right - borderRadius, _bottom)
      ..lineTo(_right - borderLength, _bottom)
      ..moveTo(_right, _bottom - borderRadius)
      ..lineTo(_right, _bottom - borderLength);

    canvas.drawPath(
      _borderPath,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}

class ScanResultSheet extends StatelessWidget {
  final String data;
  final QRType type;
  final VoidCallback onRescan;

  const ScanResultSheet({
    super.key,
    required this.data,
    required this.type,
    required this.onRescan,
  });

  Future<void> _copyToClipboard(BuildContext context) async {
    await FlutterClipboard.copy(data);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  Future<void> _openURL(BuildContext context) async {
    final uri = Uri.tryParse(data);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open URL')),
        );
      }
    }
  }

  Future<void> _openPhone(BuildContext context) async {
    final uri = Uri.parse(data);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openEmail(BuildContext context) async {
    final uri = Uri.parse(data);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    IconData iconData;
    String typeLabel;
    VoidCallback? action;

    switch (type) {
      case QRType.url:
        iconData = Icons.link;
        typeLabel = 'URL';
        action = () => _openURL(context);
        break;
      case QRType.phone:
        iconData = Icons.phone;
        typeLabel = 'Phone';
        action = () => _openPhone(context);
        break;
      case QRType.email:
        iconData = Icons.email;
        typeLabel = 'Email';
        action = () => _openEmail(context);
        break;
      case QRType.wifi:
        iconData = Icons.wifi;
        typeLabel = 'Wi-Fi';
        break;
      case QRType.vcard:
        iconData = Icons.contacts;
        typeLabel = 'Contact';
        break;
      default:
        iconData = Icons.text_fields;
        typeLabel = 'Text';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Scanned successfully',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              data,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: action,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onRescan();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Again'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smartqr_plus/models/qr_history_model.dart';
import 'package:smartqr_plus/screens/generator/widgets/ai_assistant_dialog.dart';
import 'package:smartqr_plus/screens/generator/widgets/customization_panel.dart';
import 'package:smartqr_plus/services/ai_service.dart';
import 'package:smartqr_plus/services/storage_service.dart';
import 'package:smartqr_plus/utils/app_colors.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  String _qrData = 'SmartQR+';
  Color _qrColor = Colors.black;
  Color _backgroundColor = Colors.white;
  double _qrSize = 200;
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _generateQR() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text to generate QR code')),
      );
      return;
    }
    
    setState(() {
      _qrData = _textController.text.trim();
    });
  }

  Future<void> _saveQRCode() async {
    if (_qrData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No QR code to save')),
      );
      return;
    }

    try {
      final RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final result = await ImageGallerySaver.saveImage(
        pngBytes,
        quality: 100,
        name: 'qr_code_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR code saved to gallery')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving QR code: $e')),
        );
      }
    }
  }

  Future<void> _shareQRCode() async {
    if (_qrData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No QR code to share')),
      );
      return;
    }

    try {
      final RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/qr_code.png';
      final file = File(tempPath);
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(tempPath)],
        text: 'Check out this QR code: $_qrData',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing QR code: $e')),
        );
      }
    }
  }

  Future<void> _saveToHistory() async {
    if (_qrData.isEmpty) return;

    final qrType = _detectQRType(_qrData);
    final qrModel = QRHistoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: _qrData,
      type: qrType,
      createdAt: DateTime.now(),
      isGenerated: true,
    );

    await StorageService().saveQRHistory(qrModel);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to history')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generate QR Code',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AI Assistant',
            onPressed: () async {
              final suggestion = await showDialog<String>(
                context: context,
                builder: (context) => const AIAssistantDialog(),
              );
              if (suggestion != null && mounted) {
                _textController.text = suggestion;
                _generateQR();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Enter text, URL, phone, or Wi-Fi credentials...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _generateQR,
                      icon: const Icon(Icons.qr_code_2),
                      label: const Text('Generate QR Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // QR Code Display
            if (_qrData.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.accent.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    RepaintBoundary(
                      key: _qrKey,
                      child: QrImageView(
                        data: _qrData,
                        version: QrVersions.auto,
                        size: _qrSize,
                        backgroundColor: _backgroundColor,
                        foregroundColor: _qrColor,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.save_alt),
                          onPressed: _saveQRCode,
                          tooltip: 'Save to Gallery',
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: _shareQRCode,
                          tooltip: 'Share',
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark_add),
                          onPressed: () {
                            _saveToHistory();
                          },
                          tooltip: 'Save to History',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Customization Panel
            CustomizationPanel(
              qrColor: _qrColor,
              backgroundColor: _backgroundColor,
              qrSize: _qrSize,
              onColorChanged: (color) {
                setState(() {
                  _qrColor = color;
                });
              },
              onBackgroundColorChanged: (color) {
                setState(() {
                  _backgroundColor = color;
                });
              },
              onSizeChanged: (size) {
                setState(() {
                  _qrSize = size;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';
import 'package:smartqr_plus/models/qr_history_model.dart';
import 'package:smartqr_plus/services/storage_service.dart';
import 'package:smartqr_plus/utils/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storageService = StorageService();
  int _selectedTab = 0; // 0: All, 1: Favorites

  @override
  void initState() {
    super.initState();
  }

  Future<void> _deleteQR(String id) async {
    await _storageService.deleteQRHistory(id);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleFavorite(String id) async {
    await _storageService.toggleFavorite(id);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _copyToClipboard(String data) async {
    await FlutterClipboard.copy(data);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  Future<void> _openURL(String data) async {
    final uri = Uri.tryParse(data);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ValueListenableBuilder<Box<QRHistoryModel>>(
            valueListenable: Hive.box<QRHistoryModel>('qr_history').listenable(),
            builder: (context, box, child) {
              if (box.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Clear All',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear All History?'),
                      content: const Text(
                        'This will delete all your QR code history. This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _storageService.clearAllHistory();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('History cleared')),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'All',
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    label: 'Favorites',
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ),
              ],
            ),
          ),
          
          // History List
          Expanded(
            child: ValueListenableBuilder<Box<QRHistoryModel>>(
              valueListenable: Hive.box<QRHistoryModel>('qr_history').listenable(),
              builder: (context, box, child) {
                final allHistory = _storageService.getAllHistory();
                final favorites = _storageService.getFavorites();
                final displayList = _selectedTab == 0 ? allHistory : favorites;
                
                if (displayList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedTab == 0
                              ? Icons.history
                              : Icons.favorite_border,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedTab == 0
                              ? 'No history yet'
                              : 'No favorites yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedTab == 0
                              ? 'Generate or scan QR codes to see them here'
                              : 'Mark QR codes as favorite to see them here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final qr = displayList[index];
                    return _HistoryItem(
                      qr: qr,
                      onDelete: () => _deleteQR(qr.id),
                      onToggleFavorite: () => _toggleFavorite(qr.id),
                      onCopy: () => _copyToClipboard(qr.data),
                      onOpen: qr.type == QRType.url
                          ? () => _openURL(qr.data)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final QRHistoryModel qr;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;
  final VoidCallback onCopy;
  final VoidCallback? onOpen;

  const _HistoryItem({
    required this.qr,
    required this.onDelete,
    required this.onToggleFavorite,
    required this.onCopy,
    this.onOpen,
  });

  IconData _getIcon(QRType type) {
    switch (type) {
      case QRType.url:
        return Icons.link;
      case QRType.phone:
        return Icons.phone;
      case QRType.email:
        return Icons.email;
      case QRType.wifi:
        return Icons.wifi;
      case QRType.vcard:
        return Icons.contacts;
      case QRType.sms:
        return Icons.sms;
      default:
        return Icons.text_fields;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => _QRDetailsSheet(qr: qr),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(qr.type),
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              qr.title ?? _getTypeLabel(qr.type),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (qr.isFavorite)
                            const Icon(
                              Icons.favorite,
                              size: 16,
                              color: Colors.red,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        qr.data,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            qr.isGenerated ? Icons.qr_code_2 : Icons.qr_code_scanner,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatDate(qr.createdAt)} • ${qr.isGenerated ? "Generated" : "Scanned"}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            qr.isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(qr.isFavorite ? 'Unfavorite' : 'Favorite'),
                        ],
                      ),
                      onTap: () => Future.delayed(
                        const Duration(milliseconds: 100),
                        onToggleFavorite,
                      ),
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.copy, size: 20),
                          SizedBox(width: 12),
                          Text('Copy'),
                        ],
                      ),
                      onTap: () => Future.delayed(
                        const Duration(milliseconds: 100),
                        onCopy,
                      ),
                    ),
                    if (onOpen != null)
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.open_in_new, size: 20),
                            SizedBox(width: 12),
                            Text('Open'),
                          ],
                        ),
                        onTap: () => Future.delayed(
                          const Duration(milliseconds: 100),
                          onOpen!,
                        ),
                      ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () => Future.delayed(
                        const Duration(milliseconds: 100),
                        onDelete,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(QRType type) {
    switch (type) {
      case QRType.url:
        return 'URL';
      case QRType.phone:
        return 'Phone';
      case QRType.email:
        return 'Email';
      case QRType.wifi:
        return 'Wi-Fi';
      case QRType.vcard:
        return 'Contact';
      case QRType.sms:
        return 'SMS';
      default:
        return 'Text';
    }
  }
}

class _QRDetailsSheet extends StatelessWidget {
  final QRHistoryModel qr;

  const _QRDetailsSheet({required this.qr});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          Text(
            qr.title ?? 'QR Code Details',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              qr.data,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Created: ${qr.createdAt.toString().substring(0, 19)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


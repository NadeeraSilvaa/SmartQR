import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartqr_plus/models/qr_history_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late Box<QRHistoryModel> _historyBox;
  late Box _favoritesBox;

  Future<void> init() async {
    _historyBox = Hive.box<QRHistoryModel>('qr_history');
    _favoritesBox = Hive.box('favorites');
  }

  // History Operations
  Future<void> saveQRHistory(QRHistoryModel qrModel) async {
    await _historyBox.put(qrModel.id, qrModel);
  }

  List<QRHistoryModel> getAllHistory() {
    return _historyBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<QRHistoryModel> getFavorites() {
    return _historyBox.values
        .where((qr) => qr.isFavorite)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> deleteQRHistory(String id) async {
    await _historyBox.delete(id);
  }

  Future<void> clearAllHistory() async {
    await _historyBox.clear();
  }

  Future<void> toggleFavorite(String id) async {
    final qr = _historyBox.get(id);
    if (qr != null) {
      final updated = qr.copyWith(isFavorite: !qr.isFavorite);
      await _historyBox.put(id, updated);
    }
  }

  QRHistoryModel? getQRById(String id) {
    return _historyBox.get(id);
  }
}


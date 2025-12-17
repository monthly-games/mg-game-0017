import 'package:flutter/foundation.dart';

/// Manages game economy (currencies)
class EconomyManager extends ChangeNotifier {
  int _gold = 500;
  int _gems = 10;

  int get gold => _gold;
  int get gems => _gems;

  /// Add gold
  void addGold(int amount) {
    _gold += amount;
    notifyListeners();
  }

  /// Spend gold (returns false if not enough)
  bool spendGold(int amount) {
    if (_gold < amount) return false;
    _gold -= amount;
    notifyListeners();
    return true;
  }

  /// Add gems
  void addGems(int amount) {
    _gems += amount;
    notifyListeners();
  }

  /// Spend gems (returns false if not enough)
  bool spendGems(int amount) {
    if (_gems < amount) return false;
    _gems -= amount;
    notifyListeners();
    return true;
  }

  /// Calculate offline income (when player returns)
  void calculateOfflineIncome(Duration offlineDuration) {
    // Cap at 8 hours
    final cappedSeconds = offlineDuration.inSeconds.clamp(0, 8 * 60 * 60);

    // Base idle income: 10 gold per minute
    final idleGold = (cappedSeconds / 60 * 10).toInt();

    if (idleGold > 0) {
      addGold(idleGold);
    }
  }

  /// Reset economy (for testing)
  void reset() {
    _gold = 500;
    _gems = 10;
    notifyListeners();
  }
}

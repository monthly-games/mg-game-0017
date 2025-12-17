import 'package:flutter/foundation.dart';
import 'achievement_data.dart';

/// Achievement progress tracker
class AchievementProgress {
  final Achievement achievement;
  int currentValue;
  bool claimed;

  AchievementProgress({
    required this.achievement,
    this.currentValue = 0,
    this.claimed = false,
  });

  bool get isComplete => currentValue >= achievement.targetValue;
  bool get canClaim => isComplete && !claimed;

  double get progress => (currentValue / achievement.targetValue).clamp(0.0, 1.0);
}

/// Manages achievements and progress
class AchievementManager extends ChangeNotifier {
  final Map<String, AchievementProgress> _progress = {};

  // Statistics
  int _totalItemsCrafted = 0;
  int _totalItemsSold = 0;
  int _totalGoldEarned = 0;
  int _totalStationUpgrades = 0;
  int _totalRecipesUnlocked = 0;
  int _totalDungeonsExplored = 0;

  AchievementManager() {
    // Initialize all achievements
    for (final achievement in Achievements.all) {
      _progress[achievement.id] = AchievementProgress(achievement: achievement);
    }
  }

  List<AchievementProgress> get allProgress => _progress.values.toList();

  List<AchievementProgress> get unclaimedAchievements {
    return _progress.values.where((p) => p.canClaim).toList();
  }

  int get totalAchievements => Achievements.all.length;
  int get completedAchievements => _progress.values.where((p) => p.claimed).length;

  /// Record item crafted
  void recordItemCrafted() {
    _totalItemsCrafted++;
    _updateProgress(AchievementType.craftItems, _totalItemsCrafted);
  }

  /// Record item sold
  void recordItemSold() {
    _totalItemsSold++;
    _updateProgress(AchievementType.sellItems, _totalItemsSold);
  }

  /// Record gold earned
  void recordGoldEarned(int amount) {
    _totalGoldEarned += amount;
    _updateProgress(AchievementType.earnGold, _totalGoldEarned);
  }

  /// Record station upgrade
  void recordStationUpgrade() {
    _totalStationUpgrades++;
    _updateProgress(AchievementType.upgradeStations, _totalStationUpgrades);
  }

  /// Record recipe unlocked
  void recordRecipeUnlocked() {
    _totalRecipesUnlocked++;
    _updateProgress(AchievementType.unlockRecipes, _totalRecipesUnlocked);
  }

  /// Record dungeon explored
  void recordDungeonExplored() {
    _totalDungeonsExplored++;
    _updateProgress(AchievementType.exploreDungeons, _totalDungeonsExplored);
  }

  /// Update achievement progress
  void _updateProgress(AchievementType type, int value) {
    bool anyUpdated = false;

    for (final progress in _progress.values) {
      if (progress.achievement.type == type && !progress.claimed) {
        if (progress.currentValue != value) {
          progress.currentValue = value;
          anyUpdated = true;
        }
      }
    }

    if (anyUpdated) {
      notifyListeners();
    }
  }

  /// Claim achievement reward
  AchievementReward? claimAchievement(String achievementId) {
    final progress = _progress[achievementId];
    if (progress == null || !progress.canClaim) return null;

    progress.claimed = true;
    notifyListeners();

    return progress.achievement.reward;
  }

  /// Get statistics
  Map<String, int> getStatistics() {
    return {
      'itemsCrafted': _totalItemsCrafted,
      'itemsSold': _totalItemsSold,
      'goldEarned': _totalGoldEarned,
      'stationUpgrades': _totalStationUpgrades,
      'recipesUnlocked': _totalRecipesUnlocked,
      'dungeonsExplored': _totalDungeonsExplored,
    };
  }

  /// Load progress from save data
  void loadProgress(Map<String, dynamic> data) {
    _totalItemsCrafted = data['itemsCrafted'] ?? 0;
    _totalItemsSold = data['itemsSold'] ?? 0;
    _totalGoldEarned = data['goldEarned'] ?? 0;
    _totalStationUpgrades = data['stationUpgrades'] ?? 0;
    _totalRecipesUnlocked = data['recipesUnlocked'] ?? 0;
    _totalDungeonsExplored = data['dungeonsExplored'] ?? 0;

    final claimed = (data['claimed'] as List?)?.cast<String>() ?? [];
    for (final id in claimed) {
      if (_progress.containsKey(id)) {
        _progress[id]!.claimed = true;
      }
    }

    // Update all progress values
    _updateProgress(AchievementType.craftItems, _totalItemsCrafted);
    _updateProgress(AchievementType.sellItems, _totalItemsSold);
    _updateProgress(AchievementType.earnGold, _totalGoldEarned);
    _updateProgress(AchievementType.upgradeStations, _totalStationUpgrades);
    _updateProgress(AchievementType.unlockRecipes, _totalRecipesUnlocked);
    _updateProgress(AchievementType.exploreDungeons, _totalDungeonsExplored);

    notifyListeners();
  }

  /// Save progress to map
  Map<String, dynamic> toSaveData() {
    return {
      'itemsCrafted': _totalItemsCrafted,
      'itemsSold': _totalItemsSold,
      'goldEarned': _totalGoldEarned,
      'stationUpgrades': _totalStationUpgrades,
      'recipesUnlocked': _totalRecipesUnlocked,
      'dungeonsExplored': _totalDungeonsExplored,
      'claimed': _progress.values
          .where((p) => p.claimed)
          .map((p) => p.achievement.id)
          .toList(),
    };
  }
}

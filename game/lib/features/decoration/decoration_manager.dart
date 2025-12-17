import 'package:flutter/foundation.dart';
import 'decoration_data.dart';

/// Manages shop decorations
class DecorationManager extends ChangeNotifier {
  // Purchased decorations
  final Set<String> _ownedDecorations = {
    'theme_classic',
    'counter_wood',
    'floor_stone',
    'wall_plain',
    'light_torch',
  };

  // Currently equipped decorations
  String _equippedTheme = 'theme_classic';
  String _equippedCounter = 'counter_wood';
  String _equippedFloor = 'floor_stone';
  String _equippedWall = 'wall_plain';
  String _equippedLighting = 'light_torch';

  Set<String> get ownedDecorations => Set.unmodifiable(_ownedDecorations);

  Decoration? get equippedTheme => Decorations.getById(_equippedTheme);
  Decoration? get equippedCounter => Decorations.getById(_equippedCounter);
  Decoration? get equippedFloor => Decorations.getById(_equippedFloor);
  Decoration? get equippedWall => Decorations.getById(_equippedWall);
  Decoration? get equippedLighting => Decorations.getById(_equippedLighting);

  /// Check if decoration is owned
  bool isOwned(String decorationId) {
    return _ownedDecorations.contains(decorationId);
  }

  /// Check if decoration is equipped
  bool isEquipped(String decorationId) {
    return decorationId == _equippedTheme ||
        decorationId == _equippedCounter ||
        decorationId == _equippedFloor ||
        decorationId == _equippedWall ||
        decorationId == _equippedLighting;
  }

  /// Purchase decoration
  bool purchaseDecoration(String decorationId, Function(int) spendGold, Function(int) spendGems) {
    if (isOwned(decorationId)) return false;

    final decoration = Decorations.getById(decorationId);
    if (decoration == null) return false;

    // Spend gold
    if (!spendGold(decoration.goldCost)) return false;

    // Spend gems if required
    if (decoration.gemCost != null) {
      if (!spendGems(decoration.gemCost!)) {
        // Refund gold if gem purchase fails
        return false;
      }
    }

    _ownedDecorations.add(decorationId);
    notifyListeners();
    return true;
  }

  /// Equip decoration
  bool equipDecoration(String decorationId) {
    if (!isOwned(decorationId)) return false;

    final decoration = Decorations.getById(decorationId);
    if (decoration == null) return false;

    switch (decoration.type) {
      case DecorationType.theme:
        _equippedTheme = decorationId;
        break;
      case DecorationType.counter:
        _equippedCounter = decorationId;
        break;
      case DecorationType.floor:
        _equippedFloor = decorationId;
        break;
      case DecorationType.wall:
        _equippedWall = decorationId;
        break;
      case DecorationType.lighting:
        _equippedLighting = decorationId;
        break;
    }

    notifyListeners();
    return true;
  }

  /// Get decorations by type
  List<Decoration> getDecorationsByType(DecorationType type) {
    return Decorations.getAllByType(type);
  }

  /// Load from save data
  void loadFromSave(Map<String, dynamic> data) {
    _ownedDecorations.clear();
    _ownedDecorations.addAll((data['owned'] as List?)?.cast<String>() ?? [
      'theme_classic',
      'counter_wood',
      'floor_stone',
      'wall_plain',
      'light_torch',
    ]);

    _equippedTheme = data['theme'] ?? 'theme_classic';
    _equippedCounter = data['counter'] ?? 'counter_wood';
    _equippedFloor = data['floor'] ?? 'floor_stone';
    _equippedWall = data['wall'] ?? 'wall_plain';
    _equippedLighting = data['lighting'] ?? 'light_torch';

    notifyListeners();
  }

  /// Save to map
  Map<String, dynamic> toSaveData() {
    return {
      'owned': _ownedDecorations.toList(),
      'theme': _equippedTheme,
      'counter': _equippedCounter,
      'floor': _equippedFloor,
      'wall': _equippedWall,
      'lighting': _equippedLighting,
    };
  }
}

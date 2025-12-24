import 'package:flutter/foundation.dart';
import 'dart:math';
import '../crafting/crafting_manager.dart';
import '../crafting/recipe_data.dart';

/// Customer preferences for shopping
class Customer {
  final String name;
  final ItemType? preferredType;
  final Quality minQuality;
  final double budget;

  Customer({
    required this.name,
    this.preferredType,
    required this.minQuality,
    required this.budget,
  });

  /// Check if customer is interested in an item
  bool isInterested(CraftedItem item) {
    // Check type preference
    if (preferredType != null && item.type != preferredType) {
      return false;
    }

    // Check quality minimum
    if (item.quality.index < minQuality.index) {
      return false;
    }

    // Check budget
    if (item.sellPrice > budget) {
      return false;
    }

    return true;
  }

  /// Generate a random customer
  static Customer generateRandom(Random random) {
    final names = [
      '전사 카일',
      '마법사 루나',
      '도적 섀도우',
      '성기사 알렉스',
      '사냥꾼 로건',
      '연금술사 에밀리',
      '상인 마르코',
      '모험가 제인',
    ];

    final types = [null, ...ItemType.values]; // null = no preference
    final qualities = Quality.values;

    return Customer(
      name: names[random.nextInt(names.length)],
      preferredType: types[random.nextInt(types.length)],
      minQuality: qualities[random.nextInt(qualities.length)],
      budget: (random.nextDouble() * 800 + 200), // 200-1000 gold
    );
  }
}

/// Manages the shop, customers, and sales
class ShopManager extends ChangeNotifier {
  final CraftingManager _craftingManager;
  final Random _random = Random();

  // Display slots
  int _maxDisplaySlots = 3;
  final List<CraftedItem> _displayedItems = [];

  // Current visiting customer
  Customer? _currentCustomer;
  DateTime? _customerArrivalTime;
  static const Duration customerStayDuration = Duration(seconds: 30);

  // Shop level and upgrades
  int _shopLevel = 1;

  ShopManager(this._craftingManager);

  int get maxDisplaySlots => _maxDisplaySlots;
  List<CraftedItem> get displayedItems => List.unmodifiable(_displayedItems);
  Customer? get currentCustomer => _currentCustomer;
  int get shopLevel => _shopLevel;

  /// Check if customer is still present
  bool get isCustomerPresent {
    if (_currentCustomer == null || _customerArrivalTime == null) return false;

    final now = DateTime.now();
    return now.difference(_customerArrivalTime!).inSeconds <
        customerStayDuration.inSeconds;
  }

  /// Get time until customer leaves
  Duration get customerTimeRemaining {
    if (!isCustomerPresent) return Duration.zero;

    final elapsed = DateTime.now().difference(_customerArrivalTime!);
    final remaining = customerStayDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Display an item in the shop
  bool displayItem(CraftedItem item) {
    if (_displayedItems.length >= _maxDisplaySlots) return false;

    // Remove from crafting manager's completed items
    _craftingManager.removeItem(item);

    _displayedItems.add(item);
    notifyListeners();
    return true;
  }

  /// Remove an item from display
  bool removeFromDisplay(CraftedItem item) {
    if (_displayedItems.remove(item)) {
      // Return to completed items
      _craftingManager.completedItems.add(item);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Spawn a new customer
  void spawnCustomer() {
    if (_currentCustomer != null && isCustomerPresent) return;

    _currentCustomer = Customer.generateRandom(_random);
    _customerArrivalTime = DateTime.now();
    notifyListeners();
  }

  /// Customer leaves without buying
  void customerLeaves() {
    _currentCustomer = null;
    _customerArrivalTime = null;
    notifyListeners();
  }

  /// Try to sell an item to the current customer
  int? sellItem(CraftedItem item) {
    if (_currentCustomer == null) return null;
    if (!_currentCustomer!.isInterested(item)) return null;
    if (!_displayedItems.contains(item)) return null;

    // Remove item from display
    _displayedItems.remove(item);

    // Customer leaves after purchase
    final sellPrice = item.sellPrice;
    _currentCustomer = null;
    _customerArrivalTime = null;

    notifyListeners();
    return sellPrice;
  }

  /// Expand shop display slots
  bool expandShop(int additionalSlots, int goldCost, Function(int) spendGold) {
    if (!spendGold(goldCost)) return false;

    _maxDisplaySlots += additionalSlots;
    _shopLevel++;
    notifyListeners();
    return true;
  }

  /// Update shop (call in game loop)
  void update() {
    // Check if customer should leave
    if (_currentCustomer != null && !isCustomerPresent) {
      customerLeaves();
    }

    // Randomly spawn customers if none present
    if (_currentCustomer == null && _random.nextDouble() < 0.01) {
      // 1% chance per update
      spawnCustomer();
    }
  }

  /// Get items customer would buy from display
  List<CraftedItem> getCustomerInterests() {
    if (_currentCustomer == null) return [];
    return _displayedItems
        .where((item) => _currentCustomer!.isInterested(item))
        .toList();
  }

  /// Load shop state directly
  void loadState(int maxSlots, int level) {
    _maxDisplaySlots = maxSlots;
    _shopLevel = level;
    notifyListeners();
  }
}

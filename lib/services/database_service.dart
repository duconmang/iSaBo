import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../models/savings_goal.dart';
import '../models/savings_tile_data.dart';

final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService(),
);

class DatabaseService {
  // Multi-goal support: map goalId -> tiles
  Map<int, List<SavingsTileData>> _goalTiles = {};
  List<SavingsGoal> _goals = [];
  int _currentGoalId = 1;

  final _tilesController = StreamController<List<SavingsTileData>>.broadcast();
  final _goalController = StreamController<SavingsGoal?>.broadcast();
  final _goalsController = StreamController<List<SavingsGoal>>.broadcast();

  Stream<List<SavingsTileData>> get tilesStream => _tilesController.stream;
  Stream<SavingsGoal?> get goalStream => _goalController.stream;
  Stream<List<SavingsGoal>> get goalsStream => _goalsController.stream;

  List<SavingsTileData> get tiles => _goalTiles[_currentGoalId] ?? [];
  SavingsGoal? get goal => _goals.firstWhere(
    (g) => g.id == _currentGoalId,
    orElse: () => SavingsGoal(),
  );
  List<SavingsGoal> get goals => _goals;

  // Get tiles for a specific goal
  List<SavingsTileData> getTilesForGoal(int goalId) => _goalTiles[goalId] ?? [];

  // Check if user has "fed the pig" (saved any tile) today across all goals
  bool hasFedToday() {
    final today = DateTime.now();
    for (final tiles in _goalTiles.values) {
      for (final tile in tiles) {
        if (tile.isPaid && tile.paidAt != null) {
          final paidDate = tile.paidAt!;
          if (paidDate.year == today.year &&
              paidDate.month == today.month &&
              paidDate.day == today.day) {
            return true;
          }
        }
      }
    }
    return false;
  }

  late Directory _dbDir;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    // On Windows, use a specific subdirectory to avoid accidental deletion
    _dbDir = Directory('${dir.path}/DigitalSavingBox/data');
    if (!await _dbDir.exists()) {
      await _dbDir.create(recursive: true);
    }

    await _loadData();

    // Update saved amounts for all goals
    _updateGoalSavedAmounts();

    // Emit initial data
    _tilesController.add(tiles);
    _goalController.add(goal);
    _goalsController.add(_goals);
  }

  void _updateGoalSavedAmounts() {
    for (var goal in _goals) {
      final goalTiles = _goalTiles[goal.id] ?? [];
      final saved = goalTiles
          .where((t) => t.isPaid)
          .fold(0, (sum, t) => sum + t.amount);
      goal.savedAmount = saved.toDouble();
    }
  }

  Future<void> _loadData() async {
    final dataFile = File('${_dbDir.path}/all_data.json');

    // Try new multi-goal format first
    if (await dataFile.exists()) {
      final content = await dataFile.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      // Load goals
      final goalsList = (data['goals'] as List?) ?? [];
      _goals = goalsList.map((e) => SavingsGoal.fromJson(e)).toList();

      // Load tiles per goal
      final tilesMap = (data['goalTiles'] as Map<String, dynamic>?) ?? {};
      _goalTiles = {};
      tilesMap.forEach((key, value) {
        final goalId = int.parse(key);
        final tilesList = (value as List)
            .map((e) => SavingsTileData.fromJson(e))
            .toList();
        _goalTiles[goalId] = tilesList;
      });

      _currentGoalId = data['currentGoalId'] ?? 1;
    } else {
      // Try legacy single-goal format
      final tilesFile = File('${_dbDir.path}/tiles.json');
      final goalFile = File('${_dbDir.path}/goal.json');

      if (await tilesFile.exists()) {
        final content = await tilesFile.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        final legacyTiles = jsonList
            .map((e) => SavingsTileData.fromJson(e))
            .toList();
        _goalTiles[1] = legacyTiles;
      }

      if (await goalFile.exists()) {
        final content = await goalFile.readAsString();
        final legacyGoal = SavingsGoal.fromJson(jsonDecode(content));
        _goals = [legacyGoal];
        _currentGoalId = legacyGoal.id;
      }
    }
  }

  Future<void> _saveData() async {
    final dataFile = File('${_dbDir.path}/all_data.json');

    final tilesMap = <String, dynamic>{};
    _goalTiles.forEach((goalId, tilesList) {
      tilesMap[goalId.toString()] = tilesList.map((e) => e.toJson()).toList();
    });

    final data = {
      'goals': _goals.map((e) => e.toJson()).toList(),
      'goalTiles': tilesMap,
      'currentGoalId': _currentGoalId,
    };

    await dataFile.writeAsString(jsonEncode(data));
  }

  // Generate tiles using selected denominations to reach target amount
  List<SavingsTileData> _generateTilesForTarget({
    required double targetAmount,
    required List<int> denominations,
  }) {
    final random = Random();
    final tiles = <SavingsTileData>[];
    var remaining = targetAmount.toInt();
    var tileId = 1;

    // Sort denominations descending for efficient filling
    final sortedDenoms = List<int>.from(denominations)
      ..sort((a, b) => b.compareTo(a));
    final smallestDenom = sortedDenoms.last;

    while (remaining > 0) {
      // Filter denominations that can still fit
      final validDenoms = sortedDenoms.where((d) => d <= remaining).toList();

      if (validDenoms.isEmpty) {
        // If remaining is less than smallest denomination, add one more tile of smallest
        tiles.add(
          SavingsTileData(id: tileId++, amount: smallestDenom, isPaid: false),
        );
        break;
      }

      // Randomly select a denomination from valid ones
      final selectedDenom = validDenoms[random.nextInt(validDenoms.length)];

      tiles.add(
        SavingsTileData(id: tileId++, amount: selectedDenom, isPaid: false),
      );

      remaining -= selectedDenom;
    }

    // Shuffle tiles for random order
    tiles.shuffle(random);

    // Reassign IDs after shuffle
    for (var i = 0; i < tiles.length; i++) {
      tiles[i].id = i + 1;
    }

    return tiles;
  }

  Future<void> createNewGoal(
    String name, {
    required double targetAmount,
    required List<int> denominations,
    String? bankId,
    String? accountNo,
    String? accountName,
  }) async {
    final nextId =
        (_goals.map((g) => g.id).fold(0, (a, b) => a > b ? a : b)) + 1;

    // Generate tiles using selected denominations
    final newTiles = _generateTilesForTarget(
      targetAmount: targetAmount,
      denominations: denominations,
    );

    final newGoal = SavingsGoal(
      id: nextId,
      name: name,
      targetAmount: targetAmount,
      startDate: DateTime.now(),
      bankId: bankId,
      accountNo: accountNo,
      accountName: accountName,
    );

    _goals.add(newGoal);
    _goalTiles[nextId] = newTiles;
    _currentGoalId = nextId;

    await _saveData();
    _tilesController.add(tiles);
    _goalController.add(goal);
    _goalsController.add(_goals);
  }

  void switchToGoal(int goalId) {
    if (_goalTiles.containsKey(goalId)) {
      _currentGoalId = goalId;
      _tilesController.add(tiles);
      _goalController.add(goal);
    }
  }

  Future<void> deleteGoal(int goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
    _goalTiles.remove(goalId);

    // Switch to first remaining goal if current was deleted
    if (_currentGoalId == goalId && _goals.isNotEmpty) {
      _currentGoalId = _goals.first.id;
    } else if (_goals.isEmpty) {
      _currentGoalId = 0;
    }

    await _saveData();
    _tilesController.add(tiles);
    _goalController.add(goal);
    _goalsController.add(_goals);
  }

  Future<List<SavingsTileData>> getAllTiles() async {
    return List.from(tiles)..sort((a, b) => a.amount.compareTo(b.amount));
  }

  Stream<List<SavingsTileData>> watchTiles() {
    // Emit current data immediately, then stream updates
    return tilesStream.asBroadcastStream();
  }

  Future<SavingsGoal?> getGoal() async {
    return goal;
  }

  Stream<SavingsGoal?> watchGoal() {
    return goalStream.asBroadcastStream();
  }

  Future<void> markTilePaid(int id) async {
    final currentTiles = _goalTiles[_currentGoalId];
    if (currentTiles == null) return;

    final index = currentTiles.indexWhere((t) => t.id == id);
    if (index != -1) {
      currentTiles[index].isPaid = true;
      currentTiles[index].paidAt = DateTime.now();
      _updateGoalSavedAmounts();
      await _saveData();
      _tilesController.add(tiles);
      _goalsController.add(_goals);
    }
  }

  Future<void> markTileUnpaid(int id) async {
    final currentTiles = _goalTiles[_currentGoalId];
    if (currentTiles == null) return;

    final index = currentTiles.indexWhere((t) => t.id == id);
    if (index != -1) {
      currentTiles[index].isPaid = false;
      currentTiles[index].paidAt = null;
      _updateGoalSavedAmounts();
      await _saveData();
      _tilesController.add(tiles);
      _goalsController.add(_goals);
    }
  }

  // For export/import compatibility
  Future<Map<String, dynamic>> exportToJson() async {
    final tilesMap = <String, dynamic>{};
    _goalTiles.forEach((goalId, tilesList) {
      tilesMap[goalId.toString()] = tilesList.map((e) => e.toJson()).toList();
    });

    return {
      'meta': {'exportedAt': DateTime.now().toIso8601String()},
      'goals': _goals.map((e) => e.toJson()).toList(),
      'goalTiles': tilesMap,
    };
  }

  Future<void> importFromJson(Map<String, dynamic> data) async {
    // Clear and import
    _goals.clear();
    _goalTiles.clear();

    final goalsData = (data['goals'] as List?) ?? [];
    _goals = goalsData.map((e) => SavingsGoal.fromJson(e)).toList();

    final tilesMap = (data['goalTiles'] as Map<String, dynamic>?) ?? {};
    tilesMap.forEach((key, value) {
      final goalId = int.parse(key);
      final tilesList = (value as List)
          .map((e) => SavingsTileData.fromJson(e))
          .toList();
      _goalTiles[goalId] = tilesList;
    });

    if (_goals.isNotEmpty) {
      _currentGoalId = _goals.first.id;
    }

    _updateGoalSavedAmounts();
    await _saveData();
    _tilesController.add(tiles);
    _goalController.add(goal);
    _goalsController.add(_goals);
  }

  void dispose() {
    _tilesController.close();
    _goalController.close();
    _goalsController.close();
  }
}

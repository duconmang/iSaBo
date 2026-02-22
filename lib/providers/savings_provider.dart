import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../models/savings_tile_data.dart';
import '../models/savings_goal.dart';

// Tiles Provider using Stream
final savingsTilesProvider = StreamProvider.autoDispose<List<SavingsTileData>>((
  ref,
) async* {
  final dbService = ref.watch(databaseServiceProvider);
  // Emit initial data
  yield dbService.tiles;
  // Then watch for updates
  await for (final tiles in dbService.tilesStream) {
    yield tiles;
  }
});

// Goal Provider using Stream
final savingsGoalProvider = StreamProvider.autoDispose<SavingsGoal?>((
  ref,
) async* {
  final dbService = ref.watch(databaseServiceProvider);
  yield dbService.goal;
  await for (final goal in dbService.goalStream) {
    yield goal;
  }
});

// All Goals Provider
final allGoalsProvider = StreamProvider.autoDispose<List<SavingsGoal>>((
  ref,
) async* {
  final dbService = ref.watch(databaseServiceProvider);
  yield dbService.goals;
  await for (final goals in dbService.goalsStream) {
    yield goals;
  }
});

// Calculate current saving percentage (0-100)
final savingsProgressProvider = Provider.autoDispose<double>((ref) {
  final tilesAsync = ref.watch(savingsTilesProvider);

  return tilesAsync.when(
    data: (tiles) {
      if (tiles.isEmpty) return 0.0;
      final paidAmount = tiles
          .where((t) => t.isPaid)
          .fold(0, (sum, t) => sum + t.amount);
      final totalAmount = tiles.fold(0, (sum, t) => sum + t.amount);
      if (totalAmount == 0) return 0.0;
      return (paidAmount / totalAmount) * 100;
    },
    error: (_, __) => 0.0,
    loading: () => 0.0,
  );
});

final totalSavedProvider = Provider.autoDispose<int>((ref) {
  final tilesAsync = ref.watch(savingsTilesProvider);

  return tilesAsync.when(
    data: (tiles) {
      if (tiles.isEmpty) return 0;
      return tiles.where((t) => t.isPaid).fold(0, (sum, t) => sum + t.amount);
    },
    error: (_, __) => 0,
    loading: () => 0,
  );
});

// Saving Streak Stats Provider
final savingStreakProvider = Provider.autoDispose<Map<String, int>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  final goals = dbService.goals;

  // Goals completed (progress >= 100%)
  final goalsDone = goals.where((g) => g.progress >= 100).length;

  // Collect all paid tiles from all goals with paidAt dates
  final allPaidDates = <DateTime>[];
  for (var goal in goals) {
    final goalTiles = dbService.getTilesForGoal(goal.id);
    for (var tile in goalTiles) {
      if (tile.isPaid && tile.paidAt != null) {
        allPaidDates.add(
          DateTime(tile.paidAt!.year, tile.paidAt!.month, tile.paidAt!.day),
        );
      }
    }
  }

  // This month count
  final now = DateTime.now();
  final thisMonth = allPaidDates
      .where((d) => d.year == now.year && d.month == now.month)
      .length;

  // Day streak - count consecutive days from today backwards
  int dayStreak = 0;
  if (allPaidDates.isNotEmpty) {
    final uniqueDates = allPaidDates.toSet().toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if most recent is today or yesterday
    if (uniqueDates.isNotEmpty &&
        (uniqueDates.first == today || uniqueDates.first == yesterday)) {
      dayStreak = 1;
      var checkDate = uniqueDates.first.subtract(const Duration(days: 1));

      for (var i = 1; i < uniqueDates.length; i++) {
        if (uniqueDates[i] == checkDate) {
          dayStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (uniqueDates[i].isBefore(checkDate)) {
          break;
        }
      }
    }
  }

  return {
    'dayStreak': dayStreak,
    'thisMonth': thisMonth,
    'goalsDone': goalsDone,
  };
});

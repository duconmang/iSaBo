import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'widgets/background_ripple.dart';
import 'widgets/glass_card.dart';
import 'widgets/savings_tile.dart';
import 'widgets/bottom_nav.dart';
import 'services/database_service.dart';
import 'services/payment_service.dart'
    show PaymentService, paymentServiceProvider;
import 'services/notification_service.dart';
import 'providers/savings_provider.dart';
import 'models/savings_tile_data.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/pig_overlay_screen.dart';
import 'l10n/app_localizations.dart';
import 'data/viet_banks.dart';

// Global navigator key for notification handling
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global database service reference for notification checks
DatabaseService? _globalDbService;

// Flag for showing pig overlay after app launch
bool _shouldShowPigOverlay = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file not found. Using default/empty values.");
  }

  final dbService = DatabaseService();
  await dbService.init();
  _globalDbService = dbService; // Store reference for notification checks

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();

  // Check if app was launched from notification (cold start)
  // Only show pig overlay if user hasn't fed today
  if (NotificationService.launchedFromNotification &&
      NotificationService.launchPayload == 'pig_overlay' &&
      !dbService.hasFedToday()) {
    _shouldShowPigOverlay = true;
    NotificationService.clearLaunchFlag();
  } else if (NotificationService.launchedFromNotification) {
    NotificationService.clearLaunchFlag();
  }

  // Set notification tap callback for when app is already running
  NotificationService.setNotificationTapCallback((payload) {
    if (payload == 'pig_overlay') {
      // Only show pig overlay if user hasn't fed today
      if (_globalDbService != null && !_globalDbService!.hasFedToday()) {
        _showPigOverlay();
      }
    }
  });

  runApp(
    ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(dbService),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const DigitalSavingBoxApp(),
    ),
  );
}

void _showPigOverlay() {
  final context = navigatorKey.currentContext;
  if (context != null) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return PigOverlayScreen(
            onFeed: () {
              Navigator.of(context).pop();
              // Navigate to main app (already there)
            },
            onSkip: () {
              Navigator.of(context).pop();
            },
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class DigitalSavingBoxApp extends StatelessWidget {
  const DigitalSavingBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Digital Saving Box',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
      ),
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends ConsumerStatefulWidget {
  const MainNavigator({super.key});

  @override
  ConsumerState<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends ConsumerState<MainNavigator> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Check if app was launched from notification and should show pig overlay
    if (_shouldShowPigOverlay) {
      _shouldShowPigOverlay = false;
      // Show pig overlay after first frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPigOverlay();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: const [DashboardScreen(), StatsScreen(), SettingsScreen()],
      ),
      bottomNavigationBar: GlassBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final PageController _pageController = PageController();
  int _currentGoalIndex = 0;

  void _handleTileTap(SavingsTileData tile) {
    // Get services from ref BEFORE opening dialog
    final dbService = ref.read(databaseServiceProvider);
    final paymentService = ref.read(paymentServiceProvider);
    final currentGoal = dbService.goal;

    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        tile: tile,
        dbService: dbService,
        paymentService: paymentService,
        bankId: currentGoal?.bankId,
        accountNo: currentGoal?.accountNo,
        accountName: currentGoal?.accountName,
      ),
    );
  }

  void _showCreateGoalDialog() {
    final l10n = AppLocalizations.of(ref);
    final nameController = TextEditingController();
    final targetAmountController = TextEditingController();
    final bankIdController = TextEditingController();
    final accountNoController = TextEditingController();
    final accountNameController = TextEditingController();
    VietBank? selectedBank;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.createNewGoal,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildGlassTextField(
                        controller: nameController,
                        labelText: l10n.goalName,
                        hintText: l10n.goalNameHint,
                        prefixIcon: Icons.flag_outlined,
                      ),
                      const SizedBox(height: 10),
                      _buildGlassTextField(
                        controller: targetAmountController,
                        labelText: l10n.targetAmount,
                        hintText: l10n.targetAmountHint,
                        prefixIcon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_balance,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    l10n.bankInfo,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Bank Dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<VietBank>(
                                  isExpanded: true,
                                  hint: Text(
                                    l10n.selectBank,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  value: selectedBank,
                                  dropdownColor: const Color(0xFF4A3A8A),
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                  items: VietBanks.banks.map((bank) {
                                    return DropdownMenuItem<VietBank>(
                                      value: bank,
                                      child: Text(
                                        bank.shortName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (bank) {
                                    setDialogState(() {
                                      selectedBank = bank;
                                      if (bank != null) {
                                        bankIdController.text = bank.bin;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildGlassTextField(
                              controller: bankIdController,
                              labelText: l10n.bankId,
                              hintText: l10n.bankIdHint,
                              isDense: true,
                            ),
                            const SizedBox(height: 8),
                            _buildGlassTextField(
                              controller: accountNoController,
                              labelText: l10n.accountNumber,
                              hintText: l10n.accountNumberHint,
                              keyboardType: TextInputType.number,
                              isDense: true,
                            ),
                            const SizedBox(height: 8),
                            _buildGlassTextField(
                              controller: accountNameController,
                              labelText: l10n.accountHolder,
                              hintText: l10n.accountHolderHint,
                              isDense: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              l10n.cancel,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              final name = nameController.text.trim();
                              final targetAmount = double.tryParse(
                                targetAmountController.text,
                              );
                              final bankId = bankIdController.text.trim();
                              final accountNo = accountNoController.text.trim();
                              final accountName = accountNameController.text
                                  .trim();

                              if (name.isNotEmpty &&
                                  targetAmount != null &&
                                  targetAmount > 0) {
                                final dbService = ref.read(
                                  databaseServiceProvider,
                                );
                                // Get selected denominations from settings
                                final selectedValues = ref.read(
                                  tileValuesProvider,
                                );
                                final denominations = selectedValues.toList()
                                  ..sort();

                                await dbService.createNewGoal(
                                  name,
                                  targetAmount: targetAmount,
                                  denominations: denominations,
                                  bankId: bankId.isNotEmpty ? bankId : null,
                                  accountNo: accountNo.isNotEmpty
                                      ? accountNo
                                      : null,
                                  accountName: accountName.isNotEmpty
                                      ? accountName
                                      : null,
                                );
                                if (context.mounted) Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(l10n.create),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    bool isDense = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        isDense: isDense,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.white70)
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(ref);
    final tilesAsync = ref.watch(savingsTilesProvider);
    final totalSaved = ref.watch(totalSavedProvider);
    final goalsAsync = ref.watch(allGoalsProvider);

    return RippleBackground(
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Title Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.pink.shade300,
                                Colors.pink.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            '🐷',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'iSaBo',
                              style: GoogleFonts.montserrat(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Digital Saving Box',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                // Goals PageView - Swipeable
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100,
                    child: goalsAsync.when(
                      data: (goals) {
                        if (goals.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: GlassCard(
                              title: l10n.noGoalsYet,
                              progress: 0,
                            ),
                          );
                        }
                        return PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentGoalIndex = index);
                            ref
                                .read(databaseServiceProvider)
                                .switchToGoal(goals[index].id);
                          },
                          itemCount: goals.length,
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: GlassCard(
                                title: goal.name ?? l10n.goal,
                                progress: goal.progress / 100,
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => Center(
                        child: Text(
                          l10n.errorLoadingGoals,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                // Page indicator dots
                SliverToBoxAdapter(
                  child: goalsAsync.when(
                    data: (goals) {
                      if (goals.length <= 1) return const SizedBox(height: 10);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            goals.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentGoalIndex == index ? 12 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentGoalIndex == index
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
                // Grid Title
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${l10n.totalSaved}: ${l10n.formatCurrencyFull(totalSaved.toDouble())}",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Savings Grid
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: tilesAsync.when(
                    data: (tiles) => SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final tile = tiles[index];
                        return SavingsTile(
                          amount: tile.amount,
                          isPaid: tile.isPaid,
                          onTap: () => _handleTileTap(tile),
                          isVietnamese: l10n.isVietnamese,
                        );
                      }, childCount: tiles.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                    ),
                    loading: () => const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, stack) => SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          l10n.errorLoadingData,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // FAB for creating new goal
            Positioned(
              right: 20,
              bottom: 100,
              child: FloatingActionButton(
                onPressed: _showCreateGoalDialog,
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: const Icon(Icons.add, color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentDialog extends ConsumerWidget {
  final SavingsTileData tile;
  final DatabaseService dbService;
  final PaymentService paymentService;
  final String? bankId;
  final String? accountNo;
  final String? accountName;

  const PaymentDialog({
    super.key,
    required this.tile,
    required this.dbService,
    required this.paymentService,
    this.bankId,
    this.accountNo,
    this.accountName,
  });

  bool get _hasBankInfo =>
      bankId != null &&
      bankId!.isNotEmpty &&
      accountNo != null &&
      accountNo!.isNotEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(ref);
    final qrUrl = !tile.isPaid && _hasBankInfo
        ? paymentService.generateVietQR(
            amount: tile.amount,
            memo: "Saving Tile ${tile.id}",
            bankId: bankId,
            accountNo: accountNo,
            accountName: accountName,
          )
        : "";

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tile.isPaid ? l10n.alreadySaved : l10n.confirmSaving,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                if (tile.isPaid) ...[
                  const Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                    size: 80,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${l10n.youSaved} \$${tile.amount}",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () async {
                      await dbService.markTileUnpaid(tile.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(
                      l10n.undoMarkUnpaid,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ] else if (!_hasBankInfo) ...[
                  // No bank info - show warning
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orangeAccent,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.bankInfoNotConfigured,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.addBankInfoMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await dbService.markTilePaid(tile.id);
                      // Postpone notification to tomorrow since user fed today
                      final container = ProviderScope.containerOf(context);
                      final notificationEnabled = container.read(
                        notificationEnabledProvider,
                      );
                      if (notificationEnabled) {
                        final notificationTime = container.read(
                          notificationTimeProvider,
                        );
                        final notificationService = container.read(
                          notificationServiceProvider,
                        );
                        await notificationService
                            .postponeNotificationToTomorrow(
                              time: notificationTime,
                              title: l10n.notificationTitle,
                              body: l10n.notificationBody,
                            );
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: Text(l10n.markAsPaidManually),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withValues(alpha: 0.8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        qrUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (ctx, err, stack) => const Center(
                          child: Icon(Icons.error, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await paymentService.launchBankApp();
                    },
                    icon: const Icon(Icons.account_balance),
                    label: Text(l10n.openBankApp),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await dbService.markTilePaid(tile.id);
                      // Postpone notification to tomorrow since user fed today
                      final container = ProviderScope.containerOf(context);
                      final notificationEnabled = container.read(
                        notificationEnabledProvider,
                      );
                      if (notificationEnabled) {
                        final notificationTime = container.read(
                          notificationTimeProvider,
                        );
                        final notificationService = container.read(
                          notificationServiceProvider,
                        );
                        await notificationService
                            .postponeNotificationToTomorrow(
                              time: notificationTime,
                              title: l10n.notificationTitle,
                              body: l10n.notificationBody,
                            );
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: Text(l10n.iHaveTransferred),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withValues(alpha: 0.8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

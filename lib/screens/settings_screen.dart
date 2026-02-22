import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../widgets/background_ripple.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import 'pig_overlay_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule notification on first load if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleNotificationIfEnabled();
    });
  }

  Future<void> _scheduleNotificationIfEnabled() async {
    final isEnabled = ref.read(notificationEnabledProvider);
    final time = ref.read(notificationTimeProvider);
    final notificationService = ref.read(notificationServiceProvider);

    if (isEnabled) {
      final l10n = AppLocalizations.of(ref);
      await notificationService.scheduleDailyNotification(
        time: time,
        title: l10n.notificationTitle,
        body: l10n.notificationBody,
      );
    } else {
      await notificationService.cancelAllNotifications();
    }
  }

  void _showPigDemo() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return PigOverlayScreen(
            onFeed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🐷 Heo con đã được cho ăn! Cảm ơn bạn!'),
                  backgroundColor: Colors.green,
                ),
              );
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

  Future<void> _selectTime() async {
    final currentTime = ref.read(notificationTimeProvider);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF58BCFF),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A4A),
              onSurface: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF1A1A3A),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dayPeriodColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? const Color(0xFF58BCFF).withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
              dayPeriodTextColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? const Color(0xFF58BCFF)
                    : Colors.white70,
              ),
              hourMinuteColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? const Color(0xFF58BCFF).withValues(alpha: 0.3)
                    : const Color(0xFF2A2A4A),
              ),
              hourMinuteTextColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? const Color(0xFF58BCFF)
                    : Colors.white,
              ),
              dialHandColor: const Color(0xFF58BCFF),
              dialBackgroundColor: const Color(0xFF2A2A4A),
              dialTextColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? Colors.white
                    : Colors.white70,
              ),
              entryModeIconColor: Colors.white70,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF58BCFF),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref.read(notificationTimeProvider.notifier).state = picked;
      await _scheduleNotificationIfEnabled();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final l10n = AppLocalizations.of(ref);
    final notificationTime = ref.watch(notificationTimeProvider);
    final notificationsEnabled = ref.watch(notificationEnabledProvider);

    return RippleBackground(
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  l10n.settings,
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Language Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.language,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildLanguageButton(
                              "English",
                              "EN",
                              AppLanguage.en,
                              currentLang == AppLanguage.en,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildLanguageButton(
                              "Tiếng Việt",
                              "VN",
                              AppLanguage.vi,
                              currentLang == AppLanguage.vi,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.notifications,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingRow(
                        icon: Icons.notifications_outlined,
                        title: l10n.dailyReminder,
                        trailing: Switch(
                          value: notificationsEnabled,
                          onChanged: (val) async {
                            ref
                                    .read(notificationEnabledProvider.notifier)
                                    .state =
                                val;
                            await _scheduleNotificationIfEnabled();
                          },
                          activeColor: const Color(0xFF58BCFF),
                        ),
                      ),
                      const Divider(color: Colors.white24),
                      _buildSettingRow(
                        icon: Icons.access_time,
                        title: l10n.reminderTime,
                        subtitle: notificationTime.format(context),
                        onTap: _selectTime,
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white70,
                        ),
                      ),
                      const Divider(color: Colors.white24),
                      _buildSettingRow(
                        icon: Icons.play_circle_outline,
                        title: 'Test thông báo',
                        subtitle: 'Xem demo Heo con đòi ăn',
                        onTap: _showPigDemo,
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tileValues,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.selectTileValue,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTileValueSelector(l10n),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.about,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingRow(
                        icon: Icons.info_outline,
                        title: l10n.version,
                        trailing: Text(
                          "1.0.0",
                          style: GoogleFonts.montserrat(color: Colors.white70),
                        ),
                      ),
                      const Divider(color: Colors.white24),
                      _buildSettingRow(
                        icon: Icons.code,
                        title: l10n.madeWithFlutter,
                        trailing: const FlutterLogo(size: 24),
                      ),
                      const Divider(color: Colors.white24),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            l10n.copyright,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    String label,
    String code,
    AppLanguage language,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(languageProvider.notifier).state = language;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              code,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTileValueSelector(AppLocalizations l10n) {
    final isVN = l10n.isVietnamese;
    final selectedValues = ref.watch(tileValuesProvider);

    // EN: $1, $2, $5, $10, $20, $50, $100
    // VN: 10k, 20k, 50k, 100k, 200k, 500k (stored as 10000, 20000, etc.)
    final values = isVN
        ? [10000, 20000, 50000, 100000, 200000, 500000]
        : [1, 2, 5, 10, 20, 50, 100];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: values.map((value) {
        final isSelected = selectedValues.contains(value);
        final displayText = isVN ? '${(value ~/ 1000)}k' : '\$$value';

        return GestureDetector(
          onTap: () {
            final current = ref.read(tileValuesProvider);
            final newSet = Set<int>.from(current);
            if (newSet.contains(value)) {
              // Don't allow deselecting if it's the last one
              if (newSet.length > 1) {
                newSet.remove(value);
              }
            } else {
              newSet.add(value);
            }
            ref.read(tileValuesProvider.notifier).state = newSet;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF58BCFF).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF58BCFF)
                    : Colors.white.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              displayText,
              style: GoogleFonts.montserrat(
                color: isSelected ? const Color(0xFF58BCFF) : Colors.white,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      color: titleColor ?? Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation() {
    final l10n = AppLocalizations.of(ref);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetConfirmTitle),
        content: Text(l10n.resetConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.reset)));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }
}

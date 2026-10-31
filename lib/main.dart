import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/ai_scanner_tab.dart';
import 'screens/analytics_tab.dart';
import 'screens/auth_team_tab.dart';
import 'screens/dashboard_tab.dart';
import 'screens/health_tab.dart';
import 'screens/lock_screen_overlay.dart';
import 'state/fithabit_controller.dart';
import 'utils/bento_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FitHabitApp());
}

class FitHabitApp extends StatelessWidget {
  const FitHabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitHabit – Smart Habit & Wellness Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: BentoTextStyles.fontFamily,
        scaffoldBackgroundColor: BentoColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: BentoColors.deepForest,
          primary: BentoColors.deepForest,
          secondary: BentoColors.mintEmerald,
          surface: BentoColors.surface,
        ),
      ),
      home: const FitHabitHomeScreen(),
    );
  }
}

class FitHabitHomeScreen extends StatefulWidget {
  const FitHabitHomeScreen({super.key});

  @override
  State<FitHabitHomeScreen> createState() => _FitHabitHomeScreenState();
}

class _FitHabitHomeScreenState extends State<FitHabitHomeScreen> {
  final FitHabitController _controller = FitHabitController();
  int _currentTab = 0;
  bool _useMobileDeviceFrame = true;

  String? _toastTitle;
  String? _toastMessage;
  Color _toastColor = BentoColors.mintEmerald;
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _showToast(String title, String message, Color color) {
    _toastTimer?.cancel();
    setState(() {
      _toastTitle = title;
      _toastMessage = message;
      _toastColor = color;
    });
    _toastTimer = Timer(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      setState(() {
        _toastTitle = null;
        _toastMessage = null;
      });
    });
  }

  void _openGradingModeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                color: BentoColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chế độ chấm đồ án • Nhóm 12 (23DTHD5)',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: BentoColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Bật nhãn sub-caption (CN 01..08) trên từng thẻ chức năng',
                              style: TextStyle(
                                fontSize: 12,
                                color: BentoColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _controller.showGradingMode,
                        activeThumbColor: BentoColors.deepForest,
                        onChanged: (_) {
                          _controller.toggleGradingMode();
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: BentoColors.border, height: 1),
                  const SizedBox(height: 12),
                  _buildGradingMapItem(
                    'CN 01 & 05 & 07',
                    'Tài khoản, Bảo mật PIN/FaceID, Nhắc giờ & Sync SQLite/Firebase',
                    4,
                    ctx,
                  ),
                  _buildGradingMapItem(
                    'CN 02 & 06',
                    'Quản lý Thói quen (CRUD), Tìm kiếm & Lọc đa tiêu chí',
                    0,
                    ctx,
                  ),
                  _buildGradingMapItem(
                    'CN 03',
                    'Chỉ số cơ thể BMI (WHO) & Theo dõi lượng nước uống (ml)',
                    1,
                    ctx,
                  ),
                  _buildGradingMapItem(
                    'CN 04',
                    'Thống kê Streak, Heatmap 12 tuần, Bar Chart & Doughnut',
                    3,
                    ctx,
                  ),
                  _buildGradingMapItem(
                    'CN 08',
                    'Quét AI Calo (Công thức Atwater 4P+4C+9F) & Lộ trình tập',
                    2,
                    ctx,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGradingMapItem(
    String code,
    String desc,
    int tabIndex,
    BuildContext sheetCtx,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(sheetCtx);
        setState(() => _currentTab = tabIndex);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: BentoColors.mintSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code,
                style: BentoTextStyles.subCaption(
                  color: BentoColors.deepForest,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                desc,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: BentoColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: BentoColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileStatusBar() {
    return Container(
      color: BentoColors.surface,
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '09:41',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: BentoColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          // Dynamic Island Pill
          Container(
            width: 96,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _controller.isOnline
                        ? BentoColors.mintEmerald
                        : BentoColors.warmCoral,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.signal_cellular_alt_rounded,
                size: 14,
                color: BentoColors.textPrimary,
              ),
              SizedBox(width: 4),
              Icon(
                Icons.wifi_rounded,
                size: 14,
                color: BentoColors.textPrimary,
              ),
              SizedBox(width: 4),
              Icon(
                Icons.battery_full_rounded,
                size: 16,
                color: BentoColors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileAppViewport(
    BuildContext context, {
    required bool showSimulatedStatusBar,
  }) {
    final initials = _controller.currentUserName.isNotEmpty
        ? _controller.currentUserName.trim().split(' ').last[0]
        : 'H';

    return Scaffold(
      backgroundColor: BentoColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              if (showSimulatedStatusBar) _buildMobileStatusBar(),

              // Minimalist Commercial AppBar
              Container(
                decoration: const BoxDecoration(
                  color: BentoColors.surface,
                  border: Border(
                    bottom: BorderSide(color: BentoColors.border, width: 1),
                  ),
                ),
                child: SafeArea(
                  top: !showSimulatedStatusBar,
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: BentoColors.deepForest,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.spa_outlined,
                            color: BentoColors.mintEmerald,
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'FitHabit',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  color: BentoColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                _controller.showGradingMode
                                    ? 'NHÓM 12 • 23DTHD5'
                                    : 'Smart Habit & Wellness',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: _controller.showGradingMode
                                      ? BentoColors.mintEmerald
                                      : BentoColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Grading Mode / Info Button
                        IconButton(
                          onPressed: () => _openGradingModeSheet(context),
                          tooltip: 'Thông tin & Chế độ chấm đồ án',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: Icon(
                            Icons.info_outline_rounded,
                            size: 19,
                            color: _controller.showGradingMode
                                ? BentoColors.mintEmerald
                                : BentoColors.textSecondary,
                          ),
                        ),

                        // Lock App Button
                        IconButton(
                          onPressed: _controller.lockApp,
                          tooltip: 'Khóa ứng dụng (PIN / FaceID)',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: const Icon(
                            Icons.lock_outline_rounded,
                            size: 19,
                            color: BentoColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Cloud Sync Status (8px dot + Cloud Icon)
                        InkWell(
                          onTap: () {
                            _controller.toggleNetworkMode();
                            _showToast(
                              _controller.isOnline
                                  ? 'Đã bật đồng bộ Cloud'
                                  : 'Chế độ Offline SQLite',
                              _controller.isOnline
                                  ? 'Đã kết nối lại Firebase Realtime.'
                                  : 'Thao tác được lưu tạm vào hàng đợi SQLite.',
                              _controller.isOnline
                                  ? BentoColors.mintEmerald
                                  : BentoColors.warmCoral,
                            );
                          },
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: BentoColors.background,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: BentoColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _controller.isOnline
                                        ? BentoColors.mintEmerald
                                        : BentoColors.warmCoral,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _controller.isOnline
                                      ? Icons.cloud_done_outlined
                                      : Icons.cloud_off_outlined,
                                  size: 15,
                                  color: BentoColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // User Avatar
                        InkWell(
                          onTap: () => setState(() => _currentTab = 4),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: BentoColors.deepForest,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: BentoColors.mintEmerald.withValues(
                                  alpha: 0.4,
                                ),
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main Content Area
              Expanded(
                child: IndexedStack(
                  index: _currentTab,
                  children: [
                    DashboardTab(
                      controller: _controller,
                      onShowToast: _showToast,
                    ),
                    HealthTab(
                      controller: _controller,
                      onShowToast: _showToast,
                    ),
                    AiScannerTab(
                      controller: _controller,
                      onShowToast: _showToast,
                    ),
                    AnalyticsTab(
                      controller: _controller,
                      onShowToast: _showToast,
                    ),
                    AuthTeamTab(
                      controller: _controller,
                      onShowToast: _showToast,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 5-Tab Bottom Navigation Bar with Raised Center AI Scanner Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: BentoColors.surface,
                border: const Border(
                  top: BorderSide(color: BentoColors.border, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                      child: Row(
                        children: [
                          _buildNavTab(
                            index: 0,
                            icon: Icons.grid_view_rounded,
                            label: 'Tổng quan',
                          ),
                          _buildNavTab(
                            index: 1,
                            icon: Icons.favorite_border_rounded,
                            activeIcon: Icons.favorite_rounded,
                            label: 'Sức khỏe',
                          ),
                          _buildCenterAiScanButton(),
                          _buildNavTab(
                            index: 3,
                            icon: Icons.bar_chart_rounded,
                            label: 'Thống kê',
                          ),
                          _buildNavTab(
                            index: 4,
                            icon: Icons.person_outline_rounded,
                            activeIcon: Icons.person_rounded,
                            label: 'Cá nhân',
                          ),
                        ],
                      ),
                    ),
                    if (showSimulatedStatusBar)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6, top: 2),
                        child: Container(
                          width: 120,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Minimalist Toast Banner
          if (_toastTitle != null)
            Positioned(
              top: showSimulatedStatusBar ? 96 : 68,
              left: 14,
              right: 14,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: BentoColors.deepForest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _toastColor.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: _toastColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _toastTitle!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_toastMessage != null)
                              Text(
                                _toastMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFD1FAE5),
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Lock Screen Overlay
          if (_controller.isAppLocked)
            LockScreenOverlay(
              controller: _controller,
              onShowToast: _showToast,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideDesktop = constraints.maxWidth > 500;

            if (!isWideDesktop || !_useMobileDeviceFrame) {
              return Stack(
                children: [
                  _buildMobileAppViewport(
                    context,
                    showSimulatedStatusBar: false,
                  ),
                  if (isWideDesktop)
                    Positioned(
                      right: 16,
                      top: 14,
                      child: Material(
                        color: Colors.transparent,
                        child: FilledButton.tonalIcon(
                          onPressed: () {
                            setState(() => _useMobileDeviceFrame = true);
                          },
                          icon: const Icon(Icons.smartphone_rounded, size: 16),
                          label: const Text(
                            'Khung di động',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: BentoColors.mintSoft,
                            foregroundColor: BentoColors.deepForest,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }

            // Mobile Device Frame Mode on Desktop / Browser
            final availableHeight = constraints.maxHeight;
            final frameHeight = (availableHeight - 32).clamp(660.0, 868.0);
            const frameWidth = 408.0;

            return Container(
              color: const Color(0xFFE7EAE4),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: frameWidth,
                      height: frameHeight,
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181B),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: const Color(0xFF3F3F46),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: BentoColors.deepForest.withValues(
                              alpha: 0.18,
                            ),
                            blurRadius: 42,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(39),
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            size: Size(frameWidth - 22, frameHeight - 22),
                            padding: EdgeInsets.zero,
                          ),
                          child: _buildMobileAppViewport(
                            context,
                            showSimulatedStatusBar: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 20,
                    child: Material(
                      color: Colors.transparent,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _useMobileDeviceFrame = false);
                        },
                        icon: const Icon(Icons.fullscreen_rounded, size: 17),
                        label: const Text(
                          'Mở rộng màn hình',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                          foregroundColor: BentoColors.deepForest,
                          side: const BorderSide(color: BentoColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNavTab({
    required int index,
    required IconData icon,
    IconData? activeIcon,
    required String label,
  }) {
    final active = _currentTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentTab = index),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? (activeIcon ?? icon) : icon,
                size: 20,
                color: active
                    ? BentoColors.deepForest
                    : BentoColors.textMuted,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active
                      ? BentoColors.deepForest
                      : BentoColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterAiScanButton() {
    final active = _currentTab == 2;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 38,
              decoration: BoxDecoration(
                color: active
                    ? BentoColors.mintEmerald
                    : BentoColors.deepForest,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: BentoColors.deepForest.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.center_focus_strong_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Quét AI',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: active
                    ? BentoColors.mintEmerald
                    : BentoColors.deepForest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
